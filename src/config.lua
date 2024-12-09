package.cpath = package.cpath .. ";./lib/lua/5.4/?.so"
package.path = package.path .. ";./share/lua/5.4/?.lua"

local https = require("https")
local json = require("cjson")

local anthropic_api_key = os.getenv("ANTHROPIC_API_KEY")

assert(anthropic_api_key, "Anthropic API key must be provided first.")

return {
	https = https,
	json = json,
	anthropic_api_key = anthropic_api_key,
}
