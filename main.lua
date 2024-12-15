local config = require("src.config")
local AI = require("src.ai")
local Chat = require("src.chat")

local api_keys = config.api_keys

local api_key = api_keys.anthropic_api_key
local endpoint = "https://api.anthropic.com/v1/messages"
local model = "claude-3-5-haiku-20241022"
local settings = {
	stream = true,
}

-- local api_key = api_keys.openai_api_key
-- local endpoint = "https://api.openai.com/v1/chat/completions"
-- local model = "gpt-4o-mini"
-- local settings = {
-- 	stream = false,
-- }

local system_prompt = "Respond extremely briefly."
-- local system_prompt = "Respond always in very long sentences with lots of adjectives."

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt, settings)

local function main()
	while true do
		local user_prompt = io.read()
		print()
		-- local user_prompt = "Hello, tell me your name and who built you! My name is Emil. I was built by mother earth."

		if user_prompt == ":q" then
			break
		end

		local reply = chat:say(user_prompt)

		if reply then
			print(reply)
		else
			print()
		end

		print()

		-- break
	end
end

main()
