# Configuration

The framework can be configured by passing a configuration table to the `DragonEngine:Run()` API. The structure of the table is as follows:

| Field Name       | Field Type | Field Description                                                                                                                                |
|------------------|------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| ShowLogoInOutput | Bool       | Determines whether or not the dragon engine logo is shown in the output when the framework runs.                                                 |
| Debug            | Bool       | Determines whether or not any debug logs logged via `DragonEngine:DebugLog()` will be displayed.                                                   |
| ServerPaths      | Dictionary | Contains references to folders that the framework will look in when loading modules & services. For more information, see **"server paths"**.    |
| ClientPaths      | Dictionary | Contains references to folders that the framework will look in when loading modules & controllers. For more information, see **"client paths"**. |

## Server Paths

To specify containers that the framework server will load services and modules from, be sure to pass `ServerPaths` in your framework settings table when calling `DragonEngine:Run()`. The structure of this table is as follows:

```lua
{
	ModulePaths = {
		<LocationName> = {
			<ModulesFolderLocation>,
			<ModulesFolderLocation>,
			-- etc
		},
		<LocationName> = {
			<ModulesFolderLocation>,
			<ModulesFolderLocation>,
			-- etc
		},
		-- etc
	},
	ServicePaths = {
		<ServicesFolderLocation>,
		<ServicesFolderLocation>,
		-- etc
	}
}
```

The `ModulePaths` dictionary contains sub-dictionaries that allow you to separate module locations by scope. This is useful if you want to separate your server module paths from your client module paths. These sub-dictionaries contain references to [Folder objects](https://create.roblox.com/docs/reference/engine/classes/Folder) that contain the modules the framework will load when the modules are referenced via the `DragonEngine:GetModule()` API.
Here's an example of what a typical `ModulePaths` configuration could look like:
```lua
ModulePaths = {
	ServerModules = {
		ServerScriptService.Modules,
	},

	SharedModules = {
		ReplicatedStorage.Modules
		Replicatedstorage.ThirdPartyModules
	}
}
```

The `ServicePaths` dictionary contains references to [Folder objects](https://create.roblox.com/docs/reference/engine/classes/Folder) that contain the service modules the framework will load when it is ran via the `DragonEngine:Run()` API.
Here's an example of what a typical `ServicePaths` configuration could look like:
```lua
ServicePaths = {
	ServerScriptService.Services,
	ReplicatedStorage.ThirdPartyLibraries.ACoolDataSystem.Services
}
```

## Client Paths

To specify containers that the framework server will load services and modules from, be sure to pass `ClientPaths` in your framework settings table when calling `DragonEngine:Run()`. The structure of this table is as follows:
```lua
{
	ModulePaths = {
		<LocationName> = {
			<ModulesFolderLocation>,
			<ModulesFolderLocation>,
			-- etc
		},
		<LocationName> = {
			<ModulesFolderLocation>,
			<ModulesFolderLocation>,
			-- etc
		},
		-- etc
	},
	ControllerPaths = {
		<ControllersFolderLocation>,
		<ControllersFolderLocation>,
		-- etc
	}
}
```

Just like with `ServerPaths`, the values inside of the dictionaries must point to [Folder objects](https://create.roblox.com/docs/reference/engine/classes/Folder) that contain the modules you want the framework to load.