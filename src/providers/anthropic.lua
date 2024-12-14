-- "https://api.anthropic.com/v1/messages"

local utils = require("src.utils")

---@module "src.ai.anthropic"
local anthropic = {}

---Extract system prompt from messages
---@param messages table
---@return string|nil system_prompt
local function _extract_and_confirm_messages(messages)
	local system_prompt = nil

	local copy = utils.shallow_copy_table(messages)

	for i, message in ipairs(copy) do
		-- extract system prompt and remove from messages
		if message.role == "system" then
			system_prompt = message.content
			table.remove(messages, i)
		end
	end

	return system_prompt
end

---Constructing the request headers
---@param api_key string
---@return table headers
function anthropic.construct_headers(api_key)
	local headers = {
		["x-api-key"] = api_key,
		["anthropic-version"] = "2023-06-01", -- https://docs.anthropic.com/en/api/versioning
		["content-type"] = "application/json",
	}

	return headers
end

function anthropic.construct_payload(opts)
	local model = opts.model
	local messages = opts.messages
	local max_tokens = opts.max_tokens

	local system_prompt = _extract_and_confirm_messages(messages)

	local payload = {
		model = model,
		system = system_prompt,
		messages = messages,
		max_tokens = max_tokens or 1024, -- required
	}

	return payload
end

---Extracting reply and tokens from client response
---@param response table
---@return string reply
---@return number input_tokens
---@return number output_tokens
function anthropic.extract_response_data(response)
	local reply = response.content[1].text
	local input_tokens = response.usage.input_tokens
	local output_tokens = response.usage.output_tokens

	return reply, input_tokens, output_tokens
end

return anthropic
