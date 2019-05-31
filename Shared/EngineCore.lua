--[[
	Dragon Engine Core

	Global backend engine for Phoenix Entertainment, LLC.

	Version : 3.0.0

	Programmed, designed and developed by @Reshiram110
	Inspiration by @Crazyman32's 'Aero' framework
--]]

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

--------------
-- REQUIRES --
--------------
local Boilerplate=require(ReplicatedStorage.DragonEngine.Boilerplate)

-------------
-- DEFINES --
-------------
local DragonEngine={
	Utils={}, --Contains all of the utilities being used
	Classes={}, --Contains all of the classes being used
	Enum={}, --Contains all custom Enums.
	Config={}, --Holds the engines settings.

	Version="3.0.0"
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Boilerplate
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function IsModuleIgnored(Module)
	for _,ModuleName in pairs(DragonEngine.Config.IgnoredModules) do
		if ModuleName==Module.Name then
			return true
		end
	end

	return false
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
	if DragonEngine.Config["Debug"] then
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
	for _,ModuleScript in pairs(Boilerplate.RecurseFind(Container,"ModuleScript")) do
		if not IsModuleIgnored(ModuleScript) then
			self:LoadClass(ModuleScript)
		end
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
	for _,ModuleScript in pairs(Boilerplate.RecurseFind(Container,"ModuleScript")) do
		if not IsModuleIgnored(ModuleScript) then
			self:LoadUtility(ModuleScript)
		end
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

shared.DragonEngine=DragonEngine

return DragonEngine