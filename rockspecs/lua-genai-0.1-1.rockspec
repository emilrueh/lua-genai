package = "lua-genai"
version = "0.1-1"

source = {
	url = "https://github.com/emilrueh/lua-genai.git",
	tag = "v0.1",
}

description = {
	summary = "Generative AI SDK",
	detailed = "A developer-friendly interface for working with multiple generative AI providers, abstracting away provider-specific payload structures and response parsing so you can easily switch between various models and providers like OpenAI, Anthropic, Google Gemini, etc. without rewriting any code.",
	homepage = "https://github.com/emilrueh/lua-genai",
	license = "Zlib",
}

dependencies = {
	"lua >= 5.1",
	"lua-cjson",
	"luasec",
}

build = {
	type = "builtin",
	-- copy_directories = { "docs", "examples" },
	modules = {
		["genai"] = "src/genai/init.lua",
		["genai.genai"] = "src/genai/genai.lua",
		["genai.utils"] = "src/genai/utils.lua",
		["genai.features"] = "src/genai/features/init.lua",
		["genai.features.chat"] = "src/genai/features/chat.lua",
		["genai.providers"] = "src/genai/providers/init.lua",
		["genai.providers.anthropic"] = "src/genai/providers/anthropic.lua",
		["genai.providers.openai"] = "src/genai/providers/openai.lua",
	},
}
