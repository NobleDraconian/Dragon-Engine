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
	["ServerClasses"]={ServerStorage.DragonEngine.Classes,ServerStorage.GAME.Classes},
	["SharedClasses"]={ReplicatedStorage.DragonEngine.Classes,ReplicatedStorage.GAME.Classes},

	["Utils"]={ReplicatedStorage.DragonEngine.Utils,ReplicatedStorage.GAME.Utils},

	["Services"]={ServerStorage.DragonEngine.Services,ServerStorage.GAME.Services},
	["ServiceExtensions"]={ServerStorage.DragonEngine.ServiceExtensions,ServerStorage.GAME.ServiceExtensions}
}