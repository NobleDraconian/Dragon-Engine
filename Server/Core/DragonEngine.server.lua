--[[
	Dragon Engine Server

	Global backend engine for Phoenix Entertainment, LLC.

	Version : 2.1.0

	Programmed, designed and developed by @Reshiram110
	Inspiration by @Crazyman32's 'Aero' framework
--]]

---------------------
-- Roblox Services --
---------------------
local Workspace=game:GetService("Workspace")
local ServerStorage=game:GetService("ServerStorage")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")

--------------
-- REQUIRES --
--------------
local ENGINE_LOGO=require(ReplicatedStorage.DragonEngine.Logo)

-------------
-- DEFINES --
-------------
local DragonEngine={
	Utils={}, --Contains all of the utilities being used
	Classes={}, --Contains all of the classes being used
	Services={}, --Contains all services, both running and stopped
	Enum={}, --Contains all custom Enums.

	Version="2.2.0"
	--Logs={}
}
local Engine_Settings; --Holds the engines settings.
Instance.new('Folder',ReplicatedStorage.DragonEngine).Name="Network"

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERNAL FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Recurse
-- @Description : Returns all items in a folder/model/table and all of its subfolders/submodels/subtables.
--                If it is a table, it returns all items in a table and all items in all of its sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
-- @Returns : table "Items" - A table containing all of the items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Recurse(Root)
	local Items={}

	if typeof(Root)=="Instance" then --Root is an instance, make sure it is a model or a folder.

		if Root:IsA("Model") or Root:IsA("Folder") then --It's a folder or a model.
			for _,Object in pairs(Root:GetChildren()) do
				if Object:IsA("Folder") then --Recurse through this subfolder.
					local SubObjects=Recurse(Object)
					for _,SubObject in pairs(SubObjects) do
						table.insert(Items,SubObject)
					end
				else --Just a regular instance, add it to the items list.
					table.insert(Items,Object)
				end
			end
		end

	elseif typeof(Root)=="table" then --Root is a table.

		for _,Item in pairs(Root) do
			if typeof(Item)=="table" then --Recurse through this subtable.
				local SubItems=Recurse(Item)
				for _,SubItem in pairs(SubItems) do
					table.insert(Items,SubItem)
				end
			else --Just a regular value, add it to the items list.
				table.insert(Items,Item)
			end
		end

	end

	return Items
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RecurseFind
-- @Description : Returns all items of a given type in a folder/model and all of its subfolders/submodels.
--                If it is a table, it returns all items of a given type in a table and all items in all of its
--                sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
--           Variant "ItemType" - The type of the item to search for.
-- @Returns : table "Items" - A table containing all of the found items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RecurseFind(Root,ItemType)
	local Items={}

	if typeof(Root)=="Instance" then
		if Root:IsA("Folder") or Root:IsA("Model") then
			for _,Item in pairs(Recurse(Root)) do
				if Item:IsA(ItemType) then table.insert(Items,Item) end
			end
		end
	elseif typeof(Root)=="table" then
		for _,Item in pairs(Recurse(Root)) do
			if typeof(Item)==ItemType then table.insert(Items,Item) end
		end
	end

	return Items
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RecurseFilter
-- @Description : Returns all items that are NOT a given type in a folder/model and all of its subfolders/submodels.
--                If it is a table, it returns all items that are NOT a given type in a table and all items in all
--                of its sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
--           Variant "ItemType" - The type of the item to filter.
-- @Returns : table "Items" - A table containing all of the filtered items.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RecurseFilter(Root,ItemType)
	local Items={}

	if typeof(Root)=="Instance" then
		if Root:IsA("Folder") or Root:IsA("Model") then
			for _,Item in pairs(Recurse(Root)) do
				if not Item:IsA(ItemType) then table.insert(Items,Item) end
			end
		end
	elseif typeof(Root)=="table" then
		for _,Item in pairs(Recurse(Root)) do
			if typeof(Item)~=ItemType then table.insert(Items,Item) end
		end
	end

	return Items
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadModules
-- @Description : Loads all modules in the specified folder into the specified table.
-- @Params : table "Table" - The table to lazyload the modules into
--           Instance <Folder> "Folder" - The Folder to load the modules from
--           bool "ExposeEngine" - If set to true, DragonEngine{} will be directly exposed to the modules.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function LoadModules(Table,Folder,ExposeEngine)
	for _,ModuleScript in pairs(RecurseFind(Folder,"ModuleScript")) do
		DragonEngine:DebugLog("Loading module '"..Folder.Name.."."..ModuleScript.Name.."'...")
		local Module;
		local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
			Module=require(ModuleScript)
		end)

		if not Success then
			DragonEngine:Log("Failed to load module '"..Folder.Name.."."..ModuleScript.Name.."' : "..Error,"Warning")
		else
			if ExposeEngine then
				setmetatable(Module,{__index=DragonEngine}) --Giving the module access to Dragon Engine directly
			end
			Table[ModuleScript.Name]=Module
			DragonEngine:DebugLog("Module '"..Folder.Name.."."..ModuleScript.Name.."' loaded.")
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LazyLoadModules
-- @Description : Lazy loads all modules in the specified folder into the specified table when the modules are
--                called.
-- @Params : table "Table" - The table to lazyload the modules into
--           Instance <Folder> "Folder" - The Folder to lazy load the modules from
--           bool "ExposeEngine" - If set to true, DragonEngine{} will be directly exposed to the modules.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function LazyLoadModules(Table,Folder,ExposeEngine)
	setmetatable(Table,{
		__index=function(t,ModuleName)
			local Module;
			local s,m=pcall(function() --If the module fails to load/errors, we want to keep the engine going
				for _,mod in pairs(RecurseFind(Folder,"ModuleScript")) do
					if mod.Name==ModuleName then
						Module=require(mod)
					end
				end
			end)

			if not s then
				DragonEngine:Log("Failed to lazyload module '"..Folder.Name.."."..ModuleName.."' : "..m,"Warning")
				return nil
			else
				if ExposeEngine then
					setmetatable(Module,{__index=DragonEngine}) --Giving the module access to Dragon Engine directly
				end
				DragonEngine:DebugLog("Module '"..Folder.Name.."."..ModuleName.."' lazyloaded.")
				Table[ModuleName]=Module
				return Module
			end
		end
	})
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadServices
-- @Description : Loads all service modules from the specified path into the engine.
-- @Params : Instance <Folder> "Folder" - The folder to load the modules from.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadServices(Folder)
	for _,ServiceModule in pairs(RecurseFind(Folder,"ModuleScript")) do
		if ServiceModule:IsA("ModuleScript") and ServiceModule:FindFirstChild("Disabled")==nil then
			local ServiceLoaded=DragonEngine:LoadService(ServiceModule)

			if ServiceLoaded then
				local Service=DragonEngine:GetService(ServiceModule.Name)
				if type(Service.Init)=="function" then --An init() function exists, run it.
					DragonEngine:DebugLog("Initializing service '"..ServiceModule.Name.."'...")

					local Success,Error=pcall(function()
						Service:Init()
					end)

					if not Success then
						DragonEngine:Log("Failed to initialize service '"..ServiceModule.Name.."' : "..Error,"Warning")
						DragonEngine:UnloadService(ServiceModule.Name)
					end
				end
			end
		end
	end
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetOutput
-- @Description : Returns output from the engine.
-- @Params : Variant "Value" - The value(s) for the engine to return from this call.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetOutput(...)
	local Values={...}
	local OutputString="{"

	for Index,Param in pairs(Values) do
		OutputString=OutputString..tostring(Param)
		if Values[Index+1]~=nil then OutputString=OutputString..", " end
	end
	OutputString=OutputString.."}"
	return "DRAGON_ENGINE_OUTPUT -> "..OutputString
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENGINE LOGGING
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Log
-- @Description : Adds the specified text to the engine logs.
-- @Params : string "LogMessage" - The message to add to the logs
--           DragonEngine Enum "LogMessageType" - The type of message being logged
-- @TODO : Design and implement custom logging system with UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:Log(LogMessage,LogMessageType)
	if LogMessage==nil then
		print("")
		return
	end
	if LogMessageType=="warning" or LogMessageType=="Warning" then
		warn("[Dragon Engine Server] "..LogMessage)
	elseif LogMessageType=="error" or LogMessageType=="Error" then
		error("[Dragon Engine Server] "..LogMessage)
	else
		print("[Dragon Engine Server] "..LogMessage)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : DebugLog
