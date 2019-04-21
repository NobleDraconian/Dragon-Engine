--[[
	Debug Controller

	This controller handles various debugging tasks for the engine, such as displaying running controllers.
	It utilizes the Cmdr package.
--]]

local DebugController={}

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

-------------
-- DEFINES --
-------------
local Cmdr;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugController:Init()
	Cmdr=require(ReplicatedStorage:WaitForChild("CmdrClient"))
	Cmdr:SetPlaceName(game.Name)
	Cmdr:SetActivationKeys({ Enum.KeyCode.RightControl })

	self:DebugLog("[Debug Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugController:Start()
	self:DebugLog("[Debug Controller] Started!")

end

return DebugController