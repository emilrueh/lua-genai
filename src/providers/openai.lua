-- "https://api.openai.com/v1/chat/completions"

---@module "src.ai.openai"
local openai = {}

---Package system prompt
---@param system_prompt string
---@return table|nil
function openai.construct_system_message(system_prompt)
	local system_message = nil

	if system_prompt then
		system_message = { role = "system", content = system_prompt }
	end

	return system_message
end

---Package user prompt
---@param user_prompt string
---@return table
function openai.construct_user_message(user_prompt)
	local user_message = { role = "user", content = user_prompt }
	return user_message
end

---Package AI reply
---@param reply string
---@return table
function openai.construct_assistant_message(reply)
	local assistant_message = { role = "assistant", content = reply }
	return assistant_message
end

---Construct the request headers
---@param api_key string
---@return table headers
function openai.construct_headers(api_key)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	return headers
end

---Package AI settings
---@param opts table
---@return table
function openai.construct_payload(opts)
	local model = opts.model
	local messages = opts.history

	local payload = {
		model = model,
		messages = messages,
	}

	return payload
end

---Extract reply and tokens from client response
---@param response table
---@return string reply
---@return number input_tokens
---@return number output_tokens
function openai.extract_response_data(response)
	local reply = response.choices[1].message.content
	local input_tokens = response.usage.prompt_tokens
	local output_tokens = response.usage.completion_tokens

	return reply, input_tokens, output_tokens
end

return openai
