local config = require("src.config")
local AI = require("src.ai")

local api_keys = config.api_keys

local structured_response_obj = {
	title = "NPC",
	description = "Response schema of NPCs.",
	schema = {
		name = {
			type = "string",
		},
		response = {
			type = "string",
		},
	},
}

-- local api_key = api_keys.anthropic_api_key
-- local endpoint = "https://api.anthropic.com/v1/messages"
-- local model = "claude-3-5-sonnet-20241022"

local api_key = api_keys.openai_api_key
local endpoint = "https://api.openai.com/v1/chat/completions"
local model = "gpt-4o-mini"

local function main()
	local ai = AI.new(api_key, endpoint)
	local chat = ai:chat(model, {
		system_prompt = "Respond extremely briefly.",
		settings = {
			stream = false,
			json = structured_response_obj,
		},
	})

	while true do
		local user_prompt = "You are King Torben giving advice."
		print(user_prompt)
		-- local user_prompt = io.read()
		-- if user_prompt == ":q" then break end
		print()

		local reply = chat:say(user_prompt) -- API call

		if not chat.settings.stream then
			print(reply)
		else
			print()
		end
		print()
		break
	end

	local usd_token_cost = chat:get_cost()
	print(usd_token_cost .. "usd")
end

main()
