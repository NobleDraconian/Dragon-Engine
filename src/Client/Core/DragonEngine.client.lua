--[=[
	@class DragonEngineClient
	@client

	Handles the client sided aspects of the framework such as controllers, connecting to remotes, etc.
]=]

--- @interface Controller
--- @within DragonEngineClient
--- @field Init function -- The controller's `Init` method.
--- @field Start function -- The controller's `Start` method.
--- @field ... function -- The controller's various defined methods.
--- A client-sided microservice.

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--------------
-- REQUIRES --
--------------
local DragonEngineClient = require(ReplicatedStorage.DragonEngine.EngineCore)
local ENGINE_LOGO = require(ReplicatedStorage.DragonEngine.Logo)
local Boilerplate = require(ReplicatedStorage.DragonEngine.Boilerplate)
local EngineConfigs = {
	Settings = require(ReplicatedStorage.DragonEngine.Settings.EngineSettings),
	ClientPaths = require(ReplicatedStorage.DragonEngine.Settings.ClientPaths),
}

-------------
-- DEFINES --
-------------
DragonEngineClient.Services = {} --Contains all services, both running and stopped
DragonEngineClient.Controllers = {} --Contains all controllers, both running and stopped

-------------------------------------
-- Waiting on engine server to run --
-------------------------------------
DragonEngineClient:Log("")
DragonEngineClient:Log("**** WAITING FOR SERVER ****")
DragonEngineClient:Log("")
ReplicatedStorage:WaitForChild("DragonEngine"):WaitForChild("_Loaded") --Waiting for the server engine to load

-------------
-- DEFINES --
-------------
local Service_Endpoints = ReplicatedStorage.DragonEngine.Network.Service_Endpoints
local Service_ClientEndpoints = ReplicatedStorage.DragonEngine.Network.Service_ClientEndpoints
local Controller_Events = Instance.new('Folder') --A folder containing the client sided events for controllers.
	  Controller_Events.Name = "Controller_Events"
	  Controller_Events.Parent = StarterPlayer.StarterPlayerScripts.DragonEngine

------------
-- Events --
------------
local Service_Loaded = ReplicatedStorage.DragonEngine.Network.ServiceLoaded.OnClientEvent --Fired when a service is loaded.
DragonEngineClient.ServiceLoaded = Service_Loaded

