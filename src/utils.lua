local config = require("src.config")

local cjson = config.cjson
local https = config.https
local ltn12 = config.ltn12

---@module "src.utils"
local utils = {}

---Https request with partial response functionality via callback
---@param url string
---@param payload table?
---@param method string?
---@param headers table?
---@param callback function?
---@return string body
---@return table response_headers
function utils.send_request(url, payload, method, headers, callback)
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
	assert(status_code == 200, body)
	return body, response_headers
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

---Generic parsing of SSE via callback
---@param opts table
---@return function chunk_callback
function utils.create_sse_callback(opts)
	local pattern, handler, accumulator = table.unpack(opts)

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
				if ok and obj then handler(obj, accumulator) end
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

---Gather and select provider specific data
---@param arg table Command line flags
---@param api_keys table
---@return string model
---@return string api_key
---@return string endpoint
---@return table settings AI settings like max_tokens etc.
function utils.get_provider_specifics(arg, api_keys)
	local provider = arg[1]
	local model = arg[2]
	local api_key = nil
	local endpoint = nil
	local settings = nil

	if provider == "openai" then
		api_key = api_keys.openai_api_key
		endpoint = "https://api.openai.com/v1/chat/completions"
		model = model or "gpt-4o-mini"
		settings = {
			stream = true,
		}
	elseif provider == "anthropic" then
		api_key = api_keys.anthropic_api_key
		endpoint = "https://api.anthropic.com/v1/messages"
		model = model or "claude-3-5-haiku-20241022"
		settings = {
			stream = true,
		}
	else
		error("Provider " .. provider .. " is not supported!")
	end

	return model, api_key, endpoint, settings
end

---Loop over input until not empty
---@param input_marker string? Character to display infront of user input
---@return string user_prompt
function utils.ensure_user_input(input_marker)
	input_marker = input_marker or ""
	local user_prompt = ""

	while true do
		io.write(input_marker)
		io.flush()
		user_prompt = io.read()
		if user_prompt and user_prompt ~= "" then return user_prompt end
	end
end

---Accumulate multi-line input until a marker is reached
---@param end_marker string?
---@return string user_prompt
function utils.get_multiline_input(end_marker)
	end_marker = end_marker or ":end"

	local lines = {}
	while true do
		local line = io.read()
		if not line or line == end_marker then break end
		table.insert(lines, line)
	end
	return table.concat(lines, "\n")
end

return utils
