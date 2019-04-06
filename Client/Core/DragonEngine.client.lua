--[[
	Dragon Engine Client
	
	Global backend engine for Phoenix Entertainment, LLC.
	
	Version : 2.1.0
	
	Programmed, designed and developed by @Reshiram110
	Inspiration by @Crazyman32's 'Aero' framework
--]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")

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
	Controllers={}, --Contains all controllers, both running and stopped
	Services={}, --Contains all remote functions/events associated with the server sided services.
	ControllerExtensions={}, --Contains modules used by controllers.
	Enum={},
	
	Version="2.2.0"
	--Logs={}
}

local Engine_Settings; --Holds the engines settings.
local Service_Endpoints; --A folder containing the remote functions/events for services with client APIs.
local Controller_Events; --A folder containing the client sided events for controllers.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERNAL FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Recurse
-- @Description : Returns all items in a folder/model and all of its subfolders/submodels.
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
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RecurseFind(Root,ItemType)
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
-- @Name : LoadControllers
-- @Description : Loads all controller modules from the specified path into the engine.
-- @Params : Instance <Folder> "Folder" - The folder to load the modules from.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadControllers(Folder)
	for _,ControllerModule in pairs(RecurseFind(Folder,"ModuleScript")) do
		if ControllerModule:IsA("ModuleScript") and ControllerModule:FindFirstChild("Disabled")==nil then
			local ControllerLoaded=DragonEngine:LoadController(ControllerModule)
			
			if ControllerLoaded then --Controller loaded successfully.
				local Controller=DragonEngine:GetController(ControllerModule.Name)
				if type(Controller.Init)=="function" then --An init() function exists, run it.
					DragonEngine:DebugLog("Initializing controller '"..ControllerModule.Name.."'...")

					local Success,Error=pcall(function()
						Controller:Init()
					end)

					if not Success then
						DragonEngine:Log("Failed to initialize controller '"..ControllerModule.Name.."' : "..Error,"Warning")
						DragonEngine:UnloadController(ControllerModule.Name)
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
		warn("[Dragon Engine Client] "..LogMessage)
	elseif LogMessageType=="error" or LogMessageType=="Error" then
		error("[Dragon Engine Client] "..LogMessage)
	else
		print("[Dragon Engine Client] "..LogMessage)
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
			warn("[Dragon Engine Client] "..LogMessage)
		elseif LogMessageType=="error" or LogMessageType=="Error" then
			error("[Dragon Engine Client] "..LogMessage)
		else
			print("[Dragon Engine Client] "..LogMessage)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLLERS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetController
