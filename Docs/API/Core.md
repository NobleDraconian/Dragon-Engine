---
title: Core API - Dragon Engine
description : The core API for the framework that is shared by both server and client.
author: Jayden Charbonneau
---

# Core API
The APIs here are shared by both the [server](./Server.md) and [client](./Client.md).

## Properties

### Config
This property stores the framework's configuration settings that were loaded from the `settings modules` as a
dictionary table.

### Classes
This property stores all of the class modulescripts that were loaded into the framework as a dictionary table.

!!! Warning
	This property should not be modified directly. Instead, use the `LoadClass` or `LoadClassesIn` methods to
	load class modules into the framework.
	
	Modifying this property directly may result in glitchy behavior.

### Utils
This property stores all of the utility modulescripts that were loaded into the framework as a dictionary table.

!!! Warning
	This property should not be modified directly. Instead, use the `LoadUtility` or `LoadUtilitiesIn` methods to
	load utility modules into the framework.

	Modifying this property directly may result in glitchy behavior.

### Version
This property stores the current version number of the framework.

## Methods

### Log
`DragonEngine:Log(LogMessage,LogMessageType) -> nil`

**Arguments**

1. `string` "LogMessage" : The message to display in the logs.
2. `string` "LogMessageType" : The type of message to display in the logs.
                            Valid types are "Warning" and "Error".
							If ommitted, a regular message is sent to the logs.

**Returns**

This method returns `nil`.

**Description**

Sends the specified string to the framework logs, as the given log type.

??? info "Example usage"
	```lua
	DragonEngine:Log("A player has walked beyond the map's barriers, and may be exploiting!","Warning")
	```

<hr/>

### DebugLog
`DragonEngine:DebugLog(LogMessage,LogMessageType) -> nil`

**Arguments**

1. `string` "LogMessage" : The message to display in the logs.
2. `string` "LogMessageType" : The type of message to display in the logs.
                            Valid types are "Warning" and "Error".
							If ommitted, a regular message is sent to the logs.

**Returns**

This method returns `nil`.

**Description**

Sends the specified string to the framework logs, as the given log type.
This method only writes to the logs if "Debug" is set to `true` in the framework's [configuration settings]().

??? info "Example usage"
	```lua
	DragonEngine:Log("Player weapons registered successfully, running...")
	```

<hr/>

### LoadClass
`DragonEngine:LoadClass(ClassModule) -> LoadSuccess`

**Arguments**

1. `Instance "ModuleScript"` "ClassModule" : The class `ModuleScript` to load into the framework.

**Returns**

1. `bool` "LoadSuccess" : A `bool` describing whether or not the class `ModuleScript` was loaded into the framework
                       successfully. Will be `false` if there was an error while loading the `ModuleScript`.

**Description**

This method loads the given "ClassModule" into the framework and places its table under `DragonEngine.Classes`.
Once loaded, the loaded class can be accessed via `DragonEngine.Classes.<ClassName>`.

!!! warning
	If a module with the same name as the class module you are trying to load already exists in `DragonEngine.Classes`,
	this method will throw an error.

??? info "Example usage"
	```lua
	-- Script 1
	local Class_LoadSuccess=DragonEngine:LoadClass(script.Dog)

	if not Class_LoadSuccess then
		warn("No one can make any doggos! D:")
	end
	```

	```lua
	-- Script 2
	local Dog=DragonEngine.Classes.Dog

	local MyDog=Dog.new()
	MyDog.Name="Fido"
	MyDog.Age=4
	MyDog.Color="Brown"

	MyDog:Bark()
	MyDog:WalkTo(Vector3.new(0,0,0))
	```

<hr/>

### LoadClassesIn
`DragonEngine:LoadClassesIn(Container) -> LoadSuccess`

**Arguments**

1. `Instance` "Container" : The container that holds all of the class modules. Valid container types are `Folder`
                            instances and `Model` instances.

**Returns**

This method returns `nil`.

**Description**

This method iterates through the given `Container` and all of its sub-containers and loads all of the modules it finds
into the framework (`DragonEngine.Classes`)

!!! warning
	If a module with the same name as any of the class modules in the container already exist in `DragonEngine.Classes`,
	this method will throw an error.

??? info "Example usage"
	```lua
	local ReplicatedStorage=game:GetService("ReplicatedStorage")
	local ClassContainer=ReplicatedStorage.Classes

	DragonEngine:LoadClassesIn(ClassContainer)
	```

<hr/>

### LoadUtility
`DragonEngine:LoadUtility(UtilityModule) -> LoadSuccess`

**Arguments**

1. `Instance "ModuleScript"` "UtilityModule" : The Utility `ModuleScript` to load into the framework.

**Returns**

1. `bool` "LoadSuccess" : A `bool` describing whether or not the Utility `ModuleScript` was loaded into the framework
                       successfully. Will be `false` if there was an error while loading the `ModuleScript`.

**Description**

This method loads the given "UtilityModule" into the framework and places its table under `DragonEngine.Utils`.
Once loaded, the loaded Utility can be accessed via `DragonEngine.Utils.<UtilityName>`.

!!! warning
	If a module with the same name as the Utility module you are trying to load already exists in `DragonEngine.Utils`,
	this method will throw an error.

??? info "Example usage"
	```lua
	-- Script 1
	local Utility_LoadSuccess=DragonEngine:LoadUtility(script.Table)

	if not Utility_LoadSuccess then
		warn("No handy table functions. :(")
	end
	```

	```lua
	-- Script 2
	local PlayerService=game:GetService("Players")
	local Players=PlayerService:GetPlayers()
	local Table=DragonEngine.Utils.Table
	
	Table.Shuffle(Players)
	print("The new order of players is "..Table.repr(Players))
	```

<hr/>

### LoadUtilitiesIn
`DragonEngine:LoadUtilitiesIn(Container) -> LoadSuccess`

**Arguments**

1. `Instance` "Container" : The container that holds all of the class modules. Valid container types are `Folder`
                            instances and `Model` instances.

**Returns**


This method returns `nil`.
**Description**

This method iterates through the given `Container` and all of its sub-containers and loads all of the modules it finds
into the framework (`DragonEngine.Utils`).

!!! warning
	If a module with the same name as any of the class modules in the container already exist in `DragonEngine.Utils`,
	this method will throw an error.

??? info "Example usage"
	```lua
	local ReplicatedStorage=game:GetService("ReplicatedStorage")
	local UtilityContainer=ReplicatedStorage.Utilities

	DragonEngine:LoadUtilitiesIn(UtilityContainer)
	```