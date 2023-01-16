--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ServerScriptService= game:GetService("ServerScriptService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Shared = {
			require(ReplicatedStorage.Packages["Roblox-LibModules"]),
		}
	},

	ServicePaths = {
		ServerScriptService.DragonEngine.Services
	}
}