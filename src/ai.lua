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

function AI.new(api_key, endpoint)
	local self = setmetatable({}, AI)

	self._api_key = api_key
	self._endpoint = endpoint

	-- Determine AI provider module to load
	self.provider = self:_determine_provider(providers)
	assert(self.provider, "AI provider could not be determined from provided endpoint")

	return self
end

---Check endpoint for occurance of ai provider name
---@param providers table Collection of AI provider modules
---@return table|nil provider_module
function AI:_determine_provider(providers)
	for provider_name, provider_module in pairs(providers) do
		if self._endpoint:find(provider_name) then
			return provider_module
		end
	end

	return nil -- default if no provider found
end

---OpenAI API call to specified model
---@param opts table Payload including model settings and chat history
---@return string|nil reply
function AI:call(opts)
	local headers = self.provider.construct_headers(self._api_key)
	local payload = cjson.encode(self.provider.construct_payload(opts))

	-- TODO: make this file independent of specific setting structure like opts.settings.stream
	-- - right now it Chat contains the stream = True setting
	-- - perhaps it should be set within the AI client?

	local callback = nil
	if opts.settings.stream then
		callback = self.provider.callback
	end

	local response = utils.send_request(self._endpoint, payload, "POST", headers, callback)

	if callback then
		return self.provider.assemble_stream_data()
	else
		return self.provider.extract_response_data(cjson.decode(response))
	end
end

return AI
