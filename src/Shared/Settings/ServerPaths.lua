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
			ReplicatedStorage.DragonEngine.lib.Classes,
			ReplicatedStorage.DragonEngine.lib.Utils
		}
	},

	ServicePaths = {
		ServerScriptService.DragonEngine.Services
	}
}