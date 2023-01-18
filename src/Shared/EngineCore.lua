--[=[
	@class DragonEngine

	The core of the framework. It handles module-loading, logging, and other aspects that are available on the server and client.
]=]

--- @type LogType string
--- @within DragonEngine
--- The type of a log. Valid values are `Normal`, `Warning` and `Error`.

--- @interface FrameworkLog
--- @within DragonEngine
--- @field Message string -- The log's message
--- @field Type LogType -- The log's type
--- @field Timestamp string -- The timestamp of when the log was created
---
--- A table containing the metadata of a single log.

--- @interface FrameworkSettings
--- @within DragonEngine
--- @field ShowLogoInOutput bool -- Determines whether or not the dragon engine logo is shown in the output when the framework runs.
--- @field Debug bool -- Determines whether or not any debug logs logged via DragonEngine:DebugLog() will be displayed.
--- @field ServerPaths ServerPaths
--- @field ClientPaths ClientPaths
---
--- The general settings of the framework

--------------
-- REQUIRES --
--------------
local Boilerplate = require(script.Parent.Boilerplate)

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
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RegisterEvent(EventName)
	local BindableEvent = Instance.new('BindableEvent')
	BindableEvent.Name = EventName

	DragonEngine[EventName] = BindableEvent.Event

	return BindableEvent
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Returns output from the framework. Useful for checking if the framework is being accessed properly.
--- ```lua
--- print(DragonEngine:GetOutput("HelloWorld",os.clock(),true))
--- ```
---
--- @param ... any -- The value(s) for the framework to return from this API call.
--- @return string -- The output the framework returns in response to this API call.
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
--- Adds the given text to the framework's logs.
--- ```lua
--- DragonEngine:Log("EquipPet() was called, but the player has no avatar!","Warning")
--- ```
---
--- @param LogMessage string -- The message to add to the logs
--- @param LogMessageType LogType -- The type of the message that is being logged.
--- @return nil
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
--- Adds the given text to the framework's logs if FrameworkSettings.Debug is `true`.
--- ```lua
--- DragonEngine:DebugLog(
--- 	("The item '%s' was purchased by player '%s'"):format(ItemName,Player.Name),
--- 	"Normal"
--- )
--- ```
---
--- @param LogMessage string -- The message to add to the logs
--- @param LogMessageType LogType -- The type of the message that is being logged.
--- @return nil
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:DebugLog(LogMessage,LogMessageType)
	if DragonEngine.Config.Debug then
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
--- Returns the history of the output logs, in ascending order (older entries first).
--- ```lua
--- print(DragonEngine:GetLogHistory(50)[4].Message)
--- ```
---
--- @param MaxLines integer -- How many lines back of history to return. If omitted, all logs will be returned.
--- @return {FrameworkLog} -- The logs pulled from the log history, in ascending order
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
--- Gets and returns the specified module from the framework if it exists. Returns `nil` if it does not exist.
--- If this is the first time the module is being called, it will be lazyloaded.
--- ```lua
--- local AvatarUtils = DragonEngine:GetModule("AvatarUtilities")
--- AvatarUtils:CreateCharacterModelFromPlayer(Player)
--- ```
---
--- @param ModuleName string -- The name of the module to get from the framework
--- @return table -- The module with the given name
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:GetModule(ModuleName)

	----------------
	-- Assertions --
	----------------
	assert(ModuleName ~= nil,"[Dragon Engine] GetModule() : string expected for 'ModuleName', got "..typeof(ModuleName).." instead.")

	return self.Modules[ModuleName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Loads the specified module and registers it with the framework
--- ```lua
--- local LoadSuccess,LoadErrorMessage = DragonEngine:LoadModule(ModuleScript)
--- if not LoadSuccess then
--- 	print("Module load failed : " .. LoadErrorMessage)
--- end
--- ```
---
--- @private
--- @param Module ModuleScript -- The ModuleScript to register with the framework
--- @return bool -- A `bool` describing whether or not the module was successfully loaded
--- @return string -- A `string` describing the error that occured while loading the module
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
--- Registers all ModuleScripts in the given container with the framework,
--- allowing them to be lazy-loaded when called via `DragonEngine:GetModule()`.
--- ```lua
--- DragonEngine:LazyLoadModulesIn(ReplicatedStorage.Modules)
--- ```
--- :::caution
--- Only modules that are children of a `Model` or `Folder` instance will be considered for lazy-loading. Other instance types
--- are not supported at this time.
--- :::
---
--- @private
--- @param Container Folder -- The folder that contains the ModuleScripts.
--- @return nil
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
--- Creates an enum with the given name.
---
--- @deprecated v1.0.0 -- This was a redundant feature of the framework. You can easily make your own enum library & load it through the framework!
--- @param EnumName string -- The name of the enum to create
--- @param EnumTable table -- A table containing possible enum values
--- @return nil
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DragonEngine:DefineEnum(EnumName,EnumTable)
	self:Log("[Dragon Engine Core] DefineEnum() has been deprecated and should not be used!","Warning")
	
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- End of APIs
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------
-- Listening for module calls --
--------------------------------
setmetatable(DragonEngine.Modules,{
	__index = function(_,Key)
		for _,ModuleLocation in pairs(ModuleLocations) do
			for _,ModuleScript in pairs(Boilerplate.RecurseFind(ModuleLocation,"ModuleScript")) do
				if ModuleScript.Name == Key then
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
})

-----------------------
-- Setting up events --
-----------------------
MessageLogged = RegisterEvent("MessageLogged")

return DragonEngine