-- "https://api.openai.com/v1/chat/completions"

---@module "src.ai.openai"
local openai = {}

---Constructing the request headers
---@param api_key string
---@return table headers
function openai.construct_headers(api_key)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	return headers
end

function openai.construct_payload(opts)
	local model = opts.model
	local messages = opts.messages

	local payload = {
		model = model,
		messages = messages,
	}

	return payload
end

---Extracting reply and tokens from client response
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
