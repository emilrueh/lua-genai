local genai = require("genai")

local api_key = "<YOUR_API_KEY>"
local endpoint = "https://api.anthropic.com/v1/messages"
local model = "claude-3-5-sonnet-20241022"

local client = genai.new(api_key, endpoint)

local response_schema = {
	name = {
		type = "string",
	},
	response = {
		type = "string",
	},
}

local chat = client:chat(model, {
	system_prompt = "Respond extremely briefly.",
	settings = {
		json = {
			title = "NPC",
			description = "Response schema of NPCs.",
			schema = response_schema,
		},
		stream = function(text)
			io.write(text)
			io.flush()
		end,
	},
})

while true do
	local user_prompt = "You are King Torben giving advice."
	print(user_prompt)
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
