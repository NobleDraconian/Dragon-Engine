--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")

return {
	ModulePaths = {
		Shared = {
			ReplicatedStorage.DragonEngine.lib.Classes,
			ReplicatedStorage.DragonEngine.lib.Utils
		}
	},

	ControllerPaths = {
		Players.LocalPlayer.PlayerScripts.DragonEngine.Controllers
	}
}