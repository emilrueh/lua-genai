-- require("lldebugger").start()

local config = require("src.config")
local utils = require("src.utils")

local anthropic_api_key = config.anthropic_api_key
local call = utils.call

local function conversation()
	local model = "claude-3-5-haiku-20241022"

	local system_prompt = "Respond very briefly."

	while true do
		local user_prompt = io.read()

		if user_prompt == ":q" then
			break
		end

		local reply, input_tokens, output_tokens = call(user_prompt, system_prompt, model, anthropic_api_key)
		print(reply)
	end
end

local function main()
	conversation()
end

main()
