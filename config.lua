package.cpath = package.cpath .. ";./lib/lua/5.4/?.so"
package.path = package.path .. ";./share/lua/5.4/?.lua"

local https = require("https")
local json = require("cjson")

-- local dotenv = require("lua-dotenv")
-- dotenv.load_dotenv()
-- local openai_api_key = dotenv["OPENAI_API_KEY"]

local openai_api_key = os.getenv("OPENAI_API_KEY")

return {
	https = https,
	json = json,
	openai_api_key = openai_api_key,
}
