# Unified Lua Interface for Generative AI

A developer-friendly Lua interface for working with multiple generative AI providers, abstracting away provider-specific payload structures and response parsing so you can easily switch between various models and providers without rewriting any code.

## Providers

- [OpenAI](https://platform.openai.com/docs/overview)

- [Anthropic](https://docs.anthropic.com/en/home)

## Features

- Easily switch between AI chat model providers.
- Pass in prompts and get replies without the provider complexity.
- Easily integrate new models and adjust settings.
- Work directly with the `src.ai` client for more granular control.
- Abstraction for structured response JSON output
- Token usage tracking with cost calculation

## Usage

```lua
local AI = require("src.ai")
local Chat = require("src.chat")

local api_key = "<YOUR_API_KEY>"
local endpoint = "https://api.openai.com/v1/chat/completions"
local model = "gpt-4o-mini"
local system_prompt = "You are Torben, the king of a nation."
local settings = {
	stream = false,
	json = {
		title = "NPC",
		description = "Response schema of NPCs.",
		schema = {
			name = {
				type = "string",
			},
			response = {
				type = "string",
			},
		},
	},
}

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt, settings)

local reply = chat:say("Give three short words of advice to the hero.")
if not chat.settings.stream then print(reply) end
```

See `main.lua` for a more detailed example.

### Dependencies

- [lua-cjson](https://github.com/openresty/lua-cjson)

- [luasec](https://github.com/brunoos/luasec)

- [luasocket](https://github.com/lunarmodules/luasocket.git)

## Status

⚠️ This is a work in progress so any help is appreciated!

### Planned

- Advanced error handling
- Google Gemini integration
- Open-Source model integration
- Image models
- Audio models
- Video models
