--

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
end

--

local config = require("src.config")
local OpenAI = require("src.ai.openai")

local api_keys = config.api_keys

local client = OpenAI.new(api_keys.openai_api_key, "https://api.openai.com/v1/chat/completions")

---@param model string
local function conversation(model)
	local system_prompt = "Respond extremely briefly and concise."

	local messages = {}
	table.insert(messages, { role = "system", content = system_prompt })

	while true do
		local user_prompt = io.read()
		print()

		if user_prompt == ":q" then
			break
		end

		table.insert(messages, { role = "user", content = user_prompt })

		-- api call
		local reply, input_tokens, output_tokens = client:call(messages, model)

		table.insert(messages, { role = "assistant", content = reply })

		print(reply)
		print()
	end
end

local function main()
	conversation("gpt-4o-mini")
end

main()
