if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then require("lldebugger").start() end

package.cpath = package.cpath .. ";./lib/lua/5.4/?.so"
package.path = package.path .. ";./share/lua/5.4/?.lua"

local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local api_keys = {
	anthropic_api_key = os.getenv("ANTHROPIC_API_KEY"),
	openai_api_key = os.getenv("OPENAI_API_KEY"),
	groq_api_key = os.getenv("GROQ_API_KEY"),
	gemini_api_key = os.getenv("GEMINI_API_KEY"),
}

local colors = { -- ANSI colors
	output = "\27[36m", -- cyan
	info = "\27[34m", -- blue
	reset = "\27[0m", -- reset
}

return {
	cjson = cjson,
	https = https,
	ltn12 = ltn12,
	api_keys = api_keys,
	colors = colors,
}
