# Configuration

The framework can be configured by adding modules with specific names to a folder named "DragonEngine_Configs" in `ReplicatedStorage`. These modules can then be edited to configure some of the framework's behaviors.

## General Settings

To configure the framework's global settings, add a module to the configuration folder named "EngineSettings". The structure of the module is as follows:

```lua
return {
	ShowLogoInOutput = false,
	Debug = false,

	IgnoredModules = {}
}
```

## Server Paths

To specify containers that the framework server will load services and modules from, add a module to the configuration folder named "ServerPaths". The structure of the module is as follows:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Server = {
			ServerScriptService.Modules,
		},
		Shared = {
			ReplicatedStorage.Modules,
		}
	},

	ServicePaths = {
		ServerScriptService.Services
	}
}
```

Key names for path tables are used to indicate the type of location that the modules are in. If you do not need to diffrentiate between location types, you can simply reference all containers in one table. For example:
```lua
ModulePaths = {
	{
		ReplicatedStorage.Modules,
		ServerScriptService.Modules
	}
}
```

## Client Paths

To specify containers that the framework client will load controllers and modules from, add a module to the configuration folder named "ClientPaths". The structure of the module is as follows:

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Shared = {
			ReplicatedStorage.Modules,
		},
		Client = {
			Players.LocalPlayer.PlayerScripts:WaitForChild("Modules")
		}
	},

	ControllerPaths = {
		Players.LocalPlayer.PlayerScripts:WaitForChild("Controllers")
	}
}
```

Just like with server paths, the names of the keys for path tables purely cosmetic. You can reference all containers in a single table if you wish.