local config = require("src.config")
local utils = require("src.utils")

local json = config.json

---@module "src.ai.google"
local google = {}

---OpenAI API call to v1/chat/completions endpoint
---@param user_prompt string
---@param system_prompt string
---@param model string
---@param api_key string
---@return string|nil reply
function google.call(user_prompt, system_prompt, model, api_key)
	local messages = {
		-- system prompt
		system_instruction = { parts = { text = system_prompt } },
		-- user prompts
		contents = {
			role = "user",
			parts = { { text = user_prompt } },
		},
	}

	local endpoint = "https://generativelanguage.googleapis.com/v1beta/models/"
		.. model
		.. ":generateContent?key="
		.. api_key

	local headers = {
		["Content-Type"] = "application/json",
	}

	local payload = json.encode(messages)

	local response = utils.make_request(endpoint, payload, "POST", headers)
	local response_decoded = json.decode(response)

	if response then
		local reply = response_decoded.candidates[1].content.parts[1].text

		-- local input_tokens = response_decoded.usage.prompt_tokens
		-- local output_tokens = response_decoded.usage.completion_tokens

		-- return reply, input_tokens, output_tokens
		return reply
	end
end

return google
