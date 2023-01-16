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
			require(ReplicatedStorage.Packages["Roblox-LibModules"]),
		}
	},

	ControllerPaths = {
		StarterPlayer.StarterPlayerScripts.DragonEngine.Controllers
	}
}