--[[
	Example Service

	This is an example service to display how a service is created and how it should be formatted.
--]]

local ExampleService={Client={}}
ExampleService.Client.Server=ExampleService

---------------------
-- Roblox Services --
---------------------
local HttpService=game:GetService("HttpService")

-------------
-- DEFINES --
-------------
local IncludeBraces=true --Whether or not to include curly braces

local GUID_Generated_ClientEvent; --Example service client event
local GUID_Generated_ServerEvent; --Example service server event

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GenerateGUID
-- @Description : This is an example service server method.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:GenerateGUID()
	local GUID=HttpService:GenerateGUID(IncludeBraces)

	GUID_Generated_ServerEvent:Fire(GUID)
	GUID_Generated_ClientEvent:FireAllClients(GUID)

	return GUID
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetGUID
-- @Description : This is an example service client endpoint method.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService.Client:GetGUID(Player)
	self.Server:Log("[Example Service] Getting GUID for player '"..Player.Name.."'.")

	return self.Server:GenerateGUID()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Init()
	GUID_Generated_ClientEvent=self:RegisterServiceClientEvent("GUIDGenerated")
	GUID_Generated_ServerEvent=self:RegisterServiceServerEvent("GUIDGenerated")

	self:DebugLog("[Example Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Start()
	self:DebugLog("[Example Service] Started!")

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the service is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Stop()
	
	self:Log("[Example Service] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Description : Called when the service is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Unload()

	self:Log("[Example Service] Unloaded!")
end

return ExampleService