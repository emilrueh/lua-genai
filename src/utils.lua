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
function utils.make_request(url, data, method, headers)
	assert(url, "A url to request must be specified.")

	local payload = {
		method = method,
		headers = headers,
		data = data,
	}

	local status_code, body, response_headers = https.request(url, payload)

	if status_code ~= 200 then
		error("Request error " .. tostring(status_code) .. " with " .. url)
	else
		return body
	end
end

return utils
