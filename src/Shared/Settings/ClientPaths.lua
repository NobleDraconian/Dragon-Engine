--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Shared = {
			require(script.Parent.Parent.Parent.Parent["Roblox-LibModules"]),
		}
	},

	ControllerPaths = {
		script.Parent.Parent.Parent.Client.Controllers
	}
}