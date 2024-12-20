local config = require("src.config")

local https = config.https

---@module "src.utils"
local utils = {}

---Basic https request
---@param url string
---@param data string|nil
---@param method string|nil
---@param headers table|nil
---@return string|nil response_body
---@return table|nil response_headers
function utils.send_request(url, data, method, headers)
	assert(url, "A url to request must be specified.")

	local payload = {
		method = method,
		headers = headers,
		data = data,
	}

	local status_code, body, response_headers = https.request(url, payload)

	assert(status_code == 200 and response_headers, body)

	return body
end

return utils
