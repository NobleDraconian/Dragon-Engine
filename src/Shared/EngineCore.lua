--[[
	Dragon Engine Core

	Global backend engine for Phoenix Entertainment, LLC.

	Programmed, designed and developed by @Reshiram110
	Inspiration by @Crazyman32's 'Aero' framework
--]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------
-- REQUIRES --
--------------
local Boilerplate = require(ReplicatedStorage.DragonEngine.Boilerplate)

-------------
-- DEFINES --
-------------
local DragonEngine = {
	Modules = {}, --Holds all of the loaded modules
	Enum = {}, --Contains all custom Enums.
	Config = {}, --Holds the engines settings.

	Version = "0.1.0" --TODO : Replace this with a valueobject that stores the latest git tag inside it via remodel.
}

local ModuleLocations = {} -- Stores the locations of modulescripts to be lazy-loaded
local LogHistory = {} -- Stores the the history of all logs
local MessageLogged; -- Fired when a message is logged via Log() or DebugLog()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Boilerplate
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function IsModuleIgnored(Module)
	for _,ModuleName in pairs(DragonEngine.Config.Settings.IgnoredModules) do
		if ModuleName == Module.Name then
			return true
		end
	end

	return false
end

local function RegisterEvent(EventName)
	local BindableEvent = Instance.new('BindableEvent')
	BindableEvent.Name = EventName

	DragonEngine[EventName] = BindableEvent.Event

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetOutput
-- @Description : Returns output from the engine.
-- @Params : Variant "Value" - The value(s) for the engine to return from this call.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetOutput(...)
	local Values = {...}
	local OutputString = "{"

	for Index,Param in pairs(Values) do
		OutputString = OutputString..tostring(Param)
		if Values[Index+1] ~= nil then 
			OutputString = OutputString..", " 
		end
	end
	OutputString = OutputString.."}"
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
	LogMessageType = LogMessageType or "Normal"

	if LogMessage == nil then
		print("")
		return
	end

	table.insert(LogHistory,{Message = LogMessage,Type = LogMessageType,Timestamp = tostring(DateTime.now().UnixTimestampMillis)})
	MessageLogged:Fire(LogMessage,LogMessageType,tostring(DateTime.now().UnixTimestampMillis))

	if LogMessageType == "warning" or LogMessageType == "Warning" then
		warn("[Dragon Engine Server] "..LogMessage)
	elseif LogMessageType == "error" or LogMessageType == "Error" then
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
	if DragonEngine.Config.Settings.Debug then
		LogMessageType = LogMessageType or "Normal"

		if LogMessage == nil then
			print("")
			return
		end

		table.insert(LogHistory,{Message = LogMessage,Type = LogMessageType,Timestamp = tostring(DateTime.now().UnixTimestampMillis)})
		MessageLogged:Fire(LogMessage,LogMessageType,tostring(DateTime.now().UnixTimestampMillis))

		if LogMessageType == "warning" or LogMessageType == "Warning" then
			warn("[Dragon Engine Server] "..LogMessage)
		elseif LogMessageType == "error" or LogMessageType == "Error" then
			error("[Dragon Engine Server] "..LogMessage)
		else
			print("[Dragon Engine Server] "..LogMessage)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetLogHistory
-- @Description : Returns the history of the output logs
-- @Params : OPTIONAL number "MaxLines" - How many lines back of history to return. If omitted, all logs will be returned.
-- @Example : DragonEngine:GetLogHistory(50)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetLogHistory(MaxLines)
	if MaxLines ~= nil then
		local TrimmedLogs = {}

		for Index = 1,#LogHistory do
			if Index > #LogHistory - MaxLines then
				table.insert(TrimmedLogs,LogHistory[Index])
			end
		end

		return table.freeze(TrimmedLogs)
	else
		return table.freeze(table.clone(LogHistory))
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modules
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetModule
-- @Description : Gets and returns the specified module from the framework
-- @Params : string "ModuleName" - The name of the module to get from the framework
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetModule(ModuleName)

	----------------
	-- Assertions --
	----------------
	assert(ModuleName ~= nil,"[Dragon Engine] GetModule() : string expected for 'ModuleName', got "..typeof(ModuleName).." instead.")

	return self.Modules[ModuleName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadModule
-- @Description : Loads the specified module into the framework
-- @Params : Instance <ModuleScript> 'Module' - The module to load
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LoadModule(Module)

	----------------
	-- Assertions --
	----------------
	assert(Module ~= nil,"[Dragon Engine Server] LoadModule() : ModuleScript expected for 'Module', got nil instead.")
	assert(typeof(Module) == "Instance","[Dragon Engine Server] LoadModule() : ModuleScript expected for 'Module', got "..typeof(Module).." instead.")
	assert(Module:IsA("ModuleScript"),"[Dragon Engine Server] LoadModule() : ModuleScript expected for 'Module', got "..Module.ClassName.." instead.")
	assert(rawget(self.Modules,Module.Name) == nil,"[Dragon Engine Server] LoadModule() : A module with the name '"..Module.Name.."' is already loaded!")

	-------------
	-- Defines --
	-------------
	local ModuleName = Module.Name
	local LoadedModule; --Table holding the class

	-----------------------
	-- Loading the class --
	-----------------------
	self:DebugLog("Loading module '"..ModuleName.."'...")
	local Success,Error = pcall(function() --If the module fails to load/errors, we want to keep the engine going
		LoadedModule = require(Module)
	end)
	if not Success then
		self:Log("Failed to load module '"..ModuleName.."' : "..Error,"Warning")
		return false,Error
	else
		self.Modules[ModuleName] = LoadedModule
		self:DebugLog("Loaded module '"..ModuleName.."'.")
		return true
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LazyLoadModulesIn
-- @Description : Lazy-loads all modules in the given container into the framework
-- @Params : Instance variant 'Container' - The container to lazy-load the modules from
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:LazyLoadModulesIn(Container)

	----------------
	-- Assertions --
	----------------
	assert(typeof(Container) == "Instance","[Dragon Engine Core] LazyLoadModulesIn() : Instance expected for 'Container', got "..typeof(Container).." instead.")

	table.insert(ModuleLocations,Container)
	self:DebugLog("All modules in '"..Container:GetFullName().."' will be lazyloaded.")
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
		local EnumItems = {}

		for _,EnumItemValue in pairs(CustomEnum) do
			if type(EnumItemValue) == "table" then
				for _,v in pairs(GetEnumItems(EnumItemValue)) do
					table.insert(EnumItems,v)
				end
			else
				table.insert(EnumItems,EnumItemValue)
			end
		end

		return EnumItems
	end


	self.Enum[EnumName] = EnumTable
end

--------------------------------
-- Listening for module calls --
--------------------------------
setmetatable(DragonEngine.Modules,{
	__index = function(_,Key)
		for _,ModuleLocation in pairs(ModuleLocations) do
			for _,ModuleScript in pairs(Boilerplate.RecurseFind(ModuleLocation,"ModuleScript")) do
				if ModuleScript.Name == Key then
					if not IsModuleIgnored(ModuleScript.Name) then
						DragonEngine:DebugLog("Lazy-loading module '"..ModuleScript.Name.."'...")
						local LoadSuccess = DragonEngine:LoadModule(ModuleScript)

						if LoadSuccess then
							return DragonEngine:GetModule(ModuleScript.Name)
						else
							DragonEngine:DebugLog("Failed to lazy-load module '"..ModuleScript.Name.."'","Warning")
							return nil
						end
					end
				end
			end
		end
	end
})

-----------------------
-- Setting up events --
-----------------------
MessageLogged = RegisterEvent("MessageLogged")

return DragonEngine