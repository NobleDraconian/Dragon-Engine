--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	ModulePaths = {
		Shared = {
			ReplicatedStorage.DragonEngine.lib.Classes,
			ReplicatedStorage.DragonEngine.lib.Utils
		}
	},

	ControllerPaths = {
		StarterPlayer.StarterPlayerScripts.DragonEngine.Controllers
	}
}