-- require("lldebugger").start()

local utils = require("utils")
local config = require("config")

local call = utils.call
local openai_api_key = config.openai_api_key

-- TODO: make plan on when to call a first version done and post about it
-- - loading prompts from file or cloud
-- - basic logging instead of print
-- - once streaming and cost tracking are implemented to be able to start löve gamedev
-- - when published as lua rock

local function main()
	local model = "gpt-4o-mini"

	local system_prompt = "You respond only very briefly."
	local user_prompt = "What do you know about Bitburger?"

	local reply, input_tokens, output_tokens = call(user_prompt, system_prompt, model, openai_api_key)

	if reply then
		print(reply)
	end
end

main()
