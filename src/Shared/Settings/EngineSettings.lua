--[[
	Dragon Engine settings module
	
	This module contains all the configurable settings for the engine.
	Please note that any misconfigurations may crash the engine.
	
	SETTINGS
	========
	ShowLogoInOutput (Bool) : Determines whether or not the dragon engine logo is displayed apon startup.
	
	Debug (Bool) : Determines whether or not any debug output displayed via DragonEngine:DebugLog() will be displayed.
	
	LogMaxLength (Int) : The max amount of logs to store.

	Enums (Table) : Contains all custom enum values.
--]]

return{
	ShowLogoInOutput = false,
	Debug = false
}