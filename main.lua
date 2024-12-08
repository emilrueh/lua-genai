-- require("lldebugger").start()

local config = require("src.config")
local utils = require("src.utils")

local openai_api_key = config.openai_api_key
local call = utils.call

local function conversation()
	local model = "gpt-4o-mini"

	local system_prompt = "Respond very briefly."

	while true do
		local user_prompt = io.read()

		if user_prompt == ":q" then
			break
		end

		local reply, input_tokens, output_tokens = call(user_prompt, system_prompt, model, openai_api_key)
		print(reply)
	end
end

local function main()
	conversation()
end

main()
