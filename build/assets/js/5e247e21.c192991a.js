"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[879],{47590:e=>{e.exports=JSON.parse('{"functions":[{"name":"GetOutput","desc":"Returns output from the framework. Useful for checking if the framework is being accessed properly.\\n```lua\\nprint(DragonEngine:GetOutput(\\"HelloWorld\\",os.clock(),true))\\n```","params":[{"name":"...","desc":"The value(s) for the framework to return from this API call.","lua_type":"any"}],"returns":[{"desc":"The output the framework returns in response to this API call.","lua_type":"string"}],"function_type":"method","source":{"line":72,"path":"src/Shared/EngineCore.lua"}},{"name":"Log","desc":"Adds the given text to the framework\'s logs.\\n```lua\\nDragonEngine:Log(\\"EquipPet() was called, but the player has no avatar!\\",\\"Warning\\")\\n```","params":[{"name":"LogMessage","desc":"The message to add to the logs","lua_type":"string"},{"name":"LogMessageType","desc":"The type of the message that is being logged.","lua_type":"LogType"}],"returns":[{"desc":"","lua_type":"nil"}],"function_type":"method","source":{"line":100,"path":"src/Shared/EngineCore.lua"}},{"name":"DebugLog","desc":"Adds the given text to the framework\'s logs if FrameworkSettings.Debug is `true`.\\n```lua\\nDragonEngine:DebugLog(\\n\\t(\\"The item \'%s\' was purchased by player \'%s\'\\"):format(ItemName,Player.Name),\\n\\t\\"Normal\\"\\n)\\n```","params":[{"name":"LogMessage","desc":"The message to add to the logs","lua_type":"string"},{"name":"LogMessageType","desc":"The type of the message that is being logged.","lua_type":"LogType"}],"returns":[{"desc":"","lua_type":"nil"}],"function_type":"method","source":{"line":133,"path":"src/Shared/EngineCore.lua"}},{"name":"GetLogHistory","desc":"Returns the history of the output logs, in ascending order (older entries first).\\n```lua\\nprint(DragonEngine:GetLogHistory(50)[4].Message)\\n```","params":[{"name":"MaxLines","desc":"How many lines back of history to return. If omitted, all logs will be returned.","lua_type":"integer"}],"returns":[{"desc":"The logs pulled from the log history, in ascending order","lua_type":"{FrameworkLog}"}],"function_type":"method","source":{"line":164,"path":"src/Shared/EngineCore.lua"}},{"name":"GetModule","desc":"Gets and returns the specified module from the framework if it exists. Returns `nil` if it does not exist.\\nIf this is the first time the module is being called, it will be lazyloaded.\\n```lua\\nlocal AvatarUtils = DragonEngine:GetModule(\\"AvatarUtilities\\")\\nAvatarUtils:CreateCharacterModelFromPlayer(Player)\\n```","params":[{"name":"ModuleName","desc":"The name of the module to get from the framework","lua_type":"string"}],"returns":[{"desc":"The module with the given name","lua_type":"table"}],"function_type":"method","source":{"line":191,"path":"src/Shared/EngineCore.lua"}},{"name":"LoadModule","desc":"Loads the specified module and registers it with the framework\\n```lua\\nlocal LoadSuccess,LoadErrorMessage = DragonEngine:LoadModule(ModuleScript)\\nif not LoadSuccess then\\n\\tprint(\\"Module load failed : \\" .. LoadErrorMessage)\\nend\\n```","params":[{"name":"Module","desc":"The ModuleScript to register with the framework","lua_type":"ModuleScript"}],"returns":[{"desc":"A `bool` describing whether or not the module was successfully loaded","lua_type":"bool"},{"desc":"A `string` describing the error that occured while loading the module","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":215,"path":"src/Shared/EngineCore.lua"}},{"name":"LazyLoadModulesIn","desc":"Registers all ModuleScripts in the given container with the framework,\\nallowing them to be lazy-loaded when called via `DragonEngine:GetModule()`.\\n```lua\\nDragonEngine:LazyLoadModulesIn(ReplicatedStorage.Modules)\\n```\\n:::caution\\nOnly modules that are children of a `Model` or `Folder` instance will be considered for lazy-loading. Other instance types\\nare not supported at this time.\\n:::","params":[{"name":"Container","desc":"The folder that contains the ModuleScripts.","lua_type":"Folder"}],"returns":[{"desc":"","lua_type":"nil"}],"function_type":"method","private":true,"source":{"line":263,"path":"src/Shared/EngineCore.lua"}},{"name":"DefineEnum","desc":"Creates an enum with the given name.","params":[{"name":"EnumName","desc":"The name of the enum to create","lua_type":"string"},{"name":"EnumTable","desc":"A table containing possible enum values","lua_type":"table"}],"returns":[{"desc":"","lua_type":"nil"}],"function_type":"method","deprecated":{"version":"v1.0.0","desc":"This was a redundant feature of the framework. You can easily make your own enum library & load it through the framework!"},"source":{"line":282,"path":"src/Shared/EngineCore.lua"}}],"properties":[],"types":[{"name":"LogType","desc":"The type of a log. Valid values are `Normal`, `Warning` and `Error`.","lua_type":"string","source":{"line":10,"path":"src/Shared/EngineCore.lua"}},{"name":"FrameworkLog","desc":"A table containing the metadata of a single log.","fields":[{"name":"Message","lua_type":"string","desc":"The log\'s message"},{"name":"Type","lua_type":"LogType","desc":"The log\'s type"},{"name":"Timestamp","lua_type":"string","desc":"The timestamp of when the log was created"}],"source":{"line":18,"path":"src/Shared/EngineCore.lua"}},{"name":"FrameworkSettings","desc":"The general settings of the framework. For more information, see [framework configuration](../docs/Configuration).","fields":[{"name":"ShowLogoInOutput","lua_type":"bool","desc":"Determines whether or not the dragon engine logo is shown in the output when the framework runs."},{"name":"Debug","lua_type":"bool","desc":"Determines whether or not any debug logs logged via DragonEngine:DebugLog() will be displayed."},{"name":"ServerPaths","lua_type":"ServerPaths","desc":""},{"name":"ClientPaths","lua_type":"ClientPaths","desc":""}],"source":{"line":27,"path":"src/Shared/EngineCore.lua"}}],"name":"DragonEngine","desc":"The core of the framework. It handles module-loading, logging, and other aspects that are available on the server and client.","source":{"line":6,"path":"src/Shared/EngineCore.lua"}}')}}]);