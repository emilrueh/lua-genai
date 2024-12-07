-- TODO: this file can be a class

local config = require("config")

local https = config.https
local json = config.json

local function make_request(url, data, method, headers)
	local response = nil

	local payload = {
		method = method,
		headers = headers,
		data = data,
	}

	local code, body, headers = https.request(url, payload)

	if code ~= 200 then
		print("Request error " .. tostring(code) .. " with " .. url)
	else
		response = body
	end

	return response
end

local function call(user_prompt, system_prompt, model, api_key)
	assert(user_prompt, "A user prompt must be specified.")

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

	local response = json.decode(make_request("https://api.openai.com/v1/chat/completions", payload, "POST", headers))

	if response then
		local input_tokens = response.usage.prompt_tokens
		local output_tokens = response.usage.completion_tokens
		print(input_tokens, output_tokens, "\n")

		local reply = response.choices[1].message.content
		return reply -- TODO: this should be outside or not?
	end

	print()
end

return { call = call }
