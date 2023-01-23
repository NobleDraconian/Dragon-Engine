--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

return {
	ModulePaths = {
		Shared = {
			require(script.Parent.Parent.Parent.Parent["Roblox-LibModules"]),
		}
	},

	ServicePaths = {
		script.Parent.Parent.Parent.Server.Services
	}
}