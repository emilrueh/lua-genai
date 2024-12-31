---@module "genai.providers"
local providers = {}

providers.openai = require("genai.providers.openai")
providers.anthropic = require("genai.providers.anthropic")

return providers
