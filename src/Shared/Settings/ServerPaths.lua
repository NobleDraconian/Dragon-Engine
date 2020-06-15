--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ServerScriptService= game:GetService("ServerScriptService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

return{
	["ServerClasses"]={},
	["SharedClasses"]={ReplicatedStorage.DragonEngine.lib.Classes},

	["Utils"]={ReplicatedStorage.DragonEngine.lib.Utils},

	["Services"]={ServerScriptService.DragonEngine.Services},
	["ServiceExtensions"]={}
}