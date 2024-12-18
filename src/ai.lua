local config = require("src.config")
local utils = require("src.utils")
local providers = require("src.providers._load")
local cjson = config.cjson

---Client for interacting with specified API endpoint
---@class AI
---@field _api_key string
---@field _endpoint string
---@field provider table|nil
---@field _determine_provider function
local AI = {}
AI.__index = AI

---@param api_key string
---@param endpoint string
function AI.new(api_key, endpoint)
	local self = setmetatable({}, AI)
	self._api_key = api_key
	self._endpoint = endpoint
	self.provider = self:_determine_provider(providers)
	return self
end

---Check endpoint for occurance of ai provider name
---@param providers table Collection of AI provider modules
---@return table|nil provider_module Collection of functions determining input and output structure
function AI:_determine_provider(providers)
	local provider = nil
	for provider_name, provider_module in pairs(providers) do
		if self._endpoint:find(provider_name) then provider = provider_module end
	end
	assert(provider, "AI provider could not be determined from provided endpoint")
	return provider
end

---Prepare streaming requirements if set to stream
---@param payload table
---@return table|nil accumulator Schema storing full streamed response
---@return function|nil callback Streaming handler
function AI:_setup_stream(payload)
	local accumulator = nil
	local callback = nil
	if payload.stream then
		accumulator = utils.Accumulator.new(cjson.encode(self.provider.response_schema))
		local callback_opts = { self.provider.match_pattern, self.provider.handle_stream_data, accumulator }
		callback = payload.stream and utils.create_sse_callback(callback_opts)
	end
	return accumulator, callback
end

---Prepare API call payload and streaming options
---@param opts table Payload including model settings and chat history
---@return table headers
---@return table payload
---@return function|nil callback Streaming handler
---@return table|nil accumulator Schema storing full streamed response
function AI:_prepare_response_requirements(opts)
	local headers = self.provider.construct_headers(self._api_key)
	local payload = self.provider.construct_payload(opts)
	local accumulator, callback = self:_setup_stream(payload)
	return headers, payload, callback, accumulator
end

---Execute API call to specified AI model with all payload and settings
---@param opts table Payload including model settings and chat history
---@return string reply
---@return number input_tokens
---@return number output_tokens
function AI:call(opts)
	local headers, payload, callback, accumulator = self:_prepare_response_requirements(opts)
	local response = utils.send_request(self._endpoint, cjson.encode(payload), "POST", headers, callback)
	return self.provider.extract_response_data(accumulator and accumulator.schema or cjson.decode(response))
end

return AI
