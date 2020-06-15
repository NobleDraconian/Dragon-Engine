--[[
	Network Service
	
	Handles things such as latency checking, pinging clients, etc.
--]]

local NetworkService={Client={}}
NetworkService.Client.Server=NetworkService

---------------------
-- ROBLOX Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")

-------------
-- DEFINES --
-------------
local MAX_LATENCY=5 --The max time a ping will wait until auto failing. Can be overridden by the PingClient:(_,TimeOut) parameter.

local RemotesFolder=Instance.new('Folder')
	  RemotesFolder.Name="NetworkService"
	  RemotesFolder.Parent=ReplicatedStorage.DragonEngine.Network
local ClientPing=Instance.new('RemoteEvent') --Used to ping clients
      ClientPing.Name="ClientPing"
      ClientPing.Parent = RemotesFolder
local ServerPing=Instance.new('RemoteEvent') --Used to respond to pinging clients
	  ServerPing.Name="ServerPing"
	  ServerPing.Parent=RemotesFolder

local Connections={} --Holds any event listener connections in case the service is stopped/unloaded.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PingClient
-- @Description : Pings the specified client and returns the ping status (success/fail) and the time in milliseconds a response took.
-- @Params : Instance <Player> "Player" - The player to ping.
--           Number "TimeOut" - The amount of time to wait for a response before failing the ping.
-- @Returns : bool "PingSuccess" - Is true if the client replied to the ping.
--            float "Latency" - The time (in ms) it took the client to respond to the ping.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkService:PingClient(Player,TimeOut)
	local EndTick=0
	local PingReturned=false
	local PingSuccess=false
	local PingID=HttpService:GenerateGUID(false)
	local Latency=TimeOut or MAX_LATENCY
	local StartTick=tick()
	
	local PingResponse;
	PingResponse=ClientPing.OnServerEvent:connect(function(_,ResponseID)
		if ResponseID==PingID then
			PingResponse:Disconnect()
			EndTick=tick()
			self:DebugLog("Ping "..PingID.." RESPONSE")
			PingReturned=true
			PingSuccess=true
		end
	end)
	
	self:DebugLog("Ping "..PingID.." SEND")
	ClientPing:FireClient(Player,PingID)
	
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
function NetworkService:Init()
	
	self:DebugLog("[Network Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkService:Start()
	self:DebugLog("[Network Service] Started!")
	
	--------------------------------------
	-- Responding to pings from clients --
	--------------------------------------
	local PingListener=ServerPing.OnServerEvent:connect(function(Player,PingID)
		self:DebugLog("SERVER : RESPONDING TO PING "..PingID)
		ServerPing:FireClient(Player,PingID)
	end)
	table.insert(Connections,PingListener)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the service is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkService:Stop()
	for i=1,#Connections do
		Connections[1]:Disconnect()
		table.remove(Connections,i)
	end

	self:Log("[Network Service] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Descriptoin : Called when the service is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NetworkService:Unload()
	self:Log("[Network Service] Unloading...")

	self:Log("[Network Service] Removing ping events...")
	RemotesFolder:Destroy()
	self:Log("[Network Service] Ping events removed!")

	self:Log("[Network Service] Unloaded!")
end

return NetworkService