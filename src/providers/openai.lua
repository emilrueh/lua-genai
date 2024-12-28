-- "https://api.openai.com/v1/chat/completions"

---@module "src.ai.openai"
local openai = {}

---Package system prompt
---@param system_prompt string
---@return table|nil
function openai.construct_system_message(system_prompt)
	local system_message = nil
	if system_prompt then system_message = { role = "system", content = system_prompt } end
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
---@param api_key string?
---@return table headers
function openai.construct_headers(api_key)
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. tostring(api_key),
	}
	return headers
end

---Abstract structuring json responses
---@param opts table {title: string, description: string, schema: table}
---@return table? response_format
local function construct_json_schema(opts)
	if opts then
		return {
			type = "json_schema",
			json_schema = {
				schema = {
					type = "object",
					properties = opts.schema,
				},
				name = opts.title,
				description = opts.description,
			},
		}
	end
end

---Package AI settings
---@param opts table
---@return table
function openai.construct_payload(opts)
	local do_stream = opts.settings.stream

	local payload = {
		model = opts.model,
		messages = opts.history,
		-- basic settings:
		stream = do_stream,
		stream_options = do_stream and { include_usage = true } or nil,
		-- TODO: add advanced settings
		response_format = opts.settings.response_format or construct_json_schema(opts.settings.json),
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

---Parse and process provider specific chunked responses structure for text and token usage
---@param obj table JSON from string chunk
function openai.handle_stream_data(obj, accumulator)
	-- errors:
	if obj.type == "error" and obj.error then
		local err_msg = string.format("%s: %s", obj.error.type, obj.error.message)
		error(err_msg)

	-- text:
	elseif
		obj.object == "chat.completion.chunk"
		and obj.choices
		and #obj.choices > 0
		and obj.choices[1].delta
		and obj.choices[1].delta.content
	then
		local text = obj.choices[1].delta.content
		-- print chunked response text onto the same line
		io.write(text)
		io.flush()
		-- accumulate response text
		accumulator.schema.choices[1].message.content = accumulator.schema.choices[1].message.content .. text

	-- input_tokens:
	elseif
		obj.object == "chat.completion.chunk"
		and obj.usage
		and type(obj.usage) == "table"
		and obj.usage.prompt_tokens
	then
		local input_tokens = obj.usage.prompt_tokens
		accumulator.schema.usage.prompt_tokens = accumulator.schema.usage.prompt_tokens + input_tokens

	-- output_tokens:
	elseif
		obj.object == "chat.completion.chunk"
		and obj.usage
		and type(obj.usage) == "table"
		and obj.usage.completion_tokens
	then
		local output_tokens = obj.usage.completion_tokens
		accumulator.schema.usage.completion_tokens = accumulator.schema.usage.completion_tokens + output_tokens
	end
end

---Handle various status codes returned by the API
---@param response table
---@param status_code number
function openai.handle_exceptions(response, status_code)
	if status_code >= 300 then
		local err_msg = string.format("%d %s: %s", status_code, response.error.type, response.error.message)
		error(err_msg)
	end
end

---Lua pattern match for provider specific stream chunk data json
---@type string
openai.stream_pattern = "^data:%s*(.*)"

---Data structure to accumulate stream for centralized parsing
---@type table
openai.response_schema = {
	choices = {
		{ message = { content = "" } },
	},
	usage = {
		prompt_tokens = 0,
		completion_tokens = 0,
	},
}

openai.pricing = {
	["gpt-4o-mini"] = {
		input = 0.15,
		output = 0.6,
	},
	["gpt-4o"] = {
		input = 5,
		output = 15,
	},
	["gpt-4o-2024-11-20"] = {
		input = 2.5,
		output = 15,
	},
}

return openai
