local config = require("src.config")
local AI = require("src.ai")
local Chat = require("src.chat")

local api_keys = config.api_keys

local api_key = api_keys.anthropic_api_key
local endpoint = "https://api.anthropic.com/v1/messages"
local model = "claude-3-5-haiku-20241022"

-- local api_key = api_keys.openai_api_key
-- local endpoint = "https://api.openai.com/v1/chat/completions"
-- local model = "gpt-4o-mini"

local system_prompt = "Respond extremely briefly."

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt)

local function main()
	while true do
		local user_prompt = io.read()
		print()

		if user_prompt == ":q" then
			break
		end

		local reply = chat:say(user_prompt)

		print(reply)
		print()
	end
end

main()
