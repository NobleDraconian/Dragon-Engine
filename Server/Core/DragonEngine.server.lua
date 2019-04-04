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

--------------
-- REQUIRES --
--------------
local Logo=require(ReplicatedStorage.DragonEngine.Logo)

-------------
-- DEFINES --
-------------
local DragonEngine={
	Utils={}, --Contains all of the utilities being used
	Classes={}, --Contains all of the classes being used
	Services={}, --Contains all services, both running and stopped
	ServiceExtensions={}, --Contains modules used by services.
	Enum={}, --Contains all custom Enums.

	Version="2.2.0"
	--Logs={}
}

local ENGINE_SETTINGS; --Holds the engines settings.
local Service_Endpoints; --A folder containing the remote functions/events for services with client APIs.
local Service_Events; --A folder containing the server sided events for services.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERNAL FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Recurse
-- @Description : Returns all items in a folder/model/table and all of its subfolders/submodels/subtables.
--                If it is a table, it returns all items in a table and all items in all of its sub-tables.
-- @Params : Instance <Folder>/table "Root" - The folder/table to recurse through.
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
		
		for _,Item in pairs(Table) do
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
	if ENGINE_SETTINGS["Debug"] then
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: GetService
-- @Description : Returns the requested service.
--                Similiar to game:GetService().
-- @Params : string "ServiceName" - The name of the service to retrieve
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetService(ServiceName)
	assert(DragonEngine.Services[ServiceName]~=nil,"[Dragon Engine Server] DragonEngine::GetService() : Service '"..ServiceName.."' was not loaded or does not exist.")
	return DragonEngine.Services[ServiceName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadService
-- @Description : Loads the specified service module into the engine. Returns false if the service fails to load.
-- @Params : Instance <ModuleScript> "ServiceModule" - The service module to load into the engine
-- @Returns : Boolean "ServiceLoaded" - Will be TRUE if the service is loaded successfully, will be FALSE if the service failed to load.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadService(ServiceModule)
	local ServiceName=ServiceModule.Name
	local Service; --Table holding the service
	
	self:DebugLog("Loading service '"..ServiceModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Service=require(ServiceModule)
	end)
	if not Success then --Service module failed to load
		self:Log("Failed to load service '"..ServiceName.."' : "..Error,"Warning")
		return false
	else --Service module was loaded
		
		---------------------------------------------------------------------------------------------------
		-- Generating remote functions and events for the client to call client functions of the service --
		---------------------------------------------------------------------------------------------------
		
		if Service.Client~=nil then --The service has client APIs
			local EndpointFolder=Instance.new('Folder',Service_Endpoints);EndpointFolder.Name=ServiceName --Container for remote functions/events so clients can access the service client API.
			
			Service._EndpointFolder=EndpointFolder

			for FunctionName,Function in pairs(Service.Client) do
				if type(Function)=="function" then
					local RemoteFunction=Instance.new('RemoteFunction',EndpointFolder);RemoteFunction.Name=FunctionName

					RemoteFunction.OnServerInvoke=function(...)
						return Function(Service.Client,...) --Service.Client is passed since `self` needs to be manually defined
					end

					self:DebugLog("Registered endpoint '"..ServiceName.."."..FunctionName.."'")
				end
			end
		end

		---------------------------------------------
		-- Adding service to DragonEngine.Services --
		---------------------------------------------
		local EventsFolder=Instance.new('Folder',Service_Events);EventsFolder.Name=ServiceName --Container for server sided events for this service
		Service._ServerEventsFolder=EventsFolder

		Service.Name=ServiceName

		setmetatable(Service,{__index=DragonEngine}) --Exposing Dragon Engine to the service
		self.Services[ServiceName]=Service
		self:DebugLog("Service '"..ServiceName.."' loaded.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : UnloadService
-- @Description : Unloads the specified service from the engine and destroys any endpoints/events it created.
-- @Params : string "ServiceName" - The name of the service to unload.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:UnloadService(ServiceName)
	local Service=self.Services[ServiceName]

	self:Log("Unloading service '"..ServiceName.."'...")
	if typeof(Service.Unload)=="function" then --The service has an unload function, run it to allow the service to clean state.

		local Success,Error=pcall(function()
			Service:Unload()
		end)

		if not Success then
			self:Log("Service '"..ServiceName.."' unload function failed : "..Error,"Warning")
		end
	end

	Service._EndpointFolder:Destroy()
	Service._ServerEventsFolder:Destroy()
	self.Services[ServiceName]=nil

	self:Log("Service '"..ServiceName.."' unloaded.")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterServiceClientEvent
-- @Description : Registers a client event for the service calling. MUST BE CALLED FROM INSIDE A SERVICE MODULE.
-- @Params : string "Name" - The name to assign to the client event.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterServiceClientEvent(Name)
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
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterServiceServerEvent(Name)
	local BindableEvent=Instance.new('BindableEvent')
	BindableEvent.Name=Name
	BindableEvent.Parent=self._ServerEventsFolder
	self[Name]=BindableEvent.Event
	
	self:DebugLog("Registered server event '"..Name.."' for service '"..self.Name.."'")

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadServiceExtension
-- @Description : Loads the specified module into the engine.
-- @Params : Instance <ModuleScript> "ServiceExtension" - The ServiceExtension module to load into the engine
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadServiceExtension(ServiceExtension)
	local ServiceExtensionName=ServiceExtension.Name
	local Mod;
	local s,m=pcall(function() --If the module fails to load/errors, we want to keep the engine going.
		Mod=require(ServiceExtension)
	end)
	if not s then
		setmetatable(ServiceExtension,{__index=DragonEngine})
		DragonEngine:Log("Failed to load Service Extension '"..ServiceExtensionName.."' : "..m,"Warning")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLASSES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadClass
-- @Description : Loads the specified custom class module into the engine.
-- @Params : Instance <ModuleScript>  "ClassModule" - The class module to load into the engine
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadClass(ClassModule)
	local ClassName=ClassModule.Name
	local Class; --Table holding the class

	self:DebugLog("Loading class '"..ClassModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Class=require(ClassModule)
	end)
	if not Success then
		DragonEngine:Log("Failed to load class '"..ClassName.."' : "..Error,"Warning")
	else
		DragonEngine.Classes[ClassName]=Class
		DragonEngine:DebugLog("Loaded Class '"..ClassName.."'.")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTILITIES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadUtility
-- @Description : Loads the specified utility module into the engine.
-- @Params : Instance <ModuleScript> "UtilModule" - The utility module to load into the engine
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadUtility(UtilModule)
	local UtilName=UtilModule.Name
	local Util;

	self:DebugLog("Loading utility '"..ClassModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going.
		Util=require(UtilModule)
	end)
	if not Success then
		DragonEngine:Log("Failed to load utility '"..UtilName.."' : "..Error,"Warning")
	else
		DragonEngine.Utils[UtilName]=Util
		DragonEngine:DebugLog("Loaded Utility : '"..UtilName.."'.")
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
Instance.new('Folder',ReplicatedStorage.DragonEngine).Name="Network"

------------------------------------------------------
-- Making sure that the engine settings are correct --
------------------------------------------------------
--assert(script.Parent.Settings~=nil,"[Dragon Engine Server] Cannot initialize without settings.")
local SettingsSuccess,SettingsError=pcall(function()
	ENGINE_SETTINGS=require(ReplicatedStorage.DragonEngine.Settings.EngineSettings)
	ENGINE_SETTINGS["Paths"]=require(ReplicatedStorage.DragonEngine.Settings.ServerPaths)
end)
assert(SettingsSuccess==true, SettingsSuccess==true or "[Dragon Engine Server] An error occured while loading settings : "..SettingsError)

if ENGINE_SETTINGS["ShowLogoInOutput"] then print(Logo) end --Displaying the logo in the output logs.
if ENGINE_SETTINGS["Debug"] then warn("[Dragon Engine Server] Debug enabled. Logging will be verbose.") end

-------------------
-- Loading Enums --
-------------------
for EnumName,EnumVal in pairs(ENGINE_SETTINGS.Enums) do
	DragonEngine:DefineEnum(EnumName,EnumVal)
end

-----------------------------------
-- Loading services,classes,etc. --
-----------------------------------
local Paths=ENGINE_SETTINGS.Paths

Service_Endpoints=Instance.new('Folder',ReplicatedStorage.DragonEngine.Network);Service_Endpoints.Name="Service_Endpoints"
Service_Events=Instance.new('Folder',ServerStorage.DragonEngine);Service_Events.Name="Service_Events"

--[[ Utils ]]--
print("")
print("**** LOADING UTIL MODULES ****")
print("")
for _,Path in pairs(Paths.Utils) do
	LoadModules(DragonEngine.Utils,Path,false)
end
--[[ Shared classes ]]--
print("")
print("**** LOADING CLASS MODULES ****")
print("")
for _,Path in pairs(Paths.SharedClasses) do
	LoadModules(DragonEngine.Classes,Path,false)
end
--[[ Server classes ]]--
print("")
print("**** LOADING SERVER CLASS MODULES ****")
print("")
for _,Path in pairs(Paths.ServerClasses) do
	LoadModules(DragonEngine.Classes,Path,false)
end
--[[ Service extensions ]]--
for _,Path in pairs(Paths.ServiceExtensions) do
	LoadModules(DragonEngine.ServiceExtensions,Path,true)
end

--[[ Loading services into the engine and initializing them ]]--
print("")
print("**** LOADING SERVICES ****")
print("")
DragonEngine:DebugLog("Loading and initializing services...")
for _,Path in pairs(Paths.Services) do
	LoadServices(Path)
end
DragonEngine:DebugLog("All services loaded and initialized!")

--[[ Running services ]]--
DragonEngine:DebugLog()
DragonEngine:DebugLog("Starting services...")
for ServiceName,Service in pairs(DragonEngine.Services) do
	if type(Service.Start)=="function" then --A start() function exists, run it.
		DragonEngine:DebugLog("Starting Service '"..ServiceName.."'...")
		coroutine.wrap(Service.Start)(Service) --Starting the service in its own thread, while giving it direct access to itself
	end
end
DragonEngine:DebugLog("All services running!")

shared.DragonEngineServer=DragonEngine --Exposing the engine to the global environment
local Engine_Loaded=Instance.new('BoolValue');Engine_Loaded.Name="_Loaded";Engine_Loaded.Value=true;Engine_Loaded.Parent=ReplicatedStorage.DragonEngine

print("")
DragonEngine:DebugLog((DragonEngine:GetOutput({"v",4.67,Workspace},"Hi",{},3.145967)))
print("Dragon Engine "..DragonEngine.Version.." loaded!")