local Service_Unloaded = ReplicatedStorage.DragonEngine.Network.ServiceUnloaded.OnClientEvent --Fired when a service is unloaded.
DragonEngineClient.ServiceUnloaded = Service_Unloaded

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
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
	DragonEngineClient:DebugLog("Connecting to endpoints for service '"..ServiceName.."'")
	local Service = {}

	for _,RemoteFunction in pairs(Service_EndpointFolder:GetChildren()) do
		if RemoteFunction:IsA("RemoteFunction") then
			DragonEngineClient:DebugLog("Connecting to remote function '"..Service_EndpointFolder.Name.."."..RemoteFunction.Name.."'...")

			Service[RemoteFunction.Name] = function(self,...) --We seperate 'self' to ommit it from the server call.
				return RemoteFunction:InvokeServer(...)
			end
		elseif RemoteFunction:IsA("RemoteEvent") then
			DragonEngineClient:DebugLog("Registered remote event '"..Service_EndpointFolder.Name.."."..RemoteFunction.Name.."'.")
			Service[RemoteFunction.Name] = RemoteFunction.OnClientEvent
		end
	end

	DragonEngineClient.Services[Service_EndpointFolder.Name] = Service
	DragonEngineClient:DebugLog("Connected to all endpoints for service '"..ServiceName.."'.")

	------------------------------------------
	-- Registering service client endpoints --
	------------------------------------------
	DragonEngineClient:DebugLog("Registering client endpoints for service '"..ServiceName.."'")

	for _,RemoteFunction in pairs(Service_ClientEndpointFolder:GetChildren()) do
		if RemoteFunction:IsA("RemoteFunction") then
			Service[RemoteFunction.Name] = RemoteFunction

			DragonEngineClient:DebugLog("Registered client endpoint '"..RemoteFunction.Name.."' for service '"..ServiceName.."'")
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Returns a reference to the requested service
--- ```lua
--- local MarketService = DragonEngine:GetService("MarketService")
--- MarketService:RequestPurchase("HealthPotion",5)
--- ```
---
--- @param ServiceName string -- The name of the service to get a reference to
--- @return ServiceClient -- The service with the given name
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:GetService(ServiceName)
	assert(DragonEngineClient.Services[ServiceName] ~= nil,"[Dragon Engine Client] GetService() : Service '"..ServiceName.."' was not loaded or does not exist.")
	return DragonEngineClient.Services[ServiceName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Returns a reference to the requested controller
--- ```lua
--- local UIController = DragonEngine:GetController("UIController")
--- UIController:DisplayDialogue("Do you like Cake, or Pie?","Cake",Pie")
--- ```
---
--- @param ControllerName string -- The name of the controller to get a reference to
--- @return Controller -- The controller with the given name
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:GetController(ControllerName)
	assert(DragonEngineClient.Controllers[ControllerName] ~= nil,"[Dragon Engine Client] GetController() : Controller '"..ControllerName.."' was not loaded or does not exist.")
	return DragonEngineClient.Controllers[ControllerName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Loads the given controller module into the framework, making it accessible via `DragonEngineServer:GetController()`.
--- ```lua
--- local Success,Error = DragonEngine:LoadController(LocalPlayer.PlayerScripts.Controllers.UIController)
--- if not Success then
--- 	print("Failed to load UIController : " .. Error)
--- end
--- ```
---
--- @private
--- @param ControllerModule ModuleScript -- The Controller modulescript to load into the framework
--- @return bool -- A `bool` describing whether or not the controller was successfully loaded
--- @return string -- A `string` containing the error message if the controller failed to load. Will be `nil` if the load is successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:LoadController(ControllerModule)

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
		-- Adding Controller to DragonEngineClient.Controllers --
		---------------------------------------------
		local EventsFolder = Instance.new('Folder') --Container for server sided events for this Controller
		      EventsFolder.Name = ControllerName
		      EventsFolder.Parent = Controller_Events

		Controller.Name = ControllerName
		Controller.Status = "Uninitialized"
		Controller.Initialized = false
		Controller._ClientEventsFolder = EventsFolder

		setmetatable(Controller,{__index = DragonEngineClient}) --Exposing Dragon Engine to the Controller
		self.Controllers[ControllerName] = Controller

		self:DebugLog("Controller '"..ControllerName.."' loaded.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Loads all controllers in the given container via `DragonEngine:LoadController()`.
--- ```lua
--- DragonEngine:LoadControllersIn(LocalPlayer.PlayerScripts.Controllers)
--- ```
--- :::caution
--- Only modules that are children of a `Model` or `Folder` instance will be considered for lazy-loading. Other instance types
--- are not supported at this time.
--- :::
---
--- @private
--- @param Container Folder -- The folder that contains the controller modules
--- @return nil
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:LoadControllersIn(Container)
	for _,ControllerModule in pairs(Boilerplate.RecurseFind(Container,"ModuleScript")) do
		if not IsModuleIgnored(ControllerModule) then
			DragonEngineClient:LoadController(ControllerModule)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Unloads the specified controller from the framework and destroys any bindables it created.
--- This API will attempt to call `DragonEngine:StopController()` with the controller before unloading it, to clean state.
--- ```lua
--- local Success,Error = DragonEngine:UnloadController("UIController")
--- if not Success then
--- 	print("Failed to unload UIController : " .. Error)
--- end
--- ```
---
--- @private
--- @param ControllerName string -- The name of the controller to unload
--- @return bool -- A `bool` describing whether or not the controller was successfully unloaded
--- @return string -- A `string` containing the error message if the controller fails to be unloaded. Is `nil` if unloading succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:UnloadController(ControllerName)

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
--- Calls `:Init()` on the specified controller.
--- ```lua
--- local Success,Error = DragonEngine:InitializeController("UIController")
--- if not Success then
--- 	print("Failed to initialize uicontroller : " .. Error)
--- end
--- ```
---
--- @private
--- @param ControllerName string -- The name of the controller to initialize
--- @return bool -- A `bool` describing whether or not the controller was successfully initialized
--- @return string -- A `string` containing the error message if the controller fails to be initialized. Is `nil` if initialization succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:InitializeController(ControllerName)

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
			DragonEngineClient:Log("Failed to initialize Controller '"..ControllerName.."' : "..Error,"Warning")
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
--- Calls `:Start()` on the specified controller.
--- ```lua
--- local Success,Error = DragonEngine:StartController("UIController")
--- if not Success then
--- 	print("Failed to start uicontroller : " .. Error)
--- end
--- ```
---
--- @private
--- @param ControllerName string -- The name of the controller to start
--- @return bool -- A `bool` describing whether or not the controller was successfully started.
--- @return string -- A `string` containing the error message if the controller fails to successfully start. Is `nil` if start was successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:StartController(ControllerName)
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
			DragonEngineClient:Log("Failed to start Controller '"..ControllerName.."' : "..Error,"Warning")
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
--- Calls `:Stop()` on the specified controller
--- ```lua
--- local Success,Error = DragonEngine:StopController("UIController")
--- if not Success then
--- 	print("Failed to stop uicontroller : " .. Error)
--- end
--- ```
---
--- @private
--- @param ControllerName string -- The name of the Controller to stop
--- @return bool -- A `bool` describing whether or not the controller was successfully stopped
--- @return string -- A `string` containing the error message if the controller fails to stop. Will be `nil` if the stop is successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:StopController(ControllerName)
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
			DragonEngineClient:Log("Failed to stop Controller '"..ControllerName.."' : "..Error,"Warning")
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
--- Registers a BindableEvent for the calling controller that it can use to fire client-side events.
--- ```lua
--- local AvatarJumpedBindable = DragonEngine:RegisterControllerClientEvent("AvatarJumped")
--- AvatarJumpedBindable:Fire(PlayerCharacter)
--- ```
--- :::warning
--- This API should only be called from a controller! Calling it outside of a controller will cause errors.
--- :::
---
--- @param Name string -- The name to assign to the BindableEvent
--- @return BindableEvent -- The BindableEvent that was registered with the framework
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineClient:RegisterControllerClientEvent(Name)

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
				if EngineConfigs.Settings.IgnoredModules[ModuleLocationType] == nil then
					EngineConfigs.Settings.IgnoredModules[ModuleLocationType] = {}
				end

				for _,ModuleName in pairs(ModuleNames) do
					table.insert(EngineConfigs.Settings.IgnoredModules[ModuleLocationType],ModuleName)
				end
			end
		end

		if Developer_SettingsFolder:FindFirstChild("ClientPaths") ~= nil then
			local Developer_ClientPaths = require(Developer_SettingsFolder.ClientPaths)

			for ModuleLocationType,ModulePaths in pairs(Developer_ClientPaths.ModulePaths) do
				if EngineConfigs.ClientPaths.ModulePaths[ModuleLocationType] == nil then
					EngineConfigs.ClientPaths.ModulePaths[ModuleLocationType] = {}
				end

				for _,ModulePath in pairs(ModulePaths) do
					table.insert(EngineConfigs.ClientPaths.ModulePaths[ModuleLocationType],ModulePath)
				end
			end

			for _,ControllerPath in pairs(Developer_ClientPaths.ControllerPaths) do
				table.insert(EngineConfigs.ClientPaths.ControllerPaths,ControllerPath)
			end
		end
	end)
	assert(Success == true,"[Dragon Engine Server] An error occured while loading developer-specified settings : "..(Error or ""))
end
DragonEngineClient.Config = EngineConfigs

if EngineConfigs.Settings.ShowLogoInOutput then
	DragonEngineClient:Log(ENGINE_LOGO)
end
if EngineConfigs.Settings.Debug then
	DragonEngineClient:Log("[Dragon Engine Server] Debug enabled. Logging will be verbose.")
end

-------------------
-- Loading Enums --
-------------------
for EnumName,EnumVal in pairs(EngineConfigs.Settings.Enums) do
	DragonEngineClient:DefineEnum(EnumName,EnumVal)
end

---------------------
-- Loading modules --
---------------------
DragonEngineClient:Log("")
DragonEngineClient:Log("**** Loading modules ****")
DragonEngineClient:Log("")
for _,ModulePaths in pairs(EngineConfigs.ClientPaths.ModulePaths) do
	for _,ModulePath in pairs(ModulePaths) do
		DragonEngineClient:LazyLoadModulesIn(ModulePath)
	end
end
DragonEngineClient:Log("All modules lazy-loaded!")

--------------------------------------------
-- Connecting to remote service endpoints --
--------------------------------------------
DragonEngineClient:Log("")
DragonEngineClient:Log("**** Connecting to service endpoints ****")
DragonEngineClient:Log("")
DragonEngineClient:DebugLog("Connecting to service endpoints...")
for _,ServiceFolder in pairs(Service_Endpoints:GetChildren()) do
	ConnectToServiceEndpoints(ServiceFolder.Name)
end
DragonEngineClient:Log("All endpoints connected to!")

----------------------------------------------------
--  Loading, initializing and running controllers --
----------------------------------------------------
DragonEngineClient:Log("")
DragonEngineClient:Log("**** Loading controllers ****")
DragonEngineClient:Log("")
for _,ControllerPath in pairs(EngineConfigs.ClientPaths.ControllerPaths) do
	DragonEngineClient:LoadControllersIn(ControllerPath)
end
DragonEngineClient:Log("All controllers loaded!")

DragonEngineClient:Log("")
DragonEngineClient:Log("**** Initializing controllers ****")
DragonEngineClient:Log("")
for ControllerName,_ in pairs(DragonEngineClient.Controllers) do
	DragonEngineClient:InitializeController(ControllerName)
end
DragonEngineClient:Log("All controllers initialized!")

DragonEngineClient:Log("")
DragonEngineClient:Log("**** Starting controllers ****")
DragonEngineClient:Log("")
for ControllerName,Controller in pairs(DragonEngineClient.Controllers) do
	if Controller.Initialized then
		DragonEngineClient:StartController(ControllerName)
	end
end
DragonEngineClient:Log("All services running!")


---------------------------------------------
-- Listening for service loading/unloading --
---------------------------------------------
Service_Loaded:connect(function(ServiceName)
	DragonEngineClient:Log("[Dragon Engine Client] New service loaded on the server, connecting to endpoints.")
	if Service_Endpoints:FindFirstChild(ServiceName) ~= nil then --Service has endpoint APIs.
		ConnectToServiceEndpoints(ServiceName)
	end
end)
Service_Unloaded:connect(function(ServiceName)
	DragonEngineClient:Log("[Dragon Engine Client] Service unloaded on the server, disconnecting from endpoints.")
	DragonEngineClient.Services[ServiceName] = nil
end)

------------------------------------------
-- Indicating that the engine is loaded --
------------------------------------------
shared.DragonEngine = DragonEngineClient
DragonEngineClient:Log("Dragon Engine "..DragonEngineClient.Version.." loaded!")