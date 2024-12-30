---@module "src.providers"
local providers = {}

providers.openai = require("src.providers.openai")
providers.anthropic = require("src.providers.anthropic")

return providers
