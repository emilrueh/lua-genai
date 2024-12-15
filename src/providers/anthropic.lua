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

function anthropic.init_settings(settings)
	settings = {
		max_tokens = settings.max_tokens or 1024,
		stream = settings.stream or false,
	}

	return settings
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
	local payload = {
		model = opts.model,
		system = opts.system_prompt,
		messages = opts.history,
		max_tokens = opts.settings.max_tokens,
		stream = opts.settings.stream,
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

---Parse and process Anthropic specific chunked responses structure
---@param obj table JSON from string chunk
---@param accumulator table Schema to collect chunked data
local function handle_stream_data(obj, accumulator)
	-- TODO: extract input and output tokens

	if obj.type == "content_block_delta" and obj.delta and obj.delta.text then
		local text = obj.delta.text

		-- print chunked response text onto the same line
		io.write(text)
		io.flush()

		-- accumulate response text
		table.insert(accumulator.text, text)
	end
end

---@type function Anthropic specific streamed data parsing and processing logic
anthropic.callback = utils.create_sse_callback("^data:%s*(.*)", handle_stream_data)

---Collect chunked data accumulated by callback
---@return string reply Full response text accumulated from chunked responses
---@return number input_tokens
---@return number output_tokens
function anthropic.assemble_stream_data()
	local reply = table.concat(utils.accumulator.text)
	local input_tokens = utils.accumulator.input_tokens
	local output_tokens = utils.accumulator.output_tokens

	utils.accumulator = utils.init_accumulator() -- reset

	return reply, input_tokens, output_tokens
end

return anthropic
