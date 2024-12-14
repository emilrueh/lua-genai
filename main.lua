--

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
end

--

local config = require("src.config")
local AI = require("src.ai")

local api_keys = config.api_keys

-- local client = AI.new(api_keys.openai_api_key, "https://api.openai.com/v1/chat/completions")
local client = AI.new(api_keys.anthropic_api_key, "https://api.anthropic.com/v1/messages")

---@param model string
local function conversation(model)
	local system_prompt = "Respond extremely briefly and concise."

	local messages = {}
	table.insert(messages, { role = "system", content = system_prompt })

	while true do
		local user_prompt = io.read()
		-- local user_prompt = "Hi, please say: 'Hello, world!'"
		print()

		if user_prompt == ":q" then
			break
		end

		table.insert(messages, { role = "user", content = user_prompt })

		local opts = {
			messages = messages,
			model = model,
		}

		-- api call
		local reply, input_tokens, output_tokens = client:call(opts)

		table.insert(messages, { role = "assistant", content = reply })

		print(reply)
		print()
		-- break
	end
end

local function main()
	-- conversation("gpt-4o-mini")
	conversation("claude-3-5-haiku-20241022")
end

main()
