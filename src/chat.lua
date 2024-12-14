---@class Chat
---@field _ai table
---@field history table
---@field system_prompt string|nil
---@field model string
local Chat = {}
Chat.__index = Chat

function Chat.new(ai, model, system_prompt)
	local self = setmetatable({}, Chat)

	self._ai = ai
	self.history = {}
	self.system_prompt = system_prompt

	self.model = model
	-- all other ai params go here (probs should get loaded depending on provider)

	-- insert system prompt into chat history at the start if provided
	local system_message = self._ai.provider.construct_system_message(self.system_prompt)
	if system_message then
		table.insert(self.history, system_message)
	end

	return self
end

---Wrap message construction
---@param user_prompt string
---@return string reply
function Chat:say(user_prompt)
	local user_message = self._ai.provider.construct_user_message(user_prompt)
	table.insert(self.history, user_message)
	local reply = self._ai:call(self)
	table.insert(self.history, self._ai.provider.construct_assistant_message(reply))

	return reply
end

return Chat
