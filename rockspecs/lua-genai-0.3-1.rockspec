package = "lua-genai"
version = "0.3-1"
source = {
   url = "https://github.com/emilrueh/lua-genai/archive/refs/tags/v0.3.tar.gz"
}
description = {
   summary = "Generative AI SDK",
   detailed = "Interface for generative AI providers like OpenAI, Anthropic, Google Gemini, DeepSeek, etc. abstracting away provider-specific payload structures and response parsing to simplify switching models with optional async requests.",
   homepage = "https://github.com/emilrueh/lua-genai",
   license = "Zlib"
}
dependencies = {
   "lua >= 5.1",
   "lua-cjson",
   "luasec"
}
build = {
   type = "builtin",
   modules = {
      genai = "src/genai/init.lua",
      ["genai.features"] = "src/genai/features/init.lua",
      ["genai.features.chat"] = "src/genai/features/chat.lua",
      ["genai.genai"] = "src/genai/genai.lua",
      ["genai.providers"] = "src/genai/providers/init.lua",
      ["genai.providers.anthropic"] = "src/genai/providers/anthropic.lua",
      ["genai.providers.openai"] = "src/genai/providers/openai.lua",
      ["genai.utils"] = "src/genai/utils.lua"
   }
}
