--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")

return{
	["SharedClasses"]={ReplicatedStorage.DragonEngine.Classes,ReplicatedStorage.GAME.Classes},

	["Utils"]={ReplicatedStorage.DragonEngine.Utils,ReplicatedStorage.GAME.Utils},

	["Controllers"]={Players.LocalPlayer.PlayerScripts.DragonEngine.Controllers,Players.LocalPlayer.PlayerScripts:WaitForChild("GAME").Controllers},
	["ControllerExtensions"]={Players.LocalPlayer.PlayerScripts.DragonEngine.ControllerExtensions},
}