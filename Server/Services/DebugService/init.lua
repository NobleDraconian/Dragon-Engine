--[[
	Debug Service

	This services handles various debugging tasks for the engine, such as displaying running services.
	It utilizes the Cmdr package.
--]]

local DebugService={}

---------------------
-- Roblox Services --
---------------------


-------------
-- DEFINES --
-------------
local Cmdr;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugService:Init()
	Cmdr=self.Utils.Cmdr
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(script.Commands)

	self:DebugLog("[Debug Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugService:Start()
	self:DebugLog("[Debug Service] Started!")

end

return DebugService