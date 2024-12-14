# Lua Wrapper for Generative AI APIs

A developer-friendly Lua interface for working with multiple generative AI providers. This library abstracts away provider-specific payload structures and response parsing, allowing you to switch between models from OpenAI or Anthropic without rewriting your code.

## Providers Implemented

- **OpenAI**
- **Anthropic**

## Features

- Easily switch between AI chat model providers.
- Pass in prompts and get replies without the provider complexity.
- Easily integrate new models and adjust settings.

- For more granual control one could peel away a layer of abstraction and use the ai client directly without going through the chat interface.

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

local reply = chat:say("Give advice to the hero regarding their dangerous quest.")
print(reply)
```

See `main.lua` for a more detailed example.

## Status & Contributions

⚠️ This is a work in progress so any help is appreciated!

## Planned Features

- Error handling
- Toke cost tracking
- Gemini and open-source model integration

## Dependencies

- [lua-https](https://github.com/love2d/lua-https)
- [lua-cjson](https://github.com/openresty/lua-cjson)