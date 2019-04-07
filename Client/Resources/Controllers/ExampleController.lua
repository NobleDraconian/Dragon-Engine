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

end

return ExampleController