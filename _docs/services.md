---
title: Services
permalink: /docs/services/
---

## What are services?
Services are special modules. Unlike a typical `Class` or `Util` module, Services have a specific format that they have to follow. When the engine server runs, it automatically loads, initializes, and starts any services that it finds (based on its configuration settings). Apon loading a service, the framework will expose itself to the service table via the `__index` metatable method.

Essentially, services are designed to run all of the server-sided aspects of your game.

**NOTE: services can only run on the *server*. They are meant to be authoritative and control server state!**

## Service structure
A typical service module will have 2 functions : `Init` and `Start`. Any code inside of the `Init` function will be ran when the engine loads the service. 

Code inside of the `Init` function should be used to initialize the service. This can include setting up the service state and registering events. The code should not have any dependencies on other services, as the order in which the framework loads services *is not guaranteed*.

Any code inside of the `Start` function will be ran on its own seperate thread when the engine begins running all of the services it has loaded. Any non-method code for your service should be placed here. This can include listening to game events, setting up game state, and much more.

A service module can also contain various other developer-defined methods, such as `MyService:SomeMethod()`. Alongside this, a service can also have client methods that will be exposed to clients, such as `MyService.Client:SomeMethod()`. This allows for services to create endpoint APIs that clients can utilize, which makes for a very clean and straightforward network structure in your game.

**NOTE : Since client methods are exposed to the client, validate any data supplied by clients calling the function! Exploiters can also call these client methods.**

Here is what a basic bare-bones service will look like:
```lua
--[[
	Example Service

	This is an example service to display how a service is created and how it should be formatted.
--]]

local ExampleService={}

---------------------
-- Roblox Services --
---------------------


-------------
-- DEFINES --
-------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Init()

	self:DebugLog("[Example Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Start()
	self:DebugLog("[Example Service] Started!")

end

return ExampleService
```