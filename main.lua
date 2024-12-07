-- require("lldebugger").start()

local config = require("config")

local https = config.https
local json = config.json
local openai_api_key = config.openai_api_key

-- TODO: this needs to be a class

assert(openai_api_key, "OpenAI API key must be provided first.")

local openai_endpoint = "https://api.openai.com/v1/chat/completions"

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

local function call(prompt, model, api_key)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	}

	local messages = {}
	table.insert(messages, { role = "user", content = prompt })

	local payload = json.encode({
		model = model,
		messages = messages,
	})

	local response = json.decode(make_request(openai_endpoint, payload, "POST", headers))

	if response then
		local input_tokens = response.usage.prompt_tokens
		local output_tokens = response.usage.completion_tokens
		local reply = response.choices[1].message.content

		return reply -- TODO: this should be outside or not?
	end

	print()
end

local reply = call("What do you know about Bitburger?", "gpt-4o-mini", openai_api_key)

if reply then
	print(reply)
end
