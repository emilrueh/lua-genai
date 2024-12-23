local config = require("src.config")
local utils = require("src.utils")
local AI = require("src.ai")
local Chat = require("src.chat")

local api_keys = config.api_keys
local colors = config.colors

local provider = arg[1]
local model = arg[2]
local api_key = nil
local endpoint = nil
local settings = nil

if provider == "openai" then
	api_key = api_keys.openai_api_key
	endpoint = "https://api.openai.com/v1/chat/completions"
	model = model or "gpt-4o-mini"
	settings = {
		stream = true,
	}
elseif provider == "anthropic" then
	api_key = api_keys.anthropic_api_key
	endpoint = "https://api.anthropic.com/v1/messages"
	model = model or "claude-3-5-haiku-20241022"
	settings = {
		stream = true,
	}
else
	error("Provider " .. provider .. " is not supported!")
end

local system_prompt = "Respond extremely briefly."

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt, settings)

local function main()
	print(colors.info .. model .. colors.reset .. "\n")

	while true do
		io.write("> ")
		io.flush()

		local user_prompt = io.read()
		if user_prompt == ":q" then break end
		if user_prompt == ":m" then user_prompt = utils.get_multiline_input(":end") end
		print()

		local reply = chat:say(colors.output .. user_prompt .. colors.reset) -- API call

		if not chat.settings.stream then
			print(reply)
		else
			print()
		end
		print()
		-- break
	end

	local usd_token_cost = chat:get_cost()
	if usd_token_cost >= 0.0001 then
		print("\n" .. colors.info .. string.format("%.4f", usd_token_cost) .. " usd" .. colors.reset)
	end
end

main()
