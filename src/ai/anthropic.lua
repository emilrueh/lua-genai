local config = require("src.config")
local utils = require("src.utils")

local json = config.json

---@module "src.ai.anthropic"
local anthropic = {}

---Anthropic API call to v1/messages endpoint
---@param user_prompt string
---@param system_prompt string|nil
---@param model string|nil
---@param api_key string
---@return string|nil reply
---@return integer|nil input_tokens
---@return integer|nil output_tokens
function anthropic.call(user_prompt, system_prompt, model, api_key)
	assert(user_prompt, "A user prompt must be specified.")

	model = model or "claude-3-5-haiku-20241022"

	local endpoint = "https://api.anthropic.com/v1/messages"

	local headers = {
		["x-api-key"] = api_key,
		["anthropic-version"] = "2023-06-01", -- https://docs.anthropic.com/en/api/versioning
		["content-type"] = "application/json",
	}

	local messages = {}
	table.insert(messages, { role = "user", content = user_prompt })

	local payload = json.encode({
		model = model,
		system = system_prompt,
		messages = messages,
		max_tokens = 1024,
	})

	local response = utils.make_request(endpoint, payload, "POST", headers)
	local response_decoded = json.decode(response)

	if response_decoded then
		local reply = response_decoded.content[1].text
		local input_tokens = response_decoded.usage.input_tokens
		local output_tokens = response_decoded.usage.output_tokens

		return reply, input_tokens, output_tokens
	end
end

return anthropic
