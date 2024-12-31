local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

---@module "genai.utils"
local utils = {}

---Https request with partial response functionality via callback
---@param url string
---@param payload table?
---@param method string?
---@param headers table?
---@param callback function?
---@param exception_handler function?
---@return string|table body
function utils.send_request(url, payload, method, headers, callback, exception_handler)
	local response_body = {}
	local final_sink = ltn12.sink.table(response_body)

	---Trigger streamed response parsing
	---@param chunk string
	---@return string chunk
	local function stream_filter(chunk)
		if chunk and callback then callback(chunk) end
		return chunk
	end

	-- if payload then headers["Content-Length"] = #payload end

	local request_opts = {
		url = url,
		method = method,
		headers = headers,
		sink = callback and ltn12.sink.chain(stream_filter, final_sink) or final_sink,
		source = payload and ltn12.source.string(payload) or nil,
	}

	local _, status_code, response_headers = https.request(request_opts)
	local body = table.concat(response_body)

	-- decode body if json response
	if response_headers["content-type"]:find("application/json") then body = cjson.decode(body) end

	-- handle status codes
	if exception_handler then
		exception_handler(body, status_code)
	else
		assert(status_code == 200, body)
	end

	return body
end

---Storage for full stream response
---@class Accumulator
---@field schema table Provider specific non-streamed response matching schema
local Accumulator = {}
Accumulator.__index = Accumulator

---@param schema string Encoded provider specific schema table
function Accumulator.new(schema)
	local self = setmetatable({}, Accumulator)
	self.schema = cjson.decode(schema)
	return self
end

utils.Accumulator = Accumulator

---Closure to parse SSE via callback
---@param opts table
---@return function chunk_callback
function utils.create_sse_callback(opts)
	local pattern, handler = table.unpack(opts)

	local buffer = ""

	---Callback to parse chunks from SSE
	---@param chunk string
	local function chunk_callback(chunk)
		if not chunk then return end
		buffer = buffer .. chunk

		while true do
			local newline_pos = buffer:find("\n")
			if not newline_pos then break end

			local line = buffer:sub(1, newline_pos - 1)
			buffer = buffer:sub(newline_pos + 1)

			local json_str = line:match(pattern)
			if json_str then
				local ok, obj = pcall(cjson.decode, json_str)
				if ok and obj then handler(obj) end
			end
		end
	end
	return chunk_callback
end

---Caculate model pricing from input and output tokens in USD
---@param model string
---@param usage table
---@param pricing table
---@return number
function utils.calc_token_cost(model, usage, pricing)
	local model_pricing = pricing[model]

	if model_pricing then
		local one_mil = 1000000
		local input_cost = usage.input * (model_pricing.input / one_mil)
		local output_cost = usage.output * (model_pricing.output / one_mil)
		return input_cost + output_cost
	else
		return 0
	end
end

return utils
