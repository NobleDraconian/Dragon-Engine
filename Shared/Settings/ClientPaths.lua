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
	["SharedClasses"]={ReplicatedStorage.DragonEngine.Classes},

	["Utils"]={ReplicatedStorage.DragonEngine.Utils},

	["Controllers"]={Players.LocalPlayer.PlayerScripts.DragonEngine.Controllers},
	["ControllerExtensions"]={},
}