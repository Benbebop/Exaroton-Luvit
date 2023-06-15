local stream = {}

function stream.new(websocket)
	
	return setmetatable({
		websocket = websocket,
	},stream)
	
end

return 