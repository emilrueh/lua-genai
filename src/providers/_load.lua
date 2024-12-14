local providers = {}

local openai = require("src.providers.openai")
local anthropic = require("src.providers.anthropic")

providers.openai = openai
providers.anthropic = anthropic

return providers
