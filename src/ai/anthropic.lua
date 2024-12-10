local config = require("src.config")
local utils = require("src.utils")

local json = config.json

---@module "src.ai.anthropic"
local anthropic = {}

---extract system prompt and confirm user prompt
---@param messages table
---@return string|nil system_prompt
local function extract_and_confirm_messages(messages)
	local system_prompt = nil
	local user_prompt = nil

	local copy = utils.shallow_copy_table(messages)

	for i, message in ipairs(copy) do
		-- extract user prompt to validate existance
		if message.role == "user" then
			user_prompt = message.content
		-- extract system prompt and remove from messages
		elseif message.role == "system" then
			system_prompt = message.content
			table.remove(messages, i)
		end
	end

	assert(user_prompt, "A user prompt must be specified.")

	return system_prompt
end

---Anthropic API call to v1/messages endpoint
---@param messages table
---@param model string|nil
---@param api_key string
---@return string|nil reply
---@return integer|nil input_tokens
---@return integer|nil output_tokens
function anthropic.call(messages, model, api_key)
	local system_prompt = extract_and_confirm_messages(messages)

	-- set defaults
	model = model or "claude-3-5-haiku-20241022"

	local endpoint = "https://api.anthropic.com/v1/messages"

	local headers = {
		["x-api-key"] = api_key,
		["anthropic-version"] = "2023-06-01", -- https://docs.anthropic.com/en/api/versioning
		["content-type"] = "application/json",
	}

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
