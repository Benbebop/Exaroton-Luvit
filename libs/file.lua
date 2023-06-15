local file = {}
file.__index = file

function file.new(server,path)
	
	local data, err = server:request({endpoint = {"files/info/%s", path}})
	
	return setmetatable({
		path = path,
		name = data.name,
		size = data.size,
		
		children = nil, --TODO
		
		isTextFile = data.isTextFile,
		isConfigFile = data.isConfigFile,
		isDirectory = data.isDirectory,
		isLog = data.isLog,
		isReadable = data.isReadable,
		isWritable = data.isWritable
	},file)
	
end

--TODO

function file:getContent()
	return server:request({endpoint = {"files/data/%s", self.path}})
end

function file:download(output)
	
end

function file:putContent(content)
	
end

function file:upload(file)
	
end

return file