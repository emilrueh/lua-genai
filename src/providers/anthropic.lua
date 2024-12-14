-- "https://api.anthropic.com/v1/messages"

local utils = require("src.utils")

---@module "src.ai.anthropic"
local anthropic = {}

---Return nil as system prompt is provided in top-level payload
---@param system_prompt string
---@return nil
function anthropic.construct_system_message(system_prompt)
	return nil
end

---Package user prompt
---@param user_prompt string
---@return table
function anthropic.construct_user_message(user_prompt)
	local user_message = { role = "user", content = user_prompt }
	return user_message
end

---Package AI reply
---@param reply string
---@return table
function anthropic.construct_assistant_message(reply)
	local assistant_message = { role = "assistant", content = reply }
	return assistant_message
end

---Construct the request headers
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

---Packaging AI settings
---@param opts table
---@return table
function anthropic.construct_payload(opts)
	local messages = opts.history
	local system_prompt = opts.system_prompt
	local model = opts.model
	local max_tokens = opts.max_tokens

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
