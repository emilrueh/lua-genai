-- TODO: this file can be a class

local config = require("config")

local https = config.https
local json = config.json

local function make_request(url, data, method, headers)
	local payload = {
		method = method,
		headers = headers,
		data = data,
	}

	local status_code, body, headers = https.request(url, payload)

	if status_code ~= 200 then
		error("Request error " .. tostring(status_code) .. " with " .. url)
	else
		return body
	end
end

local function call(user_prompt, system_prompt, model, api_key)
	assert(user_prompt, "A user prompt must be specified.")

	local endpoint = "https://api.openai.com/v1/chat/completions"

	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	local messages = {}
	table.insert(messages, { role = "user", content = user_prompt })
	table.insert(messages, { role = "system", content = system_prompt })

	local payload = json.encode({
		model = model,
		messages = messages,
	})

	local response = json.decode(make_request(endpoint, payload, "POST", headers))

	if response then
		local reply = response.choices[1].message.content
		local input_tokens = response.usage.prompt_tokens
		local output_tokens = response.usage.completion_tokens

		return reply, input_tokens, output_tokens
	end
end

return {
	call = call,
}
