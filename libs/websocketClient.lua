local socket, timer, json, miniz = require("coro-websocket"), require("timer"), require("json"), require('miniz')

local emitter = require("emitter")

local websocketClient = {}
websocketClient.__index = websocketClient

function websocketClient.new(server)
	
	return setmetatable({server = server},socketClient)
	
end

websocketClient.emit = emitter.emit
websocketClient.on = emitter.on

function websocketClient:connect()
	self.websocket, self.read, self.write = socket.connect({
		host = "api.exaroton.com",
		pathname = ("/%s/servers/%s/websocket"):format("v1", self.server.id),
		headers = {{"Authorization", self.server.client.apiToken}},
		
		tls = true
	})
	
	coroutine.wrap(function()
		for message in self.read do
			self:handleIncoming(message)
		end
	end)()
	
	self:onOpen()
end

function websocketClient:disconnect()
	
end

function websocketClient:handleIncoming(message) -- stole this from discordia shhhhh
	if message.opcode == 1 then
		self:onMessage(message.payload)
	elseif message.opcode == 8 then
		self:onClose()
	else
		self:onError("unexpected opcode???: " .. message.opcode)
	end
end

function websocketClient:onOpen()
	self.connected = true
	self:emit("open")
end

function websocketClient:onClose()
	self:emit("close")
	self.ready = false
	if self.autoReconnect and this.shouldConnect and self.reconnectTimeout then
		self.reconnectInterval = timer.setInterval(self.reconnectTimeout, websocketClient.connect, self)
	else
		self.connected = false
	end
end

function websocketClient:onError(err)
	self:emit("error", err)
end

function websocketClient:onMessage(message)
	message = json.parse(message)
	
	if message.type == "keep-alive" then
		return
	elseif message.type == "ready" then
		self.ready = true
		self:emit("ready")
		return
	elseif message.type == "connected" then
		self.serverConnected = true
		self:emit('connected')
		return
	elseif message.type == "disconnected" then
		self.serverConnected = false
		self:emit('disconnected')
		if self.autoReconnect and self.reconnectTimeout then
			timer.setTimeout(self.reconnectTimeout, callback, self) --TODO
		end
		return
	elseif message.type == "status" then
		if message.stream == "status" then
			self.server:load(message.data)
			self:emit("status", self.server)
			return
		end
	end
	
	local stream = self.streams[message.stream]
	if stream then
		stream:onMessage(message)
	else
		self:onError("stream does not exist: " .. message.stream)
	end
end

function websocketClient:getStream()
	
end

--TODO

return websocketClient