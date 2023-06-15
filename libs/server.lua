local json = require("json")

local file, websocket = require("file"), require("websocketClient")

local server = {}
server.__index = server

function server.new(client, id)
	
	local data = client:request({endpoint = {"servers/%s", id}})
	
	local tbl = setmetatable({
		client = client,
	},server)
	tbl:load(data)
	tbl.websocket = websocket.new(tbl)
	
	return tbl
end

function server:load(data)
	self.players = {
		max = data.players.max,
		count = data.players.count or 0,
		list = data.players.list or {}
	}
	self.port = data.port
	self.software = {
		id = data.software.id,
		name = data.software.name,
		version = data.software.version
	}
	self.name = data.name
	self.motd = data.motd
	self.status = data.status
	self.shared = data.shared
	self.address = data.address
	self.id = data.id
	
	self.account = {}
end

function server:request(options)
	if type(options.endpoint) == "table" then
		options.endpoint[1] = "servers/%s/" .. options.endpoint[1]
		table.insert(options.endpoint, 2, self.id)
	else
		options.endpoint = {"servers/%s/" .. options.endpoint, self.id}
	end
	return self.client:request(options)
end

function server:start(useOwnCredits)
	return self:request({
		method = "POST",
		endpoint = "start",
		body = json.stringify({useOwnCredits = not not useOwnCredits})
	})
end

function server:stop()
	return self:request({endpoint = "stop"})
end

function server:restart()
	return self:request({endpoint = "restart"})
end

function server:executeCommand(command) end --TODO

function server:getLogs()
	local data, err = self:request({endpoint = "logs"})
	if data then return data.content end
	return nil, err
end

function server:shareLogs() end --TODO

function server:getRAM() return self:getOption("ram") end
function server:setRAM(ram) return self:setOption("ram", ram) end
function server:getMOTD() return self:getOption("motd") end
function server:setMOTD(motd) return self:setOption("motd", motd) end
function server:getOption(option)
	local data, err = self:request({endpoint = {"options/%s", option}})
	if data then return data[option] end
	return nil, err
end
function server:setOption(option, value)
	return self:request({
		method = "POST",
		endpoint = {"options/%s", option},
		body = json.stringify({[option] = value})
	})
end

function server:getFile(path)
	
end

function server:scrapeWorldDownload()
	
end

function server:hasStatus(status)
	if type(status) == "number" then
		return self.status == status
	end
	
	for _,v in ipairs(status) do
		if self.status == v then
			return true
		end
	end
	return false
end

function server:subscribe() end --TODO

function server:unsubscribe() end --TODO

return server