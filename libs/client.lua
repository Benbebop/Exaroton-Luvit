local http, path, querystring, json = require("coro-http"), require("path"), require("querystring"), require("json")

local server = require("server")

local HOST = ("https://api.exaroton.com/%s/"):format("v1")

local client = {}
client.__index = client

function client.new(self, token)
	token = token or self
	
	return setmetatable({
		apiToken = token,
		servers = {}
	},client)
	
end

function client:setAPIToken(token)
	self.apiToken = token
	return self
end

function client:request(options)
	local url
	if type(options.endpoint) == "table" then
		url = HOST .. string.format(unpack(options.endpoint))
	else
		url = HOST .. options.endpoint
	end
	
	if options.query then url = url .. "?" .. querystring.stringify(options.query) end
	
	local req = {{"Authorization", self.apiToken}}
	if options.contentType then table.insert(req, {"Content-Type", options.contentType}) end
	
	local res, body = http.request(options.method or "GET", url, req, options.body)
	
	if res.code < 200 or res.code > 299 then return nil, body end
	
	body = json.parse(body)
	
	if body.success then return body.data end
	
	return nil, body.error
end

--[[function client:getServers()
	
	local servers = self:request({endpoint = "servers"})
	
end]]

function client:getAccount()
	
end

function client:getServer(id)
	if self.servers[id] then return self.servers[id] end
	
	self.servers[id] = server.new(self, id)
	return self.servers[id]
end

return client