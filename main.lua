local genai = require("genai")
local config = require("src.genai.config")
local utils = require("src.genai.utils")

local api_keys = config.api_keys
local colors = config.colors

local model, api_key, endpoint, path_to_system_prompt, settings = utils.get_provider_specifics(arg, api_keys)
local system_prompt = path_to_system_prompt and io.open(path_to_system_prompt, "r"):read("*all") or nil

local client = genai.new(api_key, endpoint)
local chat = client:chat(model, {
	system_prompt = system_prompt,
	settings = settings,
})

local function main()
	print(colors.info .. model .. colors.reset .. "\n")

	while true do
		local user_prompt = utils.ensure_user_input("> ")
		if user_prompt == ":m" then user_prompt = utils.get_multiline_input(":end") end
		if user_prompt == ":q" then break end
		print()

		local reply = chat:say(user_prompt) -- API call

		if not chat.settings.stream then
			print(colors.output .. reply .. colors.reset)
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
