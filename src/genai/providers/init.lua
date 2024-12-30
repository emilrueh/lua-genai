---@module "src.genai.providers"
local providers = {}

providers.openai = require("src.genai.providers.openai")
providers.anthropic = require("src.genai.providers.anthropic")

return providers
