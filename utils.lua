-- TODO: this file can be a class

local config = require("config")

local https = config.https
local json = config.json

---@module "utils"
local utils = {}

---Basic https request
---@param url string
---@param data string|nil
---@param method string|nil
---@param headers table|nil
---@return string|nil response_body
---@return table|nil response_headers
function utils.make_request(url, data, method, headers)
	assert(url, "A url to request must be specified.")

	local payload = {
		method = method,
		headers = headers,
		data = data,
	}

	local status_code, response_body, response_headers = https.request(url, payload)

	if status_code ~= 200 then
		error("Request error " .. tostring(status_code) .. " with " .. url)
	else
		return response_body, response_headers
	end
end

---OpenAI API call to v1/chat/completions endpoint
---@param user_prompt string
---@param system_prompt string
---@param model string
---@param api_key string
---@return string|nil reply
---@return integer|nil input_tokens
---@return integer|nil output_tokens
function utils.call(user_prompt, system_prompt, model, api_key)
	assert(user_prompt, "A user prompt must be specified.")

	local endpoint = "https://api.openai.com/v1/chat/completions"

	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	local messages = {}
	-- first system_prompt
	if system_prompt then
		table.insert(messages, { role = "system", content = system_prompt })
	end
	-- then user_prompt
	table.insert(messages, { role = "user", content = user_prompt })

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

return utils
