local utils = require("src.utils")

---@class Chat Accumulating chat history and usage
---@field client table
---@field model string
---@field settings table?
---@field usage table
---@field history table
---@field system_prompt string?
local Chat = {}
Chat.__index = Chat

---@param client table
---@param model string
---@param opts table? Containing **settings** and or **system_prompt**
function Chat.new(client, model, opts)
	local self = setmetatable({}, Chat)

	self.client = client
	self.model = model
	self.settings = opts and opts.settings or {}
	self.usage = { input = 0, output = 0 }
	self.history = {}
	self.system_prompt = opts and opts.system_prompt

	-- insert system prompt into chat history at the start if provided
	local system_message = self.client.provider.construct_system_message(self.system_prompt)
	if system_message then -- some providers use system message as top-level arg
		table.insert(self.history, system_message)
	end

	return self
end

---Wrap message construction
---@param user_prompt string
---@return string reply Full response text whether streamed or not
function Chat:say(user_prompt)
	table.insert(self.history, self.client.provider.construct_user_message(user_prompt))
	local reply, input_tokens, output_tokens = self.client:call(self)
	table.insert(self.history, self.client.provider.construct_assistant_message(reply))
	self.usage.input = self.usage.input + input_tokens
	self.usage.output = self.usage.output + output_tokens
	return reply
end

---Caculate model pricing from input and output tokens in USD
---@return number
function Chat:get_cost()
	return utils.calc_token_cost(self.model, self.usage, self.client.provider.pricing)
end

return Chat
