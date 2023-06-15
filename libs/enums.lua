local enums = {}

enums.serverStatus = {
	offline = 0,
	online = 1,
	starting = 2,
	stopping = 3,
	restarting = 4,
	saving = 5,
	loading = 6,
	crashed = 7,
	pending = 8,
	preparing = 10
}

return enums