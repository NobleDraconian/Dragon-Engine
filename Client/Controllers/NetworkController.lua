--[[
	Network Controller
	
	Handles things such as latency checking, pinging clients, etc.
--]]

local NetworkController={}

---------------------
-- ROBLOX Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")

-------------
-- DEFINES --
-------------
local MAX_LATENCY=5 --The max time a ping will wait until auto failing.

local ClientPing;  --Used to respond to the server
local ServerPing;  --Used to ping the server

local Connections={} --Holds any event listener connections in case the controller is stopped/unloaded.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PingServer
-- @Description : Pings the server and returns the ping status (success/fail) and the time in milliseconds a response took.
-- @Params : Number "TimeOut" - The amount of time to wait for a response before failing the ping.
-- @Returns : bool "PingSuccess" - Is true if the server replied to the ping.
--            float "Latency" - The time (in ms) it took the server to respond to the ping.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkController:PingServer(TimeOut)
	local StartTick=tick()
	local EndTick=0
	local PingReturned=false
	local PingSuccess=false
	local PingID=HttpService:GenerateGUID(false)
	local Latency=TimeOut or MAX_LATENCY
	
	local PingResponse;
	PingResponse=ServerPing.OnClientEvent:connect(function(ResponseID)
		if ResponseID==PingID then
			PingResponse:Disconnect()
			EndTick=tick()
			self:DebugLog("Ping "..PingID.." RESPONSE")
			PingReturned=true
			PingSuccess=true
		end
	end)
	
	self:DebugLog("Ping "..PingID.." SEND")
	ServerPing:FireServer(PingID)
	
	while not PingReturned do
		RunService.Heartbeat:wait()
		if tick()-StartTick>Latency then --Ping timed out
			self:Log("Ping "..PingID.." TIMEOUT","Warning")
			PingResponse:Disconnect()
			break 
		end
	end
	
	return PingSuccess,EndTick-StartTick
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkController:Init()
	ClientPing=ReplicatedStorage.DragonEngine.Network:WaitForChild("NetworkService"):WaitForChild("ClientPing")
	ServerPing=ReplicatedStorage.DragonEngine.Network:WaitForChild("NetworkService"):WaitForChild("ServerPing")
	
	self:DebugLog("[Network Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkController:Start()
	self:DebugLog("[Network Controller] Started!")
	
	-----------------------------------------
	-- Responding to pings from the server --
	-----------------------------------------
	local PingListener=ClientPing.OnClientEvent:connect(function(PingID)
		self:DebugLog("CLIENT : RESPONDING TO PING "..PingID)
		ClientPing:FireServer(PingID)
	end)
	table.insert(Connections,PingListener)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the controller is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkController:Stop()
	for i=1,#Connections do
		Connections[1]:Disconnect()
		table.remove(Connections,i)
	end

	self:Log("[Network Controller] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Description : Called when the service is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkController:Unload()
	self:Log("[Network Controller] Unloading...")

	self:Log("[Network Controller] Unloaded!")
end

return NetworkController