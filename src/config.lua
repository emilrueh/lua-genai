package.cpath = package.cpath .. ";./lib/lua/5.4/?.so"
package.path = package.path .. ";./share/lua/5.4/?.lua"

local https = require("https")
local json = require("cjson")

local api_keys = {
	anthropic_api_key = os.getenv("ANTHROPIC_API_KEY"),
	openai_api_key = os.getenv("OPENAI_API_KEY"),
}

return {
	https = https,
	json = json,
	api_keys = api_keys,
}
