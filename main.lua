-- require("lldebugger").start()

local utils = require("utils")
local config = require("config")

local call = utils.call
local openai_api_key = config.openai_api_key

--

local model = "gpt-4o-mini"

local system_prompt = "You respond only very briefly."
local user_prompt = "What do you know about Bitburger?"

local reply = call(user_prompt, system_prompt, model, openai_api_key)

if reply then
	print(reply)
end

-- TODO: make plan on when to call a first version done and post about it
-- 		 e.g. once streaming and cost tracking are implemented to be able to start löve
