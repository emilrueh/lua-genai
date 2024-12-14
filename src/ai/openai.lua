local config = require("src.config")
local utils = require("src.utils")

local json = config.json

-- https://www.youtube.com/watch?v=g1iKA3lSFms

--- OpenAI API client for interacting with specified endpoint
---@class OpenAI
---@field api_key string
---@field endpoint string
local OpenAI = {}
OpenAI.__index = OpenAI

function OpenAI.new(api_key, endpoint)
	local self = setmetatable({}, OpenAI)

	self.api_key = api_key
	self.endpoint = endpoint

	return self
end

--- OpenAI API call to specified model
---@param messages table
---@param model string
---@return string|nil reply
---@return integer|nil input_tokens
---@return integer|nil output_tokens
function OpenAI:call(messages, model)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. self.api_key,
	}

	local payload = json.encode({
		model = model,
		messages = messages,
	})

	local response = json.decode(utils.make_request(self.endpoint, payload, "POST", headers))

	if response then
		local reply = response.choices[1].message.content
		local input_tokens = response.usage.prompt_tokens
		local output_tokens = response.usage.completion_tokens

		return reply, input_tokens, output_tokens
	end
end

return OpenAI