-- @Description : Adds the specified text to the engine logs, and will only dispay if debug is set to true.
-- @Params : string "LogMessage" - The message to add to the logs
--           DragonEngine Enum "LogMessageType" - The type of message being logged
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:DebugLog(LogMessage,LogMessageType)
	if Engine_Settings["Debug"] then
		if LogMessage==nil then
			print("")
			return
		end
		if LogMessageType=="warning" or LogMessageType=="Warning" then
			warn("[Dragon Engine Server] "..LogMessage)
		elseif LogMessageType=="error" or LogMessageType=="Error" then
			error("[Dragon Engine Server] "..LogMessage)
		else
			print("[Dragon Engine Server] "..LogMessage)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------
-- DEFINES --
-------------
local Service_Endpoints=Instance.new('Folder',ReplicatedStorage.DragonEngine.Network) --A folder containing the remote functions/events for services with client APIs.
Service_Endpoints.Name="Service_Endpoints"
local Service_Events=Instance.new('Folder',ServerScriptService.DragonEngine) --A folder containing the server sided events for services.
Service_Events.Name="Service_Events"

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: GetService
-- @Description : Returns the requested service.
--                Similiar to game:GetService().
-- @Params : string "ServiceName" - The name of the service to retrieve
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetService(ServiceName)
	assert(DragonEngine.Services[ServiceName]~=nil,"[Dragon Engine Server] GetService() : Service '"..ServiceName.."' was not loaded or does not exist.")
	return DragonEngine.Services[ServiceName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadService
-- @Description : Loads the specified service module into the engine. Returns false if the service fails to load.
-- @Params : Instance <ModuleScript> "ServiceModule" - The service module to load into the engine
-- @Returns : Boolean "ServiceLoaded" - Will be TRUE if the service is loaded successfully, will be FALSE if the service failed to load.
--            string "ErrorMessage" - The error message if loading the service failed. Is nil if loading succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadService(ServiceModule)

	----------------
	-- Assertions --
	----------------
	assert(ServiceModule~=nil,"[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got nil instead.")
	assert(typeof(ServiceModule)=="Instance","[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got "..typeof(ServiceModule).." instead.")
	assert(ServiceModule:IsA("ModuleScript"),"[Dragon Engine Server] LoadService() : ModuleScript expected for 'ServiceModule', got "..ServiceModule.ClassName.." instead.")
	assert(self.Services[ServiceModule.Name]==nil,"[Dragon Engine Server] LoadService() : A service with the name '"..ServiceModule.Name.."' is already loaded!")

	-------------
	-- DEFINES --
	-------------
	local ServiceName=ServiceModule.Name
	local Service; --Table holding the service

	-------------------------
	-- Loading the service --
	------------------------
	self:DebugLog("Loading service '"..ServiceModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Service=require(ServiceModule)
	end)
	if not Success then --Service module failed to load
		self:Log("Failed to load service '"..ServiceName.."' : "..Error,"Warning")
		return false,Error
	else --Service module was loaded

		----------------------------------
		-- Generating service endpoints --
		----------------------------------
		if Service.Client~=nil then --The service has client APIs
			local EndpointFolder=Instance.new('Folder',Service_Endpoints);EndpointFolder.Name=ServiceName --Container for remote functions/events so clients can access the service client API.

			for FunctionName,Function in pairs(Service.Client) do
				if type(Function)=="function" then
					local RemoteFunction=Instance.new('RemoteFunction',EndpointFolder);RemoteFunction.Name=FunctionName

					RemoteFunction.OnServerInvoke=function(...)
						return Function(Service.Client,...) --Service.Client is passed since `self` needs to be manually defined
					end
					self:DebugLog("Registered endpoint '"..ServiceName.."."..FunctionName.."'")
				end
			end
			Service._EndpointFolder=EndpointFolder
		end

		---------------------------------------------
		-- Adding service to DragonEngine.Services --
		---------------------------------------------
		local EventsFolder=Instance.new('Folder',Service_Events);EventsFolder.Name=ServiceName --Container for server sided events for this service

		Service.Name=ServiceName
		Service.Status="Uninitialized"
		Service._ServerEventsFolder=EventsFolder

		setmetatable(Service,{__index=DragonEngine}) --Exposing Dragon Engine to the service
		self.Services[ServiceName]=Service

		self:DebugLog("Service '"..ServiceName.."' loaded.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadServicesIn
-- @Description : Loads all services in the given container.
-- @Params : Instance "Container" - The container holding all of the service modules.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadServicesIn(Container)
	for _,ServiceModule in pairs(RecurseFind(Container,"ModuleScript")) do
		DragonEngine:LoadService(ServiceModule)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : UnloadService
-- @Description : Unloads the specified service from the engine and destroys any endpoints/events it created.
-- @Params : string "ServiceName" - The name of the service to unload.
-- @Returns : Boolean "ServiceUnloaded" - Will be TRUE if the service is unloaded successfully, will be FALSE if the service failed to unload.
--            string "ErrorMessage" - The error message if unloading the service failed. Is nil if unloading succeeded.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:UnloadService(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName~=nil,"[Dragon Engine Server] UnloadService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName)=="string","[Dragon Engine Server] UnloadService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName]~=nil,"[Dragon Engine Server] UnloadService() : No service with the name '"..ServiceName.."' is loaded!")

	-------------
	-- DEFINES --
	-------------
	local Service=self.Services[ServiceName]

	---------------------------
	-- Unloading the service --
	---------------------------
	self:Log("Unloading service '"..ServiceName.."'...")
	if typeof(Service.Unload)=="function" then --The service has an unload function, run it to allow the service to clean state.
		local Success,Error=pcall(function()
			Service:Unload()
		end)
		if not Success then --Unloading the service failed.
			self:Log("Service '"..ServiceName.."' unload function failed : "..Error,"Warning")
				return false,Error
		end
	else --The service had no unload function. Warn about potential memory leaks.
		self:Log("Service '"..ServiceName.."' had no unload function, a memory leak is possible.","Warning")
	end

	if Service._EndpointFolder~=nil then Service._EndpointFolder:Destroy() end --Destroy service endpoints
	Service._ServerEventsFolder:Destroy() --Destroy service server events
	self.Services[ServiceName]=nil

	self:Log("Service '"..ServiceName.."' unloaded.")
	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : InitializeService
-- @Description : Initializes the specified service.
-- @Params : string "ServiceName" - The name of the service to initialize
-- @Returns : bool "Success" - Whether or not the service was successfully initialized.
--            string "Error" - The error message if the initialization failed. Is nil if initialization succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:InitializeService(ServiceName)

	----------------
	-- Assertions --
	----------------
	assert(ServiceName~=nil,"[Dragon Engine Server] InitializeService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName)=="string","[Dragon Engine Server] InitializeService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName]~=nil,"[Dragon Engine Server] InitializeService() : No service with the name '"..ServiceName.."' is loaded!")

	-------------
	-- DEFINES --
	-------------
	local Service=self.Services[ServiceName]

	------------------------------
	-- Initializing the service --
	------------------------------
	self:DebugLog("Initializing service '"..ServiceName.."'...")
	if type(Service.Init)=="function" then --An init() function exists, run it.
		local Success,Error=pcall(function()
			Service:Init()
		end)
		if not Success then
			DragonEngine:Log("Failed to initialize service '"..ServiceName.."' : "..Error,"Warning")
			return false,Error
		end
		Service.Status="Stopped"
	else --Init function doesn't exist
		self:DebugLog("Service '"..ServiceName.."' could not be initilized, no init function was found!","Warning")
	end
	
	self:DebugLog("Service '"..ServiceName.."' initialized.")

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StartService
-- @Description : Starts the specified service.
-- @Params : bool "Success" - Whether or not the service was successfully started.
--           string "Error" - The error message if starting the service failed. Is nil if the start succeeded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:StartService(ServiceName)
	----------------
	-- Assertions --
	----------------
	assert(ServiceName~=nil,"[Dragon Engine Server] StartService() : string expected for 'ServiceName', got nil instead.")
	assert(typeof(ServiceName)=="string","[Dragon Engine Server] StartService() : string expected for 'ServiceName', got "..typeof(ServiceName).." instead.")
	assert(self.Services[ServiceName]~=nil,"[Dragon Engine Server] StartService() : No service with the name '"..ServiceName.."' is loaded!")
	assert(self.Services[ServiceName].Status~="Running","[Dragon Engine Server] StartService() : The service '"..ServiceName.."' is already running!")

	-------------
	-- DEFINES --
	-------------
	local Service=self.Services[ServiceName]

	------------------------------
	-- Initializing the service --
	------------------------------
	self:DebugLog("Starting service '"..ServiceName.."'...")
	if type(Service.Start)=="function" then --An init() function exists, run it.
		local Success,Error=pcall(function()
			coroutine.wrap(Service.Start)(Service)
		end)
		if not Success then
			DragonEngine:Log("Failed to start service '"..ServiceName.."' : "..Error,"Warning")
			return false,Error
		end
	else --Start function doesn't exist
		self:DebugLog("Service '"..ServiceName.."' could not be started, no start function was found!","Warning")
	end
	self:DebugLog("Service '"..ServiceName.."' started.")
	Service.Status="Running"

	return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterServiceClientEvent
