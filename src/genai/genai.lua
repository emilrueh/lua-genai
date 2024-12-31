local cjson = require("cjson")
local utils = require("genai.utils")
local providers = require("genai.providers")
local features = require("genai.features")

---Client for interacting with specified API endpoint
---@class GenAI
---@field _api_key string?
---@field _endpoint string
---@field provider table|nil
---@field _determine_provider function
local GenAI = {}
GenAI.__index = GenAI

---@param api_key? string
---@param endpoint string
function GenAI.new(api_key, endpoint)
	local self = setmetatable({}, GenAI)
	self._api_key = api_key
	self._endpoint = endpoint
	self.provider = self:_determine_provider(providers)
	return self
end

---Check endpoint for occurance of ai provider name
---@param providers table Collection of GenAI provider modules
---@return table? provider_module Collection of functions determining input and output structure
function GenAI:_determine_provider(providers)
	local provider = nil
	for provider_name, provider_module in pairs(providers) do
		if self._endpoint:find(provider_name) then provider = provider_module end
	end
	assert(provider, "GenAI provider could not be determined from provided endpoint")
	return provider
end

---Prepare streaming requirements if set to stream
---@param processor function? Display of streamed text chunks
---@return table? accumulator Schema storing full streamed response
---@return function? callback Streaming handler
function GenAI:_setup_stream(processor)
	local accumulator = nil
	local callback = nil

	if processor then
		accumulator = utils.Accumulator.new(cjson.encode(self.provider.response_schema))
		local handler = self.provider.create_stream_handler(accumulator, processor)
		callback = utils.create_sse_callback({ self.provider.stream_pattern, handler })
	end

	return accumulator, callback
end

---Prepare API call payload and streaming options
---@param opts table Payload including model settings and chat history
---@return table headers
---@return table payload
---@return function? callback Streaming handler
---@return table? accumulator Schema storing full streamed response
function GenAI:_prepare_response_requirements(opts)
	local headers = self.provider.construct_headers(self._api_key)
	local payload = self.provider.construct_payload(opts)
	local accumulator, callback = self:_setup_stream(opts.settings.stream)
	return headers, payload, callback, accumulator
end

---Execute API call to specified GenAI model with all payload and settings
---@param opts table Payload including model settings and chat history
---@return string reply
---@return number input_tokens
---@return number output_tokens
function GenAI:call(opts)
	local headers, payload, callback, accumulator = self:_prepare_response_requirements(opts)

	local response = utils.send_request(
		self._endpoint,
		cjson.encode(payload),
		"POST",
		headers,
		callback,
		self.provider.handle_exceptions
	)

	local reply, input_tokens, output_tokens =
		self.provider.extract_response_data(accumulator and accumulator.schema or response)
	reply = type(reply) == "table" and cjson.encode(reply) or reply -- ensure json output is string

	return reply, input_tokens, output_tokens
end

-- features:

---Create chat instance with automatic tracking of messages and tokens
---@param model string
---@param opts table? Containing **settings** and or **system_prompt**
---@return Chat
function GenAI:chat(model, opts)
	return features.Chat.new(self, model, opts)
end

return GenAI
