"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[50],{70179:e=>{e.exports=JSON.parse('{"functions":[{"name":"GetService","desc":"Returns a reference to the requested service\\n```lua\\nlocal MarketService = DragonEngine:GetService(\\"MarketService\\")\\nMarketService:RequestPurchase(\\"HealthPotion\\",5)\\n```","params":[{"name":"ServiceName","desc":"The name of the service to get a reference to","lua_type":"string"}],"returns":[{"desc":"The service with the given name","lua_type":"ServiceClient"}],"function_type":"method","source":{"line":144,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"GetController","desc":"Returns a reference to the requested controller\\n```lua\\nlocal UIController = DragonEngine:GetController(\\"UIController\\")\\nUIController:DisplayDialogue(\\"Do you like Cake, or Pie?\\",\\"Cake\\",Pie\\")\\n```","params":[{"name":"ControllerName","desc":"The name of the controller to get a reference to","lua_type":"string"}],"returns":[{"desc":"The controller with the given name","lua_type":"Controller"}],"function_type":"method","source":{"line":159,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"LoadController","desc":"Loads the given controller module into the framework, making it accessible via `DragonEngineServer:GetController()`.\\n```lua\\nlocal Success,Error = DragonEngine:LoadController(LocalPlayer.PlayerScripts.Controllers.UIController)\\nif not Success then\\n\\tprint(\\"Failed to load UIController : \\" .. Error)\\nend\\n```","params":[{"name":"ControllerModule","desc":"The Controller modulescript to load into the framework","lua_type":"ModuleScript"}],"returns":[{"desc":"A `bool` describing whether or not the controller was successfully loaded","lua_type":"bool"},{"desc":"A `string` containing the error message if the controller failed to load. Will be `nil` if the load is successful.","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":178,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"LoadControllersIn","desc":"Loads all controllers in the given container via `DragonEngine:LoadController()`.\\n```lua\\nDragonEngine:LoadControllersIn(LocalPlayer.PlayerScripts.Controllers)\\n```\\n:::caution\\nOnly modules that are children of a `Model` or `Folder` instance will be considered for lazy-loading. Other instance types\\nare not supported at this time.\\n:::","params":[{"name":"Container","desc":"The folder that contains the controller modules","lua_type":"Folder"}],"returns":[{"desc":"","lua_type":"nil"}],"function_type":"method","private":true,"source":{"line":241,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"UnloadController","desc":"Unloads the specified controller from the framework and destroys any bindables it created.\\nThis API will attempt to call `DragonEngine:StopController()` with the controller before unloading it, to clean state.\\n```lua\\nlocal Success,Error = DragonEngine:UnloadController(\\"UIController\\")\\nif not Success then\\n\\tprint(\\"Failed to unload UIController : \\" .. Error)\\nend\\n```","params":[{"name":"ControllerName","desc":"The name of the controller to unload","lua_type":"string"}],"returns":[{"desc":"A `bool` describing whether or not the controller was successfully unloaded","lua_type":"bool"},{"desc":"A `string` containing the error message if the controller fails to be unloaded. Is `nil` if unloading succeeded.","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":264,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"InitializeController","desc":"Calls `:Init()` on the specified controller.\\n```lua\\nlocal Success,Error = DragonEngine:InitializeController(\\"UIController\\")\\nif not Success then\\n\\tprint(\\"Failed to initialize uicontroller : \\" .. Error)\\nend\\n```","params":[{"name":"ControllerName","desc":"The name of the controller to initialize","lua_type":"string"}],"returns":[{"desc":"A `bool` describing whether or not the controller was successfully initialized","lua_type":"bool"},{"desc":"A `string` containing the error message if the controller fails to be initialized. Is `nil` if initialization succeeded.","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":322,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"StartController","desc":"Calls `:Start()` on the specified controller.\\n```lua\\nlocal Success,Error = DragonEngine:StartController(\\"UIController\\")\\nif not Success then\\n\\tprint(\\"Failed to start uicontroller : \\" .. Error)\\nend\\n```","params":[{"name":"ControllerName","desc":"The name of the controller to start","lua_type":"string"}],"returns":[{"desc":"A `bool` describing whether or not the controller was successfully started.","lua_type":"bool"},{"desc":"A `string` containing the error message if the controller fails to successfully start. Is `nil` if start was successful.","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":373,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"StopController","desc":"Calls `:Stop()` on the specified controller\\n```lua\\nlocal Success,Error = DragonEngine:StopController(\\"UIController\\")\\nif not Success then\\n\\tprint(\\"Failed to stop uicontroller : \\" .. Error)\\nend\\n```","params":[{"name":"ControllerName","desc":"The name of the Controller to stop","lua_type":"string"}],"returns":[{"desc":"A `bool` describing whether or not the controller was successfully stopped","lua_type":"bool"},{"desc":"A `string` containing the error message if the controller fails to stop. Will be `nil` if the stop is successful.","lua_type":"string"}],"function_type":"method","private":true,"source":{"line":424,"path":"src/Client/Core/DragonEngine.client.lua"}},{"name":"RegisterControllerClientEvent","desc":"Registers a BindableEvent for the calling controller that it can use to fire client-side events.\\n```lua\\nlocal AvatarJumpedBindable = DragonEngine:RegisterControllerClientEvent(\\"AvatarJumped\\")\\nAvatarJumpedBindable:Fire(PlayerCharacter)\\n```\\n:::warning\\nThis API should only be called from a controller! Calling it outside of a controller will cause errors.\\n:::","params":[{"name":"Name","desc":"The name to assign to the BindableEvent","lua_type":"string"}],"returns":[{"desc":"The BindableEvent that was registered with the framework","lua_type":"BindableEvent"}],"function_type":"method","source":{"line":473,"path":"src/Client/Core/DragonEngine.client.lua"}}],"properties":[],"types":[{"name":"Controller","desc":"A client-sided microservice.","fields":[{"name":"Init","lua_type":"function","desc":"The controller\'s `Init` method."},{"name":"Start","lua_type":"function","desc":"The controller\'s `Start` method."},{"name":"...","lua_type":"function","desc":"The controller\'s various defined methods."}],"source":{"line":14,"path":"src/Client/Core/DragonEngine.client.lua"}}],"name":"DragonEngineClient","desc":"Handles the client sided aspects of the framework such as controllers, connecting to remotes, etc.","realm":["Client"],"source":{"line":7,"path":"src/Client/Core/DragonEngine.client.lua"}}')}}]);