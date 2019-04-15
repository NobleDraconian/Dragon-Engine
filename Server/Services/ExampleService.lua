--[[
	Example Service

	This is an example service to display how a service is created and how it should be formatted.
--]]

local ExampleService={}

---------------------
-- Roblox Services --
---------------------


-------------
-- DEFINES --
-------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Init()

	self:DebugLog("[Example Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Start()
	self:DebugLog("[Example Service] Started!")

end

return ExampleService