-- @Description : Registers a client event for the service calling. MUST BE CALLED FROM INSIDE A SERVICE MODULE.
-- @Params : string "Name" - The name to assign to the client event.
-- @Returns : Instance <RemoteEvent> "RemoteEvent" - The service client event.
-- @TODO : Create endpoint folder for service if it doesn't exist.
--         This occurs when the service has no endpoint functions, but has client events.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterServiceClientEvent(Name)

	----------------
	-- Assertions --
	----------------
	assert(Name~=nil,"[Dragon Engine Server] RegisterServiceClientEvent() : string expected for 'Name', got nil instead.")
	assert(typeof(Name)=="string","[Dragon Engine Server] RegisterServiceClientEvent() : string expected for 'ame', got "..typeof(Name).." instead.")

	local RemoteEvent=Instance.new('RemoteEvent')
	RemoteEvent.Name=Name
	RemoteEvent.Parent=self._EndpointFolder

	self:DebugLog("Registered client event '"..Name.."' for service '"..self.Name.."'")

	return RemoteEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterServiceServerEvent
-- @Description : Registers a server event for the service calling. MUST BE CALLED FROM INSIDE A SERVICE MODULE.
-- @Params : string "Name" - The name to assign to the server event.
-- @Retruns : Instance <BindableEvent> "BindableEvent" - The service server event.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterServiceServerEvent(Name)

	----------------
	-- Assertions --
	----------------
	assert(Name~=nil,"[Dragon Engine Server] RegisterServiceServerEvent() : string expected for 'Name', got nil instead.")
	assert(typeof(Name)=="string","[Dragon Engine Server] RegisterServiceServerEvent() : string expected for 'ame', got "..typeof(Name).." instead.")

	local BindableEvent=Instance.new('BindableEvent')
	BindableEvent.Name=Name
	BindableEvent.Parent=self._ServerEventsFolder
	self[Name]=BindableEvent.Event

	self:DebugLog("Registered server event '"..Name.."' for service '"..self.Name.."'")

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLASSES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadClass
-- @Description : Loads the specified class module into the engine.
-- @Params : Instance <ModuleScript>  "ClassModule" - The class module to load into the engine
-- @Returns : bool "Success" - Is true if the class module was loaded successfully. Is false if it was not loaded successfully.
--            string "Error" - The error message if loading fails. Is nil if loading succeeds.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadClass(ClassModule)

	----------------
	-- Assertions --
	----------------
	assert(ClassModule~=nil,"[Dragon Engine Server] LoadClass() : ModuleScript expected for 'ClassModule', got nil instead.")
	assert(typeof(ClassModule)=="Instance","[Dragon Engine Server] LoadClass() : ModuleScript expected for 'ClassModule', got "..typeof(ClassModule).." instead.")
	assert(ClassModule:IsA("ModuleScript"),"[Dragon Engine Server] LoadClass) : ModuleScript expected for 'ClassModule', got "..ClassModule.ClassName.." instead.")
	assert(self.Classes[ClassModule.Name]==nil,"[Dragon Engine Server] LoadClass() : A class with the name '"..ClassModule.Name.."' is already loaded!")

	-------------
	-- DEFINES --
	-------------
	local ClassName=ClassModule.Name
	local Class; --Table holding the class

	-----------------------
	-- Loading the class --
	-----------------------
	self:DebugLog("Loading class '"..ClassModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Class=require(ClassModule)
	end)
	if not Success then
		DragonEngine:Log("Failed to load class '"..ClassName.."' : "..Error,"Warning")
		return false,Error
	else
		DragonEngine.Classes[ClassName]=Class
		DragonEngine:DebugLog("Loaded Class '"..ClassName.."'.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadClassesIn
-- @Description : Loads all class modules in the given container.
-- @Params : Instance "Container" - The container that holds all of the class modules.
-- @TODO : PICK UP HERE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadClassesIn(Container)
	for _,ModuleScript in pairs(RecurseFind(Container,"ModuleScript")) do
		self:LoadClass(ModuleScript)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTILITIES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadUtility
-- @Description : Loads the specified utility module into the engine.
-- @Params : Instance <ModuleScript> "UtilModule" - The utility module to load into the engine
-- @Returns : bool "Success" - Is true if the utility module was loaded successfully. Is false if it was not loaded successfully.
--            string "Error" - The error message if loading fails. Is nil if loading succeeds.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadUtility(UtilModule)

	----------------
	-- Assertions --
	----------------
	assert(UtilModule~=nil,"[Dragon Engine Server] LoadUtility() : ModuleScript expected for 'UtilModule', got nil instead.")
	assert(typeof(UtilModule)=="Instance","[Dragon Engine Server] LoadUtility() : ModuleScript expected for 'Utilodule', got "..typeof(UtilModule).." instead.")
	assert(UtilModule:IsA("ModuleScript"),"[Dragon Engine Server] LoadUtility) : ModuleScript expected for 'UtilModule', got "..UtilModule.ClassName.." instead.")
	assert(self.Utils[UtilModule.Name]==nil,"[Dragon Engine Server] LoadUtility() : A utility with the name '"..UtilModule.Name.."' is already loaded!")

	-------------
	-- DEFINES --
	-------------
	local UtilName=UtilModule.Name
	local Util;

	-------------------------
	-- Loading the utility --
	-------------------------
	self:DebugLog("Loading utility '"..UtilModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going.
		Util=require(UtilModule)
	end)
	if not Success then
		DragonEngine:Log("Failed to load utility '"..UtilName.."' : "..Error,"Warning")
		return false,Error
	else
		self.Utils[UtilName]=Util
		self:DebugLog("Loaded Utility : '"..UtilName.."'.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadUtilitiesIn
-- @Description : Loads all utility modules in the given container.
-- @Params : Instance "Container" - The container that holds all of the utility modules.
-- @TODO : PICK UP HERE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadUtilitiesIn(Container)
	for _,ModuleScript in pairs(RecurseFind(Container,"ModuleScript")) do
		self:LoadUtility(ModuleScript)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENUMS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : DefineEnum
-- @Description : Creates an enum with the given name.
-- @Params : string "EnumName" - The name of the enum
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:DefineEnum(EnumName,EnumTable)

	local function GetEnumItems(CustomEnum)
		local EnumItems={}

		for EnumItemName,EnumItemValue in pairs(CustomEnum) do
			if type(EnumItemValue)=="table" then
				for i,v in pairs(GetEnumItems(EnumItemValue)) do
					table.insert(EnumItems,v)
				end
			else
				table.insert(EnumItemValue)
			end
		end

		return EnumItems
	end


	self.Enum[EnumName]=EnumTable
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENGINE INIT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------
-- Set up environment --
------------------------

----------------------
-- Loading Settings --
----------------------
--[[ Load default settings ]]--
local SettingsSuccess,SettingsError=pcall(function()
	Engine_Settings=require(ReplicatedStorage.DragonEngine.Settings.EngineSettings)
	Engine_Settings["Paths"]=require(ReplicatedStorage.DragonEngine.Settings.ServerPaths)
end)
assert(SettingsSuccess==true, SettingsSuccess==true or "[Dragon Engine Server] An error occured while loading settings : "..SettingsError)

--[[ Load user settings ]]--
if ReplicatedStorage:FindFirstChild("DragonEngine_UserSettings")~=nil then
	local SettingsFolder=ReplicatedStorage.DragonEngine_UserSettings

	local SettingsSuccess,SettingsError=pcall(function()
		if SettingsFolder:FindFirstChild("EngineSettings")~=nil then
			local EngineSettings=require(SettingsFolder.EngineSettings)

			for SettingName,SettingValue in pairs(EngineSettings) do
				if typeof(SettingValue)~="table" then
					Engine_Settings[SettingName]=SettingValue
				else
					for Key,Val in pairs(SettingValue) do
						Engine_Settings[SettingName][Key]=Val
					end
				end
			end
		end

		if SettingsFolder:FindFirstChild("ServerPaths")~=nil then
			local Paths=require(SettingsFolder.ServerPaths)

			for PathName,PathValues in pairs(Paths) do
				for Index=1,#PathValues do
					table.insert(Engine_Settings.Paths[PathName],PathValues[Index])
				end
			end
		end
	end)

	assert(SettingsSuccess==true, SettingsSuccess==true or "[Dragon Engine Server] An error occured while loading settings : "..SettingsError)
end

if Engine_Settings["ShowLogoInOutput"] then print(ENGINE_LOGO) end --Displaying the logo in the output logs.
if Engine_Settings["Debug"] then warn("[Dragon Engine Server] Debug enabled. Logging will be verbose.") end

-------------------
-- Loading Enums --
-------------------
for EnumName,EnumVal in pairs(Engine_Settings.Enums) do
	DragonEngine:DefineEnum(EnumName,EnumVal)
end

-----------------------------------
-- Loading services,classes,etc. --
-----------------------------------
local Paths=Engine_Settings.Paths

--[[ Utils ]]--
print("")
print("**** LOADING UTIL MODULES ****")
print("")
for _,Path in pairs(Paths.Utils) do
	DragonEngine:LoadUtilitiesIn(Path)
end
--[[ Shared classes ]]--
print("")
print("**** LOADING CLASS MODULES ****")
print("")
for _,Path in pairs(Paths.SharedClasses) do
	DragonEngine:LoadClassesIn(Path)
end
--[[ Server classes ]]--
print("")
print("**** LOADING SERVER CLASS MODULES ****")
print("")
for _,Path in pairs(Paths.ServerClasses) do
	DragonEngine:LoadClassesIn(Path)
end

--[[ Loading services into the engine and initializing them ]]--
print("")
print("**** LOADING SERVICES ****")
print("")
DragonEngine:DebugLog("Loading and initializing services...")
for _,Path in pairs(Paths.Services) do
	DragonEngine:LoadServicesIn(Path)
end
for ServiceName,_ in pairs(DragonEngine.Services) do
	DragonEngine:InitializeService(ServiceName)
end
DragonEngine:DebugLog("All services loaded and initialized!")

--[[ Running services ]]--
DragonEngine:DebugLog()
DragonEngine:DebugLog("Starting services...")
for ServiceName,_ in pairs(DragonEngine.Services) do
	DragonEngine:StartService(ServiceName)
end
DragonEngine:DebugLog("All services running!")

shared.DragonEngineServer=DragonEngine --Exposing the engine to the global environment
local Engine_Loaded=Instance.new('BoolValue');Engine_Loaded.Name="_Loaded";Engine_Loaded.Value=true;Engine_Loaded.Parent=ReplicatedStorage.DragonEngine

print("")
DragonEngine:DebugLog((DragonEngine:GetOutput({"v",4.67,Workspace},"Hi",{},3.145967)))
print("Dragon Engine "..DragonEngine.Version.." loaded!")