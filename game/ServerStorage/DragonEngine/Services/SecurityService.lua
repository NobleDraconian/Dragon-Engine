--[[
	Security Service

	Runs various tasks to help stop exploiters.
--]]

local SecurityService={}

---------------------
-- Roblox Services --
---------------------
local HttpService=game:GetService("HttpService")

-------------
-- DEFINES --
-------------
local SERVICE_RENAMEINTERVAL=5 --The interval (in seconds) between service renames.

local Services={"Workspace","ReplicatedStorage","Players","Lighting"}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SecurityService:Init()

	self:DebugLog("[Security Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SecurityService:Start()
	self:DebugLog("[Security Service] Started!")

	--------------------------------------
	-- Renaming services at an interval --
	--------------------------------------
	while wait(SERVICE_RENAMEINTERVAL) do
		for Index=1,#Services do
			game[Services[Index]].Name=HttpService:GenerateGUID(false)
		end
	end

end

return SecurityService