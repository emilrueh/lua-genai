# Unified Lua Interface for Generative AI

A developer-friendly Lua interface for working with multiple generative AI providers, abstracting away provider-specific payload structures and response parsing so you can easily switch between various models and providers without rewriting any code.

## Providers

> ⚠️ This is a work in progress so any help is highly appreciated!

- [OpenAI](https://platform.openai.com/docs/overview)

- [Anthropic](https://docs.anthropic.com/en/home)

## Features

- Easily switch between AI chat model providers
- Pass in prompts and get replies without the provider complexity
- Easily integrate new models and adjust settings
- Work directly with the `src.ai` client for more granular control
- Abstraction for structured response JSON output
- Token usage tracking with cost calculation

## Usage

```lua
local AI = require("src.ai")

local client = AI.new("<YOUR_API_KEY>", "https://api.openai.com/v1/chat/completions")
```

### Minimal

```lua
local chat = client:chat("gpt-4o-mini")
print(chat:say("Hello, world!"))
```

### Streaming

```lua
local chat = client:chat("gpt-4o-mini", { settings = { stream = true } })
chat:say("Hello, world!")
```

### JSON

```lua
local npc_schema = {
	name = { type = "string" },
	class = { type = "string" },
	level = { type = "integer" },
}

local json_object = {
	title = "NPC",
	description = "A non-player character's attributes.",
	schema = npc_schema,
}

local chat = client:chat("gpt-4o-mini", { settings = { json = json_object } })
print(chat:say("Create a powerful wizard called Torben."))
```

See `main.lua` for a more detailed example.

### Dependencies

- [lua-cjson](https://github.com/openresty/lua-cjson)

- [luasec](https://github.com/brunoos/luasec)

## Roadmap

1. Advanced error handling
2. Google Gemini integration
3. Audio models
4. Image models
5. Open-Source model integration
6. Video models