-- @Description : Returns the requested controller.
-- @Params : string "ControllerName" - The name of the controller to retreve
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetController(ControllerName)
	assert(DragonEngine.Controllers[ControllerName]~=nil,"[Dragon Engine Client] DragonEngine::GetController() : Controller '"..ControllerName.."' was not loaded or does not exist.")
	return DragonEngine.Controllers[ControllerName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadController
-- @Description : Loads the specified controller module into the engine.
-- @Params :  Instance <ModuleScript> "ControllerModule" - The controller module to load into the engine
-- RETURNS : bool "Loaded_Successfully" - Determines whether or not the controller was loaded successfully.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadController(ControllerModule)
	local ControllerName=ControllerModule.Name
	local Controller;

	self:DebugLog("Loading controller '"..ControllerModule.Name.."'...")
	local Success,Error=pcall(function() --If the module fails to load/errors, we want to keep the engine going
		Controller=require(ControllerModule)
	end)
	if not Success then --Controller module failed to load
		DragonEngine:Log("Failed to load Controller '"..ControllerName.."' : "..Error,"Warning")
		return false
	else --Controller moduled was loaded
		local EventsFolder=Instance.new('Folder',Controller_Events);EventsFolder.Name=ControllerName --Container for client sided events for this controller
		Controller._ClientEventsFolder=EventsFolder

		Controller.Name=ControllerName

		setmetatable(Controller,{__index=DragonEngine}) --Exposing Dragon Engine to the controller
		DragonEngine.Controllers[ControllerName]=Controller
		DragonEngine:DebugLog("Controller '"..ControllerName.."' loaded.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : UnloadController
-- @Description : Unloads the specified controller from the engine and destroys any events it has created.
-- @Params : string "ControllerName" - The name of the controller to unload.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:UnloadController(ControllerName)
	local Controller=self.Controllers[ControllerName]

	self:DebugLog("Unloading controller '"..ControllerName.."'...")
	if typeof(Controller.Unload)=="function" then --The controller has an unload function, run it to allow the controller to clean state.

		local Success,Error=pcall(function()
			Controller:Unload()
		end)

		if not Success then
			self:Log("Controller '"..ControllerName.."' unload function failed : "..Error,"Warning")
		end
	end

	Controller._ClientEventsFolder:Destroy()
	self.Controllers[ControllerName]=nil

	self:Log("Controller '"..ControllerName.."' unloaded.")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterControllerClientEvent
-- @Description : Registers a client event for the controller calling. MUST BE CALLED FROM INSIDE A SERVICE MODULE.
-- @Params : string "Name" - The name to assign to the client event.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:RegisterControllerClientEvent(Name)
	local BindableEvent=Instance.new('BindableEvent')
	BindableEvent.Name=Name
	BindableEvent.Parent=self._ClientEventsFolder
	self[Name]=BindableEvent.Event
	
	self:DebugLog("Registered client event '"..Name.."' for service '"..self.Name.."'")

	return BindableEvent
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

	self:DebugLog("Loading utility '"..UtilModule.Name.."'...")
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
print("")
print("**** WAITING FOR SERVER ****")
print("")
ReplicatedStorage:WaitForChild("DragonEngine"):WaitForChild("_Loaded") --Waiting for the server engine to load

----------------------
-- Loading Settings --
----------------------
--[[ Load default settings ]]--
local SettingsSuccess,SettingsError=pcall(function()
	Engine_Settings=require(ReplicatedStorage.DragonEngine.Settings.EngineSettings)
	Engine_Settings["Paths"]=require(ReplicatedStorage.DragonEngine.Settings.ClientPaths)
end)
assert(SettingsSuccess==true, SettingsSuccess==true or "[Dragon Engine Client] An error occured while loading settings : "..SettingsError)

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

		if SettingsFolder:FindFirstChild("ClientPaths")~=nil then
			local Paths=require(SettingsFolder.ClientPaths)
			
			for PathName,PathValues in pairs(Paths) do
				for Index=1,#PathValues do
					table.insert(Engine_Settings.Paths[PathName],PathValues[Index])
				end
			end
		end
	end)

	assert(SettingsSuccess==true, SettingsSuccess==true or "[Dragon Engine Client] An error occured while loading settings : "..SettingsError)
end

if Engine_Settings["ShowLogoInOutput"] then print(Logo) end --Displaying the logo in the output logs.
if Engine_Settings["Debug"] then warn("[Dragon Engine Client] Debug enabled. Logging will be verbose.") end

-------------------
-- Loading Enums --
-------------------
for EnumName,EnumVal in pairs(Engine_Settings.Enums) do
	DragonEngine:DefineEnum(EnumName,EnumVal)
end

----------------------------------
-- Loading services,classes,etc.--
----------------------------------
local Paths=Engine_Settings["Paths"]

Service_Endpoints=ReplicatedStorage.DragonEngine.Network:WaitForChild("Service_Endpoints")
Controller_Events=Instance.new('Folder',Players.LocalPlayer.PlayerScripts.DragonEngine);Controller_Events.Name="Controller_Events"

--[[ Utils ]]--
print("")
print("**** LOADING UTIL MODULES ****")
print("")
for _,Path in pairs(Paths.Utils) do
	LoadModules(DragonEngine.Utils,Path,false)
end
--[[ Shared Classes ]]--
print("")
print("**** LOADING CLASS MODULES ****")
print("")
for _,Path in pairs(Paths.SharedClasses) do
	LoadModules(DragonEngine.Classes,Path,false)
end
--[[ Controller Extensions ]]--
for _,Path in pairs(Paths.ControllerExtensions) do
	LoadModules(DragonEngine.ControllerExtensions,Path,true)
end


--[[ Connecting to remote service endpoints ]]--
print("")
print("**** CONNECTING TO SERVICE ENDPOINTS ****")
print("")
DragonEngine:DebugLog("Connecting to service endpoints...")
for _,ServiceFolder in pairs(Service_Endpoints:GetChildren()) do
	local Service={}

	DragonEngine.Services[ServiceFolder.Name]=Service

	for _,RemoteFunction in pairs(ServiceFolder:GetChildren()) do
		if RemoteFunction:IsA("RemoteFunction") then
			DragonEngine:DebugLog("Connecting to remote function '"..ServiceFolder.Name.."."..RemoteFunction.Name.."'...")

			Service[RemoteFunction.Name]=function(self,...) --We seperate 'self' to ommit it from the server call.
				return RemoteFunction:InvokeServer(...)
			end
		elseif RemoteFunction:IsA("RemoteEvent") then
			DragonEngine:DebugLog("Registered remote event '"..ServiceFolder.Name.."."..RemoteFunction.Name.."'.")
			Service[RemoteFunction.Name]=RemoteFunction.OnClientEvent
		end
	end
end
DragonEngine:DebugLog("All endpoints connected to!")

--[[ Loading controllers into the engine and initializing them ]]--
print("")
print("**** LOADING CONTROLLERS ****")
print("")
DragonEngine:DebugLog("Loading and initializing controllers...")
for _,Path in pairs(Paths.Controllers) do
	LoadControllers(Path)	
end
DragonEngine:DebugLog("All controllers loaded and initialized!")

--[[ Running controllers ]]--
DragonEngine:DebugLog()
DragonEngine:DebugLog("Starting controllers...")
for ControllerName,Controller in pairs(DragonEngine.Controllers) do
	if type(Controller.Start)=="function" then
		DragonEngine:DebugLog("Starting controller '"..ControllerName.."'...")
		coroutine.wrap(Controller.Start)(Controller) --Starting the service in its own thread, while giving it direct access to itself
	end
end
DragonEngine:DebugLog("All controllers running!")

shared.DragonEngine=DragonEngine --Exposing the engine to the global environment

print("")
DragonEngine:DebugLog((DragonEngine:GetOutput({"v",4.67,Workspace},"Hi",{},3.145967)))
print("Dragon Engine "..DragonEngine.Version.." loaded!")