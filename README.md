![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/NobleDraconian/Dragon-Engine?include_prereleases&label=Latest%20Release)
![GitHub](https://img.shields.io/github/license/Reshiram110/Dragon-Engine?label=License)


[![Linting](https://github.com/NobleDraconian/Dragon-Engine/actions/workflows/lua-lint.yml/badge.svg)](https://github.com/NobleDraconian/Dragon-Engine/actions/workflows/lua-lint.yml)

# :dragon: HERE BE DRAGONS :dragon:
This framework is still a work in progress. I cannot guarantee its stability in stressful environments. Please be aware of this when utilizing it in your games.

<hr></hr>

![](/Assets/Web/Branding/DragonEngine_Wallpaper.png)

# About
Dragon Engine is a Lua framework designed for Roblox. It seamlessly bridges the server/client boundary, unifies modules to allow for easy code communication (this also helps to prevent [cyclic requiring](https://en.wikipedia.org/wiki/Circular_dependency)), and implements a [microservice structure](https://en.wikipedia.org/wiki/Microservices) in your game.

This framework was originally inspired by @Sleitnick's [Aero Game Framework](https://github.com/Sleitnick/AeroGameFramework).

# Installation instructions

## Rojo users

Add this repository as a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to your project's repository.
The framework consists of 3 components : the server, the client, and the core. You will need to place each of these components into the proper location in your rojo config file.

Example:
```json
{
	"name" : "My awesome project",
	"tree" : {
		"$className" : "DataModel",

		"ReplicatedStorage" : {
			"$className" : "ReplicatedStorage",

			"Framework_Core" : {
				"$path" : "Submodules/DragonEngine/shared.project.json"
			}
		},

		"ServerScriptService" : {
			"$className" : "ServerScriptService",

			"Framework_Server" : {
				"$path" : "Submodules/DragonEngine/server.project.json"
			}
		},

		"StarterPlayer" : {
			"$className" : "StarterPlayer",

			"StarterPlayerScripts" : {
				"$className" : "StarterPlayerScripts",

				"Framework_Client" : {
					"$path" : "Submodules/DragonEngine/client.project.json"
					}
			}
		}
	}
}
```

## Studio users

Download the `rbxmx` (model) files from the [latest release](https://github.com/Reshiram110/Dragon-Engine/releases) page.
Insert them into the following locations in studio:

`Framework_Server` -> `ServerScriptService`

`Framework_Client` -> `StarterPlayer.StarterPlayerScripts`

`Framework_Core` -> `ReplicatedStorage`

For full documentation, please head over to https://Reshiram110.github.io/Dragon-Engine.
