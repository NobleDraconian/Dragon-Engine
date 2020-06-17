--[[
	Dragon Engine Client

	Handles the client sided aspects of the framework, including controllers.
--]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--------------
-- REQUIRES --
--------------
local DragonEngine = require(ReplicatedStorage.DragonEngine.EngineCore)
local ENGINE_LOGO = require(ReplicatedStorage.DragonEngine.Logo)
local Boilerplate = require(ReplicatedStorage.DragonEngine.Boilerplate)
local EngineConfigs = {
	Settings = require(ReplicatedStorage.DragonEngine.Settings.EngineSettings),
	ClientPaths = require(ReplicatedStorage.DragonEngine.Settings.ClientPaths),
}

-------------
-- DEFINES --
-------------
DragonEngine.Services = {} --Contains all services, both running and stopped
DragonEngine.Controllers = {} --Contains all controllers, both running and stopped

-------------------------------------
-- Waiting on engine server to run --
-------------------------------------
print("")
print("**** WAITING FOR SERVER ****")
print("")
ReplicatedStorage:WaitForChild("DragonEngine"):WaitForChild("_Loaded") --Waiting for the server engine to load

-------------
-- DEFINES --
-------------
local Service_Endpoints = ReplicatedStorage.DragonEngine.Network.Service_Endpoints
local Service_ClientEndpoints = ReplicatedStorage.DragonEngine.Network.Service_ClientEndpoints
local Controller_Events = Instance.new('Folder') --A folder containing the client sided events for controllers.
	  Controller_Events.Name = "Controller_Events"
	  Controller_Events.Parent = Players.LocalPlayer.PlayerScripts.DragonEngine

------------
-- Events --
------------
local Service_Loaded = ReplicatedStorage.DragonEngine.Network.ServiceLoaded.OnClientEvent --Fired when a service is loaded.
DragonEngine.ServiceLoaded = Service_Loaded

local Service_Unloaded = ReplicatedStorage.DragonEngine.Network.ServiceUnloaded.OnClientEvent --Fired when a service is unloaded.
DragonEngine.ServiceUnloaded = Service_Unloaded

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Boilerplate
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function IsModuleIgnored(Module)
	for _,ModuleName in pairs(EngineConfigs.Settings.IgnoredModules) do
		if ModuleName == Module.Name then
			return true
		end
	end

	return false
end

--------------------------------------------------------------
--  Registers and connects to the given service's endpoints --
--------------------------------------------------------------
local function ConnectToServiceEndpoints(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName ~= nil,"[Dragon Engine Client] ConnectToServiceEndpoints() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName) == "string","[Dragon Engine Client] ConnectToServiceEndpoints() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(Service_Endpoints:FindFirstChild(ServiceName) ~= nil,"[Dragon Engine Client] ConnectToServiceEndpoints() : No service with the name '"..ServiceName.."' exists!")

	-------------
	-- DEFINES --
	-------------
	local Service_EndpointFolder = Service_Endpoints[ServiceName]
	local Service_ClientEndpointFolder = Service_ClientEndpoints[ServiceName]

	-----------------------------
	-- Connecting to endpoints --
	-----------------------------
	DragonEngine:DebugLog("Connecting to endpoints for service '"..ServiceName.."'")
	local Service = {}

	for _,RemoteFunction in pairs(Service_EndpointFolder:GetChildren()) do
		if RemoteFunction:IsA("RemoteFunction") then
			DragonEngine:DebugLog("Connecting to remote function '"..Service_EndpointFolder.Name.."."..RemoteFunction.Name.."'...")

			Service[RemoteFunction.Name] = function(self,...) --We seperate 'self' to ommit it from the server call.
				return RemoteFunction:InvokeServer(...)
			end
		elseif RemoteFunction:IsA("RemoteEvent") then
			DragonEngine:DebugLog("Registered remote event '"..Service_EndpointFolder.Name.."."..RemoteFunction.Name.."'.")
			Service[RemoteFunction.Name] = RemoteFunction.OnClientEvent
		end
	end

	DragonEngine.Services[Service_EndpointFolder.Name] = Service
	DragonEngine:DebugLog("Connected to all endpoints for service '"..ServiceName.."'.")

	------------------------------------------
	-- Registering service client endpoints --
	------------------------------------------
	DragonEngine:DebugLog("Registering client endpoints for service '"..ServiceName.."'")

	for _,RemoteFunction in pairs(Service_ClientEndpointFolder:GetChildren()) do
		if RemoteFunction:IsA("RemoteFunction") then
			Service[RemoteFunction.Name] = RemoteFunction

			DragonEngine:DebugLog("Registered client endpoint '"..RemoteFunction.Name.."' for service '"..ServiceName.."'")
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLLERS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------
-- DEFINES --
-------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: GetController
-- @Description : Returns the requested controller.
--                Similiar to game:GetService().
-- @Params : string "ControllerName" - The name of the Controller to retrieve
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetController(ControllerName)
	assert(DragonEngine.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] GetController() : Controller '"..ControllerName.."' was not loaded or does not exist.")
	return DragonEngine.Controllers[ControllerName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadController
-- @Description : Loads the specified Controller module into the engine. Returns false if the Controller fails to load.
-- @Params : Instance <ModuleScript> "ControllerModule" - The Controller module to load into the engine
-- @Returns : Boolean "ControllerLoaded" - Will be TRUE if the Controller is loaded successfully, will be FALSE if the Controller failed to load.
--            string "ErrorMessage" - The error message if loading the Controller failed. Is nil if loading succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadController(ControllerModule)

	----------------
	-- Assertions --
	----------------
	assert(ControllerModule ~= nil,"[Dragon Engine Client] LoadController() : ModuleScript expected for 'ControllerModule', got nil instead.")
	assert(typeof(ControllerModule) == "Instance","[Dragon Engine Client] LoadController() : ModuleScript expected for 'ControllerModule', got "..typeof(ControllerModule).." instead.")
	assert(ControllerModule:IsA("ModuleScript"),"[Dragon Engine Client] LoadController() : ModuleScript expected for 'ControllerModule', got "..ControllerModule.ClassName.." instead.")
	assert(self.Controllers[ControllerModule.Name] == nil,"[Dragon Engine Client] LoadController() : A Controller with the name '"..ControllerModule.Name.."' is already loaded!")

	-------------
	-- DEFINES --
	-------------
	local ControllerName = ControllerModule.Name
	local Controller; --Table holding the Controller

	-------------------------
	-- Loading the Controller --
	------------------------
	self:DebugLog("Loading Controller '"..ControllerModule.Name.."'...")

	local Success,Error = pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Controller = require(ControllerModule)
	end)
	if not Success then --Controller module failed to load
		self:Log("Failed to load Controller '"..ControllerName.."' : "..Error,"Warning")
		return false,Error
	else --Controller module was loaded

		---------------------------------------------
		-- Adding Controller to DragonEngine.Controllers --
		---------------------------------------------
		local EventsFolder = Instance.new('Folder') --Container for server sided events for this Controller
		      EventsFolder.Name = ControllerName
		      EventsFolder.Parent = Controller_Events

		Controller.Name = ControllerName
		Controller.Status = "Uninitialized"
		Controller.Initialized = false
		Controller._ClientEventsFolder = EventsFolder

		setmetatable(Controller,{__index = DragonEngine}) --Exposing Dragon Engine to the Controller
		self.Controllers[ControllerName] = Controller

		self:DebugLog("Controller '"..ControllerName.."' loaded.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadControllersIn
-- @Description : Loads all Controllers in the given container.
-- @Params : Instance "Container" - The container holding all of the Controller modules.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadControllersIn(Container)
	for _,ControllerModule in pairs(Boilerplate.RecurseFind(Container,"ModuleScript")) do
		if not IsModuleIgnored(ControllerModule) then
			DragonEngine:LoadController(ControllerModule)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : UnloadController
-- @Description : Unloads the specified Controller from the engine and destroys any endpoints/events it created.
--                This function will attempt to Stop() the controller before unloading it, to clean state.
-- @Params : string "ControllerName" - The name of the Controller to unload.
-- @Returns : Boolean "ControllerUnloaded" - Will be TRUE if the Controller is unloaded successfully, will be FALSE if the Controller failed to unload.
--            string "ErrorMessage" - The error message if unloading the Controller failed. Is nil if unloading succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:UnloadController(ControllerName)

	----------------
	-- Assertions --
	----------------
	assert(ControllerName ~= nil,"[Dragon Engine Client] UnloadController() : string expected for 'ControllerName', got nil instead.")
	assert(typeof(ControllerName) == "string","[Dragon Engine Client] UnloadController() : string expected for 'ControllerName', got "..typeof(ControllerName).." instead.")
	assert(self.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] UnloadController() : No Controller with the name '"..ControllerName.."' is loaded!")

	-------------
	-- DEFINES --
	-------------
	local Controller = self.Controllers[ControllerName]

	--------------------------
	-- Stopping the service --
	--------------------------
	if Controller.Status == "Running" then
		self:StopController(ControllerName)
	end

	---------------------------
	-- Unloading the Controller --
	---------------------------
	self:Log("Unloading Controller '"..ControllerName.."'...")
	if typeof(Controller.Unload) == "function" then --The Controller has an unload function, run it to allow the Controller to clean state.
		local Success,Error = pcall(function()
			Controller:Unload()
		end)
		if not Success then --Unloading the Controller failed.
			self:Log("Controller '"..ControllerName.."' unload function failed : "..Error,"Warning")
				return false,Error
		end
	else --The Controller had no unload function. Warn about potential memory leaks.
		self:Log("Controller '"..ControllerName.."' had no unload function, a memory leak is possible.","Warning")
	end

	Controller._ClientEventsFolder:Destroy() --Destroy Controller server events
	self.Controllers[ControllerName] = nil

	self:Log("Controller '"..ControllerName.."' unloaded.")
	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : InitializeController
-- @Description : Initializes the specified Controller.
-- @Params : string "ControllerName" - The name of the Controller to initialize
-- @Returns : bool "Success" - Whether or not the Controller was successfully initialized.
--            string "Error" - The error message if the initialization failed. Is nil if initialization succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:InitializeController(ControllerName)

	----------------
	-- Assertions --
	----------------
	assert(ControllerName ~= nil,"[Dragon Engine Client] InitializeController() : string expected for 'ControllerName', got nil instead.")
	assert(typeof(ControllerName) == "string","[Dragon Engine Client] InitializeController() : string expected for 'ControllerName', got "..typeof(ControllerName).." instead.")
	assert(self.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] InitializeController() : No Controller with the name '"..ControllerName.."' is loaded!")
	assert(self.Controllers[ControllerName].Initialized == false,"[Dragon Engine Client] InitializeController() : Controller '"..ControllerName.."' is already initialized!")

	-------------
	-- DEFINES --
	-------------
	local Controller = self.Controllers[ControllerName]

	------------------------------
	-- Initializing the Controller --
	------------------------------
	self:DebugLog("Initializing Controller '"..ControllerName.."'...")
	if type(Controller.Init) == "function" then --An init() function exists, run it.
		local Success,Error = pcall(function()
			Controller:Init()
		end)
		if not Success then
			DragonEngine:Log("Failed to initialize Controller '"..ControllerName.."' : "..Error,"Warning")
			return false,Error
		end
		Controller.Status = "Stopped"
		Controller.Initialized = true
	else --Init function doesn't exist
		self:DebugLog("Controller '"..ControllerName.."' could not be initilized, no init function was found!","Warning")
	end
	self:DebugLog("Controller '"..ControllerName.."' initialized.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StartController
-- @Description : Starts the specified Controller.
-- @Params : bool "Success" - Whether or not the Controller was successfully started.
--           string "Error" - The error message if starting the Controller failed. Is nil if the start succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:StartController(ControllerName)
	----------------
	-- Assertions --
	----------------
	assert(ControllerName ~= nil,"[Dragon Engine Client] StartController() : string expected for 'ControllerName', got nil instead.")
	assert(typeof(ControllerName) == "string","[Dragon Engine Client] StartController() : string expected for 'ControllerName', got "..typeof(ControllerName).." instead.")
	assert(self.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] StartController() : No Controller with the name '"..ControllerName.."' is loaded!")
	assert(self.Controllers[ControllerName].Status ~= "Running","[Dragon Engine Client] StartController() : The Controller '"..ControllerName.."' is already running!")
	assert(self.Controllers[ControllerName].Initialized == true,"[Dragon Engine Client] StartController() : The controller '"..ControllerName.."' was not initialized!")


	-------------
	-- DEFINES --
	-------------
	local Controller = self.Controllers[ControllerName]

	------------------------------
	-- Initializing the Controller --
	------------------------------
	self:DebugLog("Starting Controller '"..ControllerName.."'...")
	if type(Controller.Start) == "function" then --An init() function exists, run it.
		local Success,Error = pcall(function()
			coroutine.wrap(Controller.Start)(Controller)
		end)
		if not Success then
			DragonEngine:Log("Failed to start Controller '"..ControllerName.."' : "..Error,"Warning")
			return false,Error
		end
		Controller.Status = "Running"
	else --Start function doesn't exist
		self:DebugLog("Controller '"..ControllerName.."' could not be started, no start function was found!","Warning")
	end
	self:DebugLog("Controller '"..ControllerName.."' started.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StopController
-- @Description : Stops the specified Controller.
-- @Params : bool "Success" - Whether or not the Controller was successfully stopped.
--           string "Error" - The error message if stopping the Controller failed. Is nil if the start succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:StopController(ControllerName)
	----------------
	-- Assertions --
	----------------
	assert(ControllerName ~= nil,"[Dragon Engine Client] StopController() : string expected for 'ControllerName', got nil instead.")
	assert(typeof(ControllerName) == "string","[Dragon Engine Client] StopController() : string expected for 'ControllerName', got "..typeof(ControllerName).." instead.")
	assert(self.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] StopController() : No Controller with the name '"..ControllerName.."' is loaded!")
	assert(self.Controllers[ControllerName].Status == "Running","[Dragon Engine Client] StopController() : The Controller '"..ControllerName.."' is already stopped!")

	-------------
	-- DEFINES --
	-------------
	local Controller = self.Controllers[ControllerName]

	------------------------------
	-- Stopping the Controller --
	------------------------------
	self:DebugLog("Stopping Controller '"..ControllerName.."'...")
	if type(Controller.Stop) == "function" then --A stop() function exists, run it.
		local Success,Error = pcall(function()
			Controller:Stop()
		end)
		if not Success then
			DragonEngine:Log("Failed to stop Controller '"..ControllerName.."' : "..Error,"Warning")
			return false,Error
		end
		Controller.Status = "Stopped"
	else --Stop function doesn't exist
		self:DebugLog("Controller '"..ControllerName.."' could not be stopped, no stop function was found!","Warning")
	end

	self:DebugLog("Controller '"..ControllerName.."' stopped.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterControllerClientEvent
-- @Description : Registers a client event for the Controller calling. MUST BE CALLED FROM INSIDE A Controller MODULE.
-- @Params : string "Name" - The name to assign to the client event.
-- @Retruns : Instance <BindableEvent> "BindableEvent" - The Controller client event.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterControllerClientEvent(Name)

	----------------
	-- Assertions --
	----------------
	assert(Name ~= nil,"[Dragon Engine Client] RegisterControllerClientEvent() : string expected for 'Name', got nil instead.")
	assert(typeof(Name) == "string","[Dragon Engine Client] RegisterControllerClientEvent() : string expected for 'ame', got "..typeof(Name).." instead.")

	local BindableEvent = Instance.new('BindableEvent')
	BindableEvent.Name = Name
	BindableEvent.Parent = self._ClientEventsFolder
	self[Name] = BindableEvent.Event

	self:DebugLog("Registered client event '"..Name.."' for Controller '"..self.Name.."'")

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENGINE INIT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------
-- Loading Settings --
----------------------
local Developer_SettingsFolder = ReplicatedStorage:FindFirstChild("DragonEngine_Configs")
if Developer_SettingsFolder ~= nil then -- Load developer-specified settings
	local Success,Error = pcall(function()
		if Developer_SettingsFolder:FindFirstChild("EngineSettings") ~= nil then
			local Developer_EngineConfigs = require(Developer_SettingsFolder.EngineSettings)

			EngineConfigs.Settings.ShowLogoInOutput = Developer_EngineConfigs.ShowLogoInOutput
			EngineConfigs.Settings.Debug = Developer_EngineConfigs.Debug
			
			for ModuleLocationType,ModuleNames in pairs(Developer_EngineConfigs.IgnoredModules) do
				for _,ModuleName in pairs(ModuleNames) do
					table.insert(EngineConfigs.Settings.IgnoredModules[ModuleLocationType],ModuleName)
				end
			end
		end

		if Developer_SettingsFolder:FindFirstChild("ClientPaths") ~= nil then
			local Developer_ClientPaths = require(Developer_SettingsFolder.ClientPaths)

			for ModuleLocationType,ModulePaths in pairs(Developer_ClientPaths.ModulePaths) do
				for _,ModulePath in pairs(ModulePaths) do
					table.insert(EngineConfigs.ClientPaths.ModulePaths[ModuleLocationType],ModulePath)
				end
			end

			for _,ControllerPath in pairs(Developer_ClientPaths.ControllerPaths) do
				table.insert(EngineConfigs.ServerPaths.ServicePaths,ControllerPath)
			end
		end
	end)
	assert(Success == true,"[Dragon Engine Server] An error occured while loading developer-specified settings : "..Error)
end
DragonEngine.Config = EngineConfigs

if EngineConfigs.Settings.ShowLogoInOutput then
	print(ENGINE_LOGO)
end
if EngineConfigs.Settings.Debug then
	warn("[Dragon Engine Server] Debug enabled. Logging will be verbose.")
end

-------------------
-- Loading Enums --
-------------------
for EnumName,EnumVal in pairs(EngineConfigs.Settings.Enums) do
	DragonEngine:DefineEnum(EnumName,EnumVal)
end

---------------------
-- Loading modules --
---------------------
print("")
print("**** Loading modules ****")
print("")
for _,ModulePaths in pairs(EngineConfigs.ClientPaths.ModulePaths) do
	for _,ModulePath in pairs(ModulePaths) do
		DragonEngine:LazyLoadModulesIn(ModulePath)
	end
end
DragonEngine:DebugLog("All modules lazy-loaded!")

--------------------------------------------
-- Connecting to remote service endpoints --
--------------------------------------------
print("")
print("**** Connecting to service endpoints ****")
print("")
DragonEngine:DebugLog("Connecting to service endpoints...")
for _,ServiceFolder in pairs(Service_Endpoints:GetChildren()) do
	ConnectToServiceEndpoints(ServiceFolder.Name)
end
DragonEngine:DebugLog("All endpoints connected to!")

----------------------------------------------------
--  Loading, initializing and running controllers --
----------------------------------------------------
print("")
print("**** Loading controllers ****")
print("")
for _,ControllerPath in pairs(EngineConfigs.ClientPaths.ControllerPaths) do
	DragonEngine:LoadControllersIn(ControllerPath)
end
DragonEngine:DebugLog("All controllers loaded!")

print("")
print("**** Initializing controllers ****")
print("")
for ControllerName,_ in pairs(DragonEngine.Controllers) do
	DragonEngine:InitializeController(ControllerName)
end
DragonEngine:DebugLog("All controllersf initialized!")

print("")
print("**** Starting controllers ****")
print("")
for ControllerName,Controller in pairs(DragonEngine.Controllers) do
	if Controller.Initialized then
		DragonEngine:StartController(ControllerName)
	end
end
DragonEngine:DebugLog("All services running!")


---------------------------------------------
-- Listening for service loading/unloading --
---------------------------------------------
Service_Loaded:connect(function(ServiceName)
	DragonEngine:Log("[Dragon Engine Client] New service loaded on the server, connecting to endpoints.")
	if Service_Endpoints:FindFirstChild(ServiceName) ~= nil then --Service has endpoint APIs.
		ConnectToServiceEndpoints(ServiceName)
	end
end)
Service_Unloaded:connect(function(ServiceName)
	DragonEngine:Log("[Dragon Engine Client] Service unloaded on the server, disconnecting from endpoints.")
	DragonEngine.Services[ServiceName] = nil
end)

------------------------------------------
-- Indicating that the engine is loaded --
------------------------------------------
shared.DragonEngine = DragonEngine
print("Dragon Engine "..DragonEngine.Version.." loaded!")