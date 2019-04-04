--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ServerStorage=game:GetService("ServerStorage")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

return{
	["ServerClasses"]={},
	["SharedClasses"]={ReplicatedStorage.DragonEngine.Classes},

	["Utils"]={ReplicatedStorage.DragonEngine.Utils},

	["Services"]={ServerStorage.DragonEngine.Services},
	["ServiceExtensions"]={}
}