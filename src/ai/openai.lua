local config = require("src.config")
local utils = require("src.utils")

local json = config.json

---@module "src.ai.openai"
local openai = {}

---OpenAI API call to v1/chat/completions endpoint
---@param messages table
---@param model string
---@param api_key string
---@return string|nil reply
---@return integer|nil input_tokens
---@return integer|nil output_tokens
function openai.call(messages, model, api_key)
	local endpoint = "https://api.openai.com/v1/chat/completions"

	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	local payload = json.encode({
		model = model,
		messages = messages,
	})

	local response = utils.make_request(endpoint, payload, "POST", headers)
	local response_decoded = json.decode(response)

	if response then
		local reply = response_decoded.choices[1].message.content
		local input_tokens = response_decoded.usage.prompt_tokens
		local output_tokens = response_decoded.usage.completion_tokens

		return reply, input_tokens, output_tokens
	end
end

return openai
