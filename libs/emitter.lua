local emitter = {}

function emitter:emit(event, ...)
	if not self.callbacks[event] then return end
	
	for _,callback in ipairs(self.callbacks[event]) do
		coroutine.wrap(callback)(...)
	end
end

function emitter:on(event, callback)
	self.callbacks[event] = self.callbacks[event] or {}
	table.insert(self.callbacks[event], callback)
end

return emitter