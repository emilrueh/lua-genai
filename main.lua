local config = require("src.config")
local utils = require("src.utils")
local AI = require("src.ai")
local Chat = require("src.chat")

local api_keys = config.api_keys

-- local api_key = api_keys.anthropic_api_key
-- local endpoint = "https://api.anthropic.com/v1/messages"
-- local model = "claude-3-5-haiku-20241022"
-- local settings = {
-- 	stream = true,
-- }

local api_key = api_keys.openai_api_key
local endpoint = "https://api.openai.com/v1/chat/completions"
local model = "gpt-4o-mini"
local settings = {
	stream = true,
}

local system_prompt = "Respond extremely briefly."

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt, settings)

local function main()
	while true do
		local user_prompt = io.read()
		if user_prompt == ":q" then break end
		if user_prompt == ":m" then user_prompt = utils.get_multiline_input(":end") end
		print()

		local reply = chat:say(user_prompt) -- API call

		if not chat.settings.stream then
			print(reply)
		else
			print()
		end
		print()
		-- break
	end

	print(chat:get_cost() .. " usd")
end

main()
