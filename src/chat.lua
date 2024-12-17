---@class Chat
---@field _ai table
---@field history table
---@field system_prompt string|nil
---@field model string
---@field settings table
local Chat = {}
Chat.__index = Chat

function Chat.new(ai, model, system_prompt, settings)
	local self = setmetatable({}, Chat)

	self._ai = ai
	self.model = model
	self.settings = self._ai.provider.init_settings(settings or {})
	self.history = {}
	self.system_prompt = system_prompt

	-- insert system prompt into chat history at the start if provided
	local system_message = self._ai.provider.construct_system_message(self.system_prompt)
	if system_message then -- some providers use system message as top-level arg
		table.insert(self.history, system_message)
	end

	return self
end

---Wrap message construction
---@param user_prompt string
---@return string reply Full response text whether streamed or not
function Chat:say(user_prompt)
	table.insert(self.history, self._ai.provider.construct_user_message(user_prompt))
	local reply = self._ai:call(self)
	table.insert(self.history, self._ai.provider.construct_assistant_message(reply))
	return reply
end

return Chat
