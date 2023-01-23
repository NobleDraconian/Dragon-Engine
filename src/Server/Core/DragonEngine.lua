--[=[
	@class DragonEngineServer
	@server

	Handles the server sided aspects of the framework such as services, creating remotes, etc.
]=]

--- @interface Service
--- @within DragonEngineServer
--- @field Client ServiceClient -- The client-facing part of the service
--- @field Init function -- The service's `Init` method.
--- @field Start function -- The service's `Start` method.
--- @field ... function -- The service's various defined methods.
--- The server-facing part of a microservice.

--- @interface ServiceClient
--- @within DragonEngineServer
--- @field Server Service -- A reference to the service's server-facing APIs. Will be `nil` on the client.
--- @field ... function -- The service's various defined client-facing APIs.
---
--- The client-facing part of a microservice.

--- @interface ServerPaths
--- @within DragonEngineServer
--- @field ModulePaths table -- The folders that the framework will lazyload modules from
--- @field ServicePaths table -- The folders that the framework will load services from
---
--- The folders that the framework will look in when attempting to load services & modules.
--- Here's an example of a valid ServerPaths configuration:
--- ```lua
--- {
--- 	ModulePaths = {
--- 		Server = {
--- 			ServerScriptService.Modules,
--- 		},
--- 		Shared = {
--- 			ReplicatedStorage.Modules,
--- 		}
--- 	},
--- 	ServicePaths = {
--- 		ServerScriptService.Services
--- 	}
--- }
--- ```
--- For more information, see [server paths](../docs/Configuration#server-paths).

---------------------
-- Roblox Services --
---------------------


--------------
-- REQUIRES --
--------------
local DragonEngineServer = require(script.Parent.Parent.Parent.Shared.EngineCore)
local ENGINE_LOGO = require(script.Parent.Parent.Parent.Shared.Logo)
local Boilerplate = require(script.Parent.Parent.Parent.Shared.Boilerplate)
local DefaultFrameworkSettings = {
	CoreSettings = require(script.Parent.Parent.Parent.Shared.Settings.EngineSettings),
	ServerPaths = require(script.Parent.Parent.Parent.Shared.Settings.ServerPaths)
}

-------------
-- DEFINES --
-------------
local Framework_NetworkFolder = Instance.new('Folder')
      Framework_NetworkFolder.Name = "Network"
      Framework_NetworkFolder.Parent = script.Parent.Parent.Parent
local ServiceEndpoints_Folder = Instance.new('Folder')
	  ServiceEndpoints_Folder.Name = "Service_Endpoints"
	  ServiceEndpoints_Folder.Parent = Framework_NetworkFolder
local ServiceEvents_Folder = Instance.new('Folder')
      ServiceEvents_Folder.Name = "Service_Events"
      ServiceEvents_Folder.Parent = script.Parent.Parent
local Service_ClientEndpoints = Instance.new('Folder')
	  Service_ClientEndpoints.Name = "Service_ClientEndpoints"
	  Service_ClientEndpoints.Parent = Framework_NetworkFolder
local CurrentFrameworkSettings = {
	ShowLogoInOutput = DefaultFrameworkSettings.CoreSettings.ShowLogoInOutput,
	Debug = DefaultFrameworkSettings.CoreSettings.ShowLogoInOutput,
	ServerPaths = DefaultFrameworkSettings.ServerPaths
}
DragonEngineServer.Services = {} --Contains all services, both running and stopped
DragonEngineServer.Config = CurrentFrameworkSettings

------------
-- Events --
------------
local Service_Loaded_ServerEvent = Instance.new('BindableEvent')
local Service_Unloaded_ServerEvent = Instance.new('BindableEvent')
local ServiceLoaded_ClientEvent = Instance.new('RemoteEvent')
	  ServiceLoaded_ClientEvent.Name = "ServiceLoaded"
	  ServiceLoaded_ClientEvent.Parent = Framework_NetworkFolder
local ServiceUnloaded_ClientEvent = Instance.new('RemoteEvent')
	  ServiceUnloaded_ClientEvent.Name = "ServiceUnloaded"
	  ServiceUnloaded_ClientEvent.Parent = Framework_NetworkFolder
DragonEngineServer.ServiceLoaded = Service_Loaded_ServerEvent.Event
DragonEngineServer.ServiceUnloaded = Service_Unloaded_ServerEvent.Event

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- APIs
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Returns a reference to the specified service. Similar to `game:GetService()` in the Roblox API.
--- ```lua
--- local MarketService = DragonEngine:GetService("MarketService")
--- MarketService:GiveItem(SomePlayer,"HealthPotion",5)
--- ```
---
--- @param ServiceName string -- The name of the service to get a reference to
--- @return Service -- The service with the given name
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:GetService(ServiceName)
	assert(DragonEngineServer.Services[ServiceName] ~= nil,"[Dragon Engine Server] GetService() : Service '"..ServiceName.."' was not loaded or does not exist.")
	return DragonEngineServer.Services[ServiceName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Loads the given service module into the framework, making it accessible via `DragonEngineServer:GetService()`.
--- ```lua
--- local Success,Error = DragonEngine:LoadService(ServerScriptService.Services.AvatarService)
--- if not Success then
--- 	print("Failed to load AvatarService : " .. Error)
--- end
--- ```
---
--- @private
--- @param ServiceModule ModuleScript -- The service modulescript to load into the framework
--- @return bool -- A `bool` describing whether or not the service was successfully loaded
--- @return string -- A `string` containing the error message if the service failed to load. Will be `nil` if the load is successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:LoadService(ServiceModule)

	----------------
	-- Assertions --
	----------------
	assert(ServiceModule ~= nil,"[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got nil instead.")
	assert(typeof(ServiceModule) == "Instance","[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got "..typeof(ServiceModule).." instead.")
	assert(ServiceModule:IsA("ModuleScript"),"[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got "..ServiceModule.ClassName.." instead.")
	assert(self.Services[ServiceModule.Name] == nil,"[Dragon Engine Server] LoadService() : A service with the name '"..ServiceModule.Name.."' is already loaded!")

	-------------
	-- DEFINES --
	-------------
	local ServiceName = ServiceModule.Name
	local Service; --Table holding the service

	-------------------------
	-- Loading the service --
	------------------------
	self:DebugLog("Loading service '"..ServiceModule.Name.."'...")

	local Success,Error = pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Service = require(ServiceModule)
	end)
	if not Success then --! Service module failed to load
		self:Log("Failed to load service '"..ServiceName.."' : "..Error,"Warning")

		return false,Error
	else --Service module was loaded

		----------------------------------
		-- Generating service endpoints --
		----------------------------------
		local EndpointFolder = Instance.new('Folder') --Container for remote functions/events so clients can access the service client API.
		      EndpointFolder.Name = ServiceName
		      EndpointFolder.Parent = ServiceEndpoints_Folder
		Service._EndpointFolder = EndpointFolder

		if Service.Client ~= nil then --The service has client APIs
			for FunctionName,Function in pairs(Service.Client) do
				if type(Function) == "function" then
					local RemoteFunction = Instance.new('RemoteFunction')
					      RemoteFunction.Name = FunctionName
					      RemoteFunction.Parent = EndpointFolder

					RemoteFunction.OnServerInvoke = function(...)
						return Function(Service.Client,...) --Service.Client is passed since `self` needs to be manually defined
					end

					self:DebugLog("Registered endpoint '"..ServiceName.."."..FunctionName.."'")
				end
			end
		end

		---------------------------------
		-- Generating client endpoints --
		---------------------------------
		local Client_EndpointFolder = Instance.new('Folder')
		      Client_EndpointFolder.Name = ServiceName
			  Client_EndpointFolder.Parent = Service_ClientEndpoints
		Service._ClientEndpointFolder = Client_EndpointFolder

		---------------------------------------------
		-- Adding service to DragonEngine.Services --
		---------------------------------------------
		local EventsFolder = Instance.new('Folder') --Container for server sided events for this service
			  EventsFolder.Name = ServiceName
			  EventsFolder.Parent = ServiceEvents_Folder
		Service._ServerEventsFolder = EventsFolder

		Service.Name = ServiceName
		Service.Status = "Uninitialized"
		Service.Initialized = false

		setmetatable(Service,{__index = DragonEngineServer}) --Exposing Dragon Engine to the service
		self.Services[ServiceName] = Service

		self:DebugLog("Service '"..ServiceName.."' loaded.")
		ServiceLoaded_ClientEvent:FireAllClients(ServiceName)

		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Loads all services in the given container via `DragonEngine:LoadService()`.
--- ```lua
--- DragonEngine:LoadServicesIn(ServerScriptService.Services)
--- ```
--- :::caution
--- Only modules that are children of a `Model` or `Folder` instance will be considered for lazy-loading. Other instance types
--- are not supported at this time.
--- :::
---
--- @private
--- @param Container Folder -- The folder that contains the service modules
--- @return nil
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:LoadServicesIn(Container)
	for _,ServiceModule in pairs(Boilerplate.RecurseFind(Container,"ModuleScript")) do
		DragonEngineServer:LoadService(ServiceModule)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Unloads the specified service from the framework and destroys any remotes/bindables it created.
--- This API will attempt to call `DragonEngine:StopService()` with the service before unloading it, to clean state.
--- ```lua
--- local Success,Error = DragonEngine:UnloadService("MemeService")
--- if not Success then
--- 	print("Failed to unload memeservice : " .. Error)
--- end
--- ```
---
--- @private
--- @param ServiceName string -- The name of the service to unload
--- @return bool -- A `bool` describing whether or not the service was successfully unloaded
--- @return string -- A `string` containing the error message if the service fails to be unloaded. Is `nil` if unloading succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:UnloadService(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName ~= nil,"[Dragon Engine Server] UnloadService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName) == "string","[Dragon Engine Server] UnloadService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName] ~= nil,"[Dragon Engine Server] UnloadService() : No service with the name '"..ServiceName.."' is loaded!")

	-------------
	-- DEFINES --
	-------------
	local Service = self.Services[ServiceName]

	--------------------------
	-- Stopping the service --
	--------------------------
	if Service.Status == "Running" then
		self:StopService(ServiceName)
	end

	---------------------------
	-- Unloading the service --
	---------------------------
	self:Log("Unloading service '"..ServiceName.."'...")

	if typeof(Service.Unload) == "function" then --The service has an unload function, run it to allow the service to clean state.
		local Success,Error = pcall(function()
			Service:Unload()
		end)
		if not Success then --Unloading the service failed.
			self:Log("Service '"..ServiceName.."' unload function failed, a memory leak is possible. : "..Error,"Warning")
			return false,Error
		end
	else --The service had no unload function. Warn about potential memory leaks.
		self:Log("Service '"..ServiceName.."' had no unload function, a memory leak is possible.","Warning")
	end

	if Service._EndpointFolder ~= nil then --Destroy service endpoints
		Service._EndpointFolder:Destroy() 
	end
	Service._ServerEventsFolder:Destroy() --Destroy service server events
	self.Services[ServiceName] = nil

	self:Log("Service '"..ServiceName.."' unloaded.")
	ServiceUnloaded_ClientEvent:FireAllClients(ServiceName)

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Calls `:Init()` on the specified service.
--- ```lua
--- local Success,Error = DragonEngine:InitializeService("MarketService")
--- if not Success then
--- 	print("Failed to initialize marketservice : " .. Error)
--- end
--- ```
---
--- @private
--- @param ServiceName string -- The name of the service to initialize
--- @return bool -- A `bool` describing whether or not the service was successfully initialized
--- @return string -- A `string` containing the error message if the service fails to be initialized. Is `nil` if initialization succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:InitializeService(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName ~= nil,"[Dragon Engine Server] InitializeService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName) == "string","[Dragon Engine Server] InitializeService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName] ~= nil,"[Dragon Engine Server] InitializeService() : No service with the name '"..ServiceName.."' is loaded!")
	assert(self.Services[ServiceName].Initialized == false,"[Dragon Engine Server] InitializeService() : Service '"..ServiceName.."' is already initialized!")

	-------------
	-- DEFINES --
	-------------
	local Service = self.Services[ServiceName]

	------------------------------
	-- Initializing the service --
	------------------------------
	self:DebugLog("Initializing service '"..ServiceName.."'...")

	if type(Service.Init) == "function" then --An init() function exists, run it.
		local Success,Error = pcall(function()
			Service:Init()
		end)
		if not Success then -- Initialization failed
			DragonEngineServer:Log("Failed to initialize service '"..ServiceName.."' : "..Error,"Warning")
			return false,Error
		end

		Service.Status = "Stopped"
		Service.Initialized = true
	else --Init function doesn't exist
		self:DebugLog("Service '"..ServiceName.."' could not be initilized, no init function was found!","Warning")
	end

	self:DebugLog("Service '"..ServiceName.."' initialized.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Calls `:Start()` on the specified service.
--- ```lua
--- local Success,Error = DragonEngine:StartService("MarketService")
--- if not Success then
--- 	print("Failed to start marketservice : " .. Error)
--- end
--- ```
---
--- @private
--- @param ServiceName string -- The name of the service to start
--- @return bool -- A `bool` describing whether or not the service was successfully started.
--- @return string -- A `string` containing the error message if the service fails to successfully start. Is `nil` if start was successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:StartService(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName ~= nil,"[Dragon Engine Server] StartService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName) == "string","[Dragon Engine Server] StartService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName] ~= nil,"[Dragon Engine Server] StartService() : No service with the name '"..ServiceName.."' is loaded!")
	assert(self.Services[ServiceName].Status ~= "Running","[Dragon Engine Server] StartService() : The service '"..ServiceName.."' is already running!")
	assert(self.Services[ServiceName].Initialized == true,"[Dragon Engine Server] StartService() : The service '"..ServiceName.."' was not initialized!")

	-------------
	-- DEFINES --
	-------------
	local Service = self.Services[ServiceName]

	------------------------------
	-- Initializing the service --
	------------------------------
	self:DebugLog("Starting service '"..ServiceName.."'...")
	if type(Service.Start) == "function" then --An init() function exists, run it.
		local Success,Error = pcall(function()
			coroutine.wrap(Service.Start)(Service)
		end)
		if not Success then
			DragonEngineServer:Log("Failed to start service '"..ServiceName.."' : "..Error,"Warning")
			return false,Error
		end
	else --Start function doesn't exist
		self:DebugLog("Service '"..ServiceName.."' could not be started, no start function was found!","Warning")
	end
	Service.Status = "Running"
	self:DebugLog("Service '"..ServiceName.."' started.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Calls `:Stop()` on the specified service
--- ```lua
--- local Success,Error = DragonEngine:StopService("MarketService")
--- if not Success then
--- 	print("Failed to stop marketservice : " .. Error)
--- end
--- ```
---
--- @private
--- @param ServiceName string -- The name of the service to stop
--- @return bool -- A `bool` describing whether or not the service was successfully stopped
--- @return string -- A `string` containing the error message if the service fails to stop. Will be `nil` if the stop is successful.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:StopService(ServiceName)
	----------------
	-- Assertions --
	----------------
	assert(ServiceName ~= nil,"[Dragon Engine Server] StopService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName) == "string","[Dragon Engine Server] StopService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName] ~= nil,"[Dragon Engine Server] StopService() : No service with the name '"..ServiceName.."' is loaded!")
	assert(self.Services[ServiceName].Status == "Running","[Dragon Engine Server] StopService() : The service '"..ServiceName.."' is already stopped!")

	-------------
	-- DEFINES --
	-------------
	local Service = self.Services[ServiceName]

	------------------------------
	-- Stopping the service --
	------------------------------
	self:DebugLog("Stopping service '"..ServiceName.."'...")
	if type(Service.Stop) == "function" then --A stop() function exists, run it.
		local Success,Error = pcall(function()
			Service:Stop()
		end)
		if not Success then
			DragonEngineServer:Log("Failed to stop service '"..ServiceName.."' : "..Error,"Warning")
			return false,Error
		end
		Service.Status = "Stopped"
	else --Stop function doesn't exist
		self:DebugLog("Service '"..ServiceName.."' could not be stopped, no stop function was found!","Warning")
	end
	
	self:DebugLog("Service '"..ServiceName.."' stopped.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Registers a RemoteFunction for the calling service that the server can invoke to get client information.
--- ```lua
--- local MyRemote = DragonEngine:RegisterClientEndpoint("MyRemote")
--- local LikesJazz = MyRemote:InvokeClient(Player,"Do ya like jazz?")
--- ```
--- :::warning
--- This API should only be called from a service! Calling it outside of a service will cause errors.
--- :::
--- :::caution
--- Use with caution! Using the client as a source of truth is dangerous and often bad practice.
--- :::
---
--- @param EndpointName string -- The name to assign to the endpoint
--- @return RemoteFunction -- The RemoteFunction that was registered with the framework
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:RegisterClientEndpoint(EndpointName)
	
	----------------
	-- Assertions --
	----------------
	assert(EndpointName ~= nil, "[Dragon Engine Server] RegisterClientEndpoint() : string Expected for 'EndpointName', got nil instead.")
	assert(typeof(EndpointName) == "string", "[Dragon Engine Server] RegisterClientEndpoint() : string expected for 'EndpointName', got "..typeof(EndpointName).." instead.")

	local RemoteFunction = Instance.new('RemoteFunction')
		  RemoteFunction.Name = EndpointName
		  RemoteFunction.Parent = self._ClientEndpointFolder

	self:DebugLog("Registered client endpoint '"..EndpointName.."' for service '"..self.Name.."'")

	return RemoteFunction
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Registers a RemoteEvent for the calling service that the server can fire to clients.
--- ```lua
--- local AnnouncementRemote = DragonEngine:RegisterServiceClientEvent("AnnouncementMade")
--- AnnouncementRemote:FireAllClients("Teh epic duck is coming!!!")
--- ```
--- :::warning
--- This API should only be called from a service! Calling it outside of a service will cause errors.
--- :::
---
--- @param Name string -- The name to assign to the RemoteEvent
--- @return RemoteEvent -- The RemoteEvent that was registered with the framework
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:RegisterServiceClientEvent(Name)

	----------------
	-- Assertions --
	----------------
	assert(Name ~= nil,"[Dragon Engine Server] RegisterServiceClientEvent() : string expected for 'Name', got nil instead.")
	assert(typeof(Name) == "string","[Dragon Engine Server] RegisterServiceClientEvent() : string expected for 'ame', got "..typeof(Name).." instead.")

	local RemoteEvent = Instance.new('RemoteEvent')
	      RemoteEvent.Name = Name
	      RemoteEvent.Parent = self._EndpointFolder

	self:DebugLog("Registered client event '"..Name.."' for service '"..self.Name.."'")

	return RemoteEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Registers a BindableEvent for the calling service that it can use to fire server-side events.
--- ```lua
--- local ItemSpawnedBindable = DragonEngine:RegisterServiceServerEvent("ItemSpawned")
--- ItemSpawnedBindable:Fire(ItemID,ItemPosition)
--- ```
--- :::warning
--- This API should only be called from a service! Calling it outside of a service will cause errors.
--- :::
---
--- @param Name string -- The name to assign to the BindableEvent
--- @return BindableEvent -- The BindableEvent that was registered with the framework
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:RegisterServiceServerEvent(Name)

	----------------
	-- Assertions --
	----------------
	assert(Name ~= nil,"[Dragon Engine Server] RegisterServiceServerEvent() : string expected for 'Name', got nil instead.")
	assert(typeof(Name) == "string","[Dragon Engine Server] RegisterServiceServerEvent() : string expected for 'ame', got "..typeof(Name).." instead.")

	local BindableEvent = Instance.new('BindableEvent')
	      BindableEvent.Name = Name
	      BindableEvent.Parent = self._ServerEventsFolder
	self[Name] = BindableEvent.Event

	self:DebugLog("Registered server event '"..Name.."' for service '"..self.Name.."'")

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Runs the framework. Services will be loaded & ran from the service locations specified in the framework's settings,
--- and modules will be marked for lazyloading from the locations specified in the framework's settings.
--- ```lua
--- DragonEngine:Run()
--- ```
---
--- :::warning
--- This API should only be called once! Calling it more than once will result in unstable behavior.
--- :::
--- :::warning
--- If the framework is accessed before this API is ran, nothing will have been initialized!
--- :::
---
--- @param FrameworkSettings FrameworkSettings -- The settings to configure the framework's behavior
--- @return nil
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngineServer:Run(FrameworkSettings)

	----------------------
	-- Loading settings --
	----------------------
	if FrameworkSettings ~= nil then
		for ModuleLocationType,ModulePaths in pairs(FrameworkSettings.ServerPaths.ModulePaths) do
			if CurrentFrameworkSettings.ServerPaths.ModulePaths[ModuleLocationType] == nil then
				CurrentFrameworkSettings.ServerPaths.ModulePaths[ModuleLocationType] = {}
			end

			for _,ModulePath in pairs(ModulePaths) do
				table.insert(CurrentFrameworkSettings.ServerPaths.ModulePaths[ModuleLocationType],ModulePath)
			end
		end

		for _,ServicePath in pairs(FrameworkSettings.ServerPaths.ServicePaths) do
			table.insert(CurrentFrameworkSettings.ServerPaths.ServicePaths,ServicePath)
		end

		CurrentFrameworkSettings.ShowLogoInOutput = FrameworkSettings.ShowLogoInOutput
		CurrentFrameworkSettings.Debug = FrameworkSettings.Debug
	end

	if CurrentFrameworkSettings.ShowLogoInOutput then
		self:Log(ENGINE_LOGO)
	end

	self:DebugLog("[Dragon Engine Server] Debug enabled. Logging will be verbose.","Warning")

	---------------------
	-- Loading modules --
	---------------------
	self:Log("")
	self:Log("**** Loading modules ****")
	self:Log("")
	for _,ModulePaths in pairs(CurrentFrameworkSettings.ServerPaths.ModulePaths) do
		for _,ModulePath in pairs(ModulePaths) do
			self:LazyLoadModulesIn(ModulePath)
		end
	end
	self:Log("All modules lazy-loaded!")

	-------------------------------------------------
	--  Loading, initializing and running services --
	-------------------------------------------------
	self:Log("")
	self:Log("**** Loading services ****")
	self:Log("")
	for _,ServicePath in pairs(CurrentFrameworkSettings.ServerPaths.ServicePaths) do
		self:LoadServicesIn(ServicePath)
	end
	self:Log("All services loaded!")

	self:Log("")
	self:Log("**** Initializing services ****")
	self:Log("")
	for ServiceName,_ in pairs(DragonEngineServer.Services) do
		self:InitializeService(ServiceName)
	end
	self:Log("All services initialized!")

	self:Log("")
	self:Log("**** Starting services ****")
	self:Log("")
	for ServiceName,Service in pairs(DragonEngineServer.Services) do
		if Service.Initialized then
			DragonEngineServer:StartService(ServiceName)
		end
	end
	self:Log("All services running!")

	------------------------------------------
	-- Indicating that the engine is loaded --
	------------------------------------------
	local Engine_Loaded = Instance.new('BoolValue')
	Engine_Loaded.Name = "_Loaded"
	Engine_Loaded.Value = true
	Engine_Loaded.Parent = script.Parent.Parent.Parent

	shared.DragonEngine = DragonEngineServer
	self:Log("Dragon Engine "..DragonEngineServer.Version.." loaded!")
end

return DragonEngineServer