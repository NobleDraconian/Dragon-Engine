--[[
	Example Controller

	This is an example Controller to display how a Controller is created and how it should be formatted.
--]]

local ExampleController={}

---------------------
-- Roblox Services --
---------------------

-------------
-- DEFINES --
-------------
local Connections={} --Holds all event connections to allow for state cleanup if the controller is stopped.
local ControllerRunning=false --Used to determine when the controller is stopped
local Generation_Interval=3 --The interval (in seconds) at which to generate new GUIDs.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetGUID
-- @Description : This is an example controller method.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleController:GetGUID()
	self:Log("[Example Controller] Getting new GUID from server.")

	return self.Services.ExampleService:GetGUID()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleController:Init()

	self:DebugLog("[Example Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleController:Start()
	self:DebugLog("[Example Controller] Started!")
	ControllerRunning=true
	
	--------------------------------------------
	-- Listen for GUID creation on the server --
	--------------------------------------------
	local GUIDListener=self.Services.ExampleService.GUIDGenerated:connect(function(GUID)
		self:Log("[Example Controller] Example Service just generated the GUID '"..GUID.."'.")
	end)
	table.insert(ExampleController,GUIDListener)

	-------------------------------------------
	-- Generationg a new GUID at an interval --
	-------------------------------------------
	while ControllerRunning do
		wait(Generation_Interval)
		local GUID=self.Services.ExampleService:GetGUID()
		self:Log("[Example Controller] New GUID is '"..GUID.."'.")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the controller is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleController:Stop()

	ControllerRunning=false

	-------------------------------------------
	-- Disconnect and remove all connections --
	-------------------------------------------
	for Index=1,#Connections do
		Connections[1]:Disconnect()
		table.remove(Connections[Index])
	end

	self:Log("[Example Controller] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Description : Called when the controller is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleController:Unload()

	self:Log("[Example Controller] Unloaded!")
end


return ExampleController