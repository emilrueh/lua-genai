local config = require("src.config")
local utils = require("src.utils")

local providers = require("src.providers._load")

local cjson = config.cjson

---AI API client for interacting with specified endpoint
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
---@param providers table
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
---@param opts table
---@return string reply
function AI:call(opts)
	local headers = self.provider.construct_headers(self._api_key)
	local payload = cjson.encode(self.provider.construct_payload(opts))
	local response = cjson.decode(utils.send_request(self._endpoint, payload, "POST", headers))
	local reply, input_tokens, output_tokens = self.provider.extract_response_data(response)

	return reply
end

return AI
