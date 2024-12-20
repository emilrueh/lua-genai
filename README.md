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

## Usage

```lua
local AI = require("src.ai")
local Chat = require("src.chat")

local api_key = "<YOUR_API_KEY>"
local endpoint = "https://api.openai.com/v1/chat/completions"
local model = "gpt-4o-mini"
local system_prompt = "You are the king of a nation."

local ai = AI.new(api_key, endpoint)
local chat = Chat.new(ai, model, system_prompt)

local reply = chat:say("Give three short words of advice to the hero.")
print(reply)
```

See `main.lua` for a more detailed example.

### Dependencies

- [lua-https](https://github.com/love2d/lua-https)

- [lua-cjson](https://github.com/openresty/lua-cjson)

## Status

⚠️ This is a work in progress so any help is appreciated!

### Future

1. Streaming responses
2. Error handling
3. Token cost tracking
4. Gemini and open-source model integration
5. Image models
6. Audio models