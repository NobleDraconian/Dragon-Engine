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
local SERVICE_RENAMEINTERVAL=2 --The interval (in seconds) between service renames.
local Services={"Workspace","ReplicatedStorage","Players","Lighting","StarterPack","StarterPlayer"}

local ServiceRunning=true --Used to stop the service

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

	ServiceRunning=true
	
	--------------------------------------
	-- Renaming services at an interval --
	--------------------------------------
	while ServiceRunning do
		for Index=1,#Services do
			game:GetService(Services[Index]).Name=HttpService:GenerateGUID(false)
		end
		wait(SERVICE_RENAMEINTERVAL)
	end

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the service is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SecurityService:Stop()
	ServiceRunning=false

	for Index=1,#Services do
		game:GetService(Services[Index]).Name=Services[Index]
	end

	self:Log("[Security Service] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Descriptoin : Called when the service is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SecurityService:Unload()

	self:Log("[Security Service] Unloaded!")
end

return SecurityService