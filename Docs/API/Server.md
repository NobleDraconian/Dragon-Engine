---
title: Server API - Dragon Engine
description : The server API for the framework.
author: Jayden Charbonneau
---

# Server API
The APIs here are only available on the server. They are not accessable to the [client](./Client.md).

## Properties

### Services
This property stores all of the service modulescripts that were loaded into the framework as a dictionary table.

!!! Warning
	This property should not be modified directly. Instead, use the `LoadService` or `LoadServicesIn` methods to
	load service modules into the framework.
	
	Modifying this property directly may result in glitchy behavior.

<hr/>

## Methods

### GetService

!!! Warning "Depreciated"
	This method is depreciated and can be removed at any time. It should not be used.

`DragonEngine:GetService(ServiceName) -> Service`

**Arguments**

1. `string` "ServiceName" : The name of the service to get.

**Returns**

1. `table` "Service" : The service that was retrieved. Will be `nil` if no service with the specified `ServiceName` was
	found.

**Description**

This method returns the requested service. It is similiar to `game:GetService()`.

??? info "Example usage"
	```lua
	local Players = game:GetService("Players")
	local DataService = DragonEngine:GetService("DataService")
	local MyData = {
		Coins = 120,
		Level = 4,
		Weapons = {
			{Name = "Axe", Material = "Diamond"},
			{Name = "Sword", Material = "Diamond"}
		}
	}

	DataService:SaveData(Players.SomePlayer,MyData)
	```

<hr/>

### LoadService

`DragonEngine:LoadService(ServiceModule) -> ServiceLoaded,ErrorMessage`

**Arguments**

1. `Instance "ModuleScript"` "ServiceModule" : The service module to load into the framework.

**Returns**

1. `bool` "ServiceLoaded" : A `bool` describing whether or not the service was loaded into the framework successfully.
	Will be `false` if an error occured while loading the service into the framework.
2. `string` "ErrorMessage" : An error message containing the error that occured while loading the service module.
	Will be `nil` if no error occured.

**Description**

This method loads the given `ServiceModule`	 into the framework and places its table under `DragonEngine.Services`.
Once loaded, the service can be accessed via `DragonEngine.Services.<ServiceName>`.

!!! warning
	If a service with the same name as the service module you are trying to load already exists in `DragonEngine.Services`,
	this method will throw an error.

??? Info "Example usage"
	```lua
	local ServerScriptService = game:GetService("ServerScriptService")
	local MyService = ServerScriptService.Services.MyService

	local ServiceLoad_Success,ErrorMessage = DragonEngine:LoadService(MyService)

	if not ServiceLoad_Success then
		warn("Failed to load service 'MyService' : "..ErrorMessage)
	end
	```

<hr/>

### LoadServicesIn

`DragonEngine:LoadServicesIn(Container,ThrowError) -> ServicesLoaded,ErrorMessage,FaultyModule`

**Arguments**

1. `Instance` "Container" : The container that holds all of the service modules. Valid container types are `Folder`
	instances and `Model` instances.
2. `bool` "ThrowError" : Determines whether or not an error will be thrown if any of the services in the `Container`
	fail to load. Defaults to `false`.

**Returns**

1. `bool` "ServicesLoaded" : A `bool` describing whether or not the services were loaded into the framework successfully.
	Will be `false` if an error occured while loading the services into the framework and
	`ThrowError` was `true`.
2. `string` "ErrorMessage" : An error message containing the error that occured while loading the service modules. Will
	be `nil` if no error occured or `ThrowError` is `false`.
3. `Instance "ModuleScript"` "FaultyModule" : The service modulescript that failed to load.

**Description**

This method iterates through the given `Container` and all of its sub-containers and loads all of the service modules 
it finds into the framework via `DragonEngine:LoadService()`.

??? info "Example usage"
	```lua
	local ServerScriptService = game:GetService("ServerScriptService")
	local ServiceContainer = ServerScriptService.Services

	local LoadServices_Success,ErrorMessage,FaultyServiceModule = DragonEngine:LoadServicesIn(ServiceContainerk,true)

	if not LoadServices_Success then
		print("Failed to load service '"..FaultyServiceModule.Name.."' : "..ErrorMessage)
	end
	```

<hr/>

### UnloadService

`DragonEngine:UnloadService(ServiceName) -> ServiceUnloaded,ErrorMessage`

**Arguments**

1. `string` "ServiceName" : The name of the service to unload from the framework.

**Returns**

1. `bool` "ServiceUnloaded" : A `bool` describing whether or not the service was unloaded from the framework successfully.
	Will be `false` if an error occured while unloading the service from the framework.
