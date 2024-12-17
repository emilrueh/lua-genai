local config = require("src.config")

local cjson = config.cjson
local https = config.https
local ltn12 = config.ltn12

---@module "src.utils"
local utils = {}

---Https request with partial response functionality via callback
---@param url string
---@param payload table|nil
---@param method string|nil
---@param headers table|nil
---@param callback function|nil
---@return string body
---@return table response_headers
function utils.send_request(url, payload, method, headers, callback)
	local response_body = {}
	local final_sink = ltn12.sink.table(response_body)

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

return utils
