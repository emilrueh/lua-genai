-- "https://api.anthropic.com/v1/messages"

---@module "genai.providers.anthropic"
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
---@param api_key string?
---@return table headers
function anthropic.construct_headers(api_key)
	local headers = {
		["x-api-key"] = tostring(api_key),
		["anthropic-version"] = "2023-06-01", -- https://docs.anthropic.com/en/api/versioning
		["content-type"] = "application/json",
	}

	return headers
end

---Abstract structuring json responses
---@param opts table {title: string, description: string, schema: table}
---@return table? response_format
local function construct_json_schema(opts)
	if opts then
		return {
			{
				name = opts.title,
				description = opts.description,
				input_schema = {
					type = "object",
					properties = opts.schema,
				},
			},
		}
	end
end

---Packaging AI settings
---@param opts table
---@return table
function anthropic.construct_payload(opts)
	local payload = {
		model = opts.model,
		messages = opts.history,
		system = opts.system_prompt,
		-- basic settings:
		max_tokens = opts.settings.max_tokens or 1024, -- required
		temperature = opts.settings.temperature,
		stream = opts.settings.stream and true or nil,
		-- advanced settings:
		top_k = opts.settings.top_k,
		top_p = opts.settings.top_p,
		metadata = opts.settings.metadata, -- only user_id
		stop_sequence = opts.settings.stop_sequence, -- broken
		tools = opts.settings.tools or construct_json_schema(opts.settings.json), -- allow json abstraction
		tool_choice = opts.settings.json and { type = "any" } or opts.settings.tool_choice, -- if json force any
	}

	return payload
end

---Extracting reply and tokens from client response
---@param response table
---@return string reply
---@return number input_tokens
---@return number output_tokens
function anthropic.extract_response_data(response)
	local reply = response.content[1].text or response.content[1].input -- plain text or tool use
	local input_tokens = response.usage.input_tokens
	local output_tokens = response.usage.output_tokens
	return reply, input_tokens, output_tokens
end

---Closure processing and accumulating streamed response chunk objects
---@param accumulator table Schema storing full streamed response
---@param processor function Display of streamed text chunks
---@return function handler
function anthropic.create_stream_handler(accumulator, processor)
	---Parse and process provider specific chunked responses structure for text and token usage
	---@param obj table JSON from string chunk
	return function(obj)
		-- errors:
		if obj.type == "error" and obj.error then
			local err_msg = string.format("%s: %s", obj.error.type, obj.error.message)
			error(err_msg)

		-- text:
		elseif obj.type == "content_block_delta" and obj.delta then
			local text = obj.delta.text or obj.delta.partial_json
			accumulator.schema.content[1].text = accumulator.schema.content[1].text .. text
			processor(text)

		-- input_tokens:
		elseif obj.type == "message_start" and obj.message and obj.message.usage and obj.message.usage.input_tokens then
			local input_tokens = obj.message.usage.input_tokens
			accumulator.schema.usage.input_tokens = accumulator.schema.usage.input_tokens + input_tokens

		-- output_tokens:
		elseif obj.type == "message_delta" and obj.usage and obj.usage.output_tokens then
			local output_tokens = obj.usage.output_tokens
			accumulator.schema.usage.output_tokens = accumulator.schema.usage.output_tokens + output_tokens
		end
	end
end

---Handle various status codes returned by the API
---@param response table
---@param status_code number
function anthropic.handle_exceptions(response, status_code)
	if status_code >= 300 then
		local err_msg = string.format("%d %s: %s", status_code or "", response.error.type, response.error.message)
		error(err_msg)
	end
end

---Lua pattern match for provider specific stream chunk data json
---@type string
anthropic.stream_pattern = "^data:%s*(.*)"

---Data structure to accumulate stream for centralized parsing
---@type table
anthropic.response_schema = {
	content = { { text = "" } },
	usage = {
		input_tokens = 0,
		output_tokens = 0,
	},
}

---All model input and output pricing per million tokens
---@type table
anthropic.pricing = {
	["claude-3-5-haiku-20241022"] = {
		input = 1,
		output = 5,
	},
	["claude-3-5-sonnet-20241022"] = {
		input = 3,
		output = 15,
	},
}

return anthropic