2. `string` "ErrorMessage" : An error message containing the error that occured while unoading the service.

**Description**

This method unloads the given `service` from the framework. If the given service is currently running when this method 
is called, the service will be stopped first via `DragonEngine:StopService()`.

??? Info "Example usage"
	```lua
	local StopService_Success,ErrorMessage = DragonEngine:StopService("MyService")

	if not StopService_Success then
		print("Failed to unload service 'MyService' : "..ErrorMessage)
	end
	```

<hr/>

### InitializeService

`DragonEngine:InitializeService(ServiceName) -> ServiceInitialized,ErrorMessage`

**Arguments**

1. `string` "ServiceName" : The name of the service to initialize.

**Returns**

1. `bool` "ServiceInitialized" : A `bool` describing whether or not the service was initialized successfully. 
   Will be `false` if an error occured while initializing the service.
2. `string` "ErrorMessage" : An error message containing the error that occured while initializing the service.

**Description**

This method initializes the given `service` in the framework. If the given service is already initialized when this method is called, this method will throw an error. It is recommended to check a service's `Status` property to determine if a service should be initialized or not.

??? Info "Example usage"
	```lua
	local ServiceInitialized,ErrorMessage = DragonEngine:InitializeService("MyService")

	if not ServiceInitialized then
		print("Failed to initialize service 'MyService' : "..ErrorMessage)
	end
	```

<hr/>

### StartService

`DragonEngine:StartService(ServiceName) -> ServiceStarted,ErrorMessage`

**Arguments**

1. `string` "ServiceName" : The name of the service to start.

**Returns**

1. `bool` "ServiceStarted" : A `bool` describing whether or not the service was started successfully.
   Will be `false` if an error occured while starting the service.
2. `string` "ErrorMessage" : An error message containing the error that occured while starting the service.

**Description**

This method starts the given `service` in the framework. If the given service is already started when this method is called, this method will throw an error. It is recommended to check a service's `Status` property to determine if a service should be started or not.

??? Info "Example usage"
	```lua
	local ServiceStarted,ErrorMessage = DragonEngine:StartService("MyService")

	if not ServiceStarted then
		print("Failed to start service 'MyService' : "..ErrorMessage)
	end
	```

<hr/>

### StopService

`DragonEngine:StopService(ServiceName) -> ServiceStopped,ErrorMessage`

**Arguments**

1. `string` "ServiceName" : The name of the service to stop.

**Returns**

1. `bool` "ServiceStopped" : A `bool` describing whether or not the service was stopped successfully.
   Will be `false` if an error occured while stopping the service.
2. `string` "ErrorMessage ": An error message containing the error that occured while stopping the service.

**Description**

This method stops the given `service` in the framework. If the given service isn't running when this method is called, this method will throw an error. It is recommended to check a service's `Status` property to determine if a service should be stopped or not.

??? Info "Example usage"
	```lua
	local ServiceStopped,ErrorMessage = DragonEngine:StopService("MyService")

	if not ServiceStopped then
		print("Failed to stop service 'MyService' : "..ErrorMessage)
	end
	```

<hr/>

### RegisterServiceClientEvent

`DragonEngine:RegisterServiceClientEvent(EventName) -> ClientEvent`

**Arguments**

1. `string` "EventName" : The name to assign to the client event.

**Returns**

1. `RemoteEvent` "ClientEvent " : The registered RemoteEvent object.

**Description**

This method allows for `services` to create client-facing events that clients can listen to. When called, this method creates a new remote event with the given name, places it inside of the framework's service endpoint folder, and returns its reference to the calling thread. 

??? Info "Example usage"
	```lua
	function MyService:Init()
		self.Client.SomeClientEvent = self:RegisterServiceClientEvent("SomeClientEvent")
	end
	```

<hr/>

### RegisterServiceServerEvent

`DragonEngine:RegisterServiceServerEvent(EventName) -> ServerEvent`

**Arguments**

1. `string` "EventName" : The name to assign to the server evnet.

**Returns**

1. `BindableEvent` "ServerEvent " : The registered BindableEvent object.

**Description**

This method allows for `services` to create server-facing events that the server can listen to. When called, this method creates a new bindable event with the given name, places it inside of the framework's service server event folder, and returs its reference to the calling thread.

??? Info "Example usage"
	```lua
	local SomeServerEvent;

	function MyService:Init()
		SomeServerEvent = self:RegisterServiceServerEvent("SomeServerEvent")
	end
	```

<hr/>