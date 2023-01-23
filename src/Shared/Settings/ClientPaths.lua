--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------

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