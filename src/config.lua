if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	require("lldebugger").start()
end

package.cpath = package.cpath .. ";./lib/lua/5.4/?.so"
package.path = package.path .. ";./share/lua/5.4/?.lua"

-- local https = require("https")
local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local api_keys = {
	anthropic_api_key = os.getenv("ANTHROPIC_API_KEY"),
	openai_api_key = os.getenv("OPENAI_API_KEY"),
	groq_api_key = os.getenv("GROQ_API_KEY"),
	gemini_api_key = os.getenv("GEMINI_API_KEY"),
}

return {
	cjson = cjson,
	https = https,
	ltn12 = ltn12,
	api_keys = api_keys,
}
