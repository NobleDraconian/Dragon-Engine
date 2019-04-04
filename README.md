# HERE BE DRAGONS!
This framework is still a work in progress. I cannot guarantee its stability in stressful environments. Please be aware of this when utilizing it in your game.

<hr></hr>

# About
Dragon Engine is a Lua framework designed specifically for Roblox, it seamlessly bridges the server/client boundary.
It also features a `Service`->`Controller` relationship, with the ability to create Server APIs that clients can access.

# Installation instructions

## Easy installation
Place the [Framework rbxm file](DragonEngine.rbxm) into your game. Open the `Dragon_Engine` folder that has appeared in the explorer.
1. Update all of the packages contained within the folder to ensure you are installing the latest version of the framework.
2. Drag the contents of the `ServerScriptService` folder into `game.ServerScriptService`.
3. Drag the contents of the `ServerStorage` folder into `game.ServerStorage`.
4. Drag the contents of the `ReplicatedStorage` folder into `game.ReplicatedStorage`.
5. Drag the contents of the `StarterPlayerScripts` folder into `game.StarterPlayer.StarterPlayerScripts`.

## Advanced installation
This project uses the [rofresh file syncer](https://github.com/osyrisrblx/rofresh) to sync files into studio. It can be easily ported to [rojo](https://github.com/LPGhatguy/rojo).
Please note that this project has [dependencies](Submodules/), so be sure to keep the dependencies up to date.

# Updating the framework
If you installed the framework from the rbxm file (easy installation), simply update the individual packages when updates are available to update the framework to the latest version.

If you installed the framework via rofresh/rojo, you will need to fetch the latest version of the framework from the [master branch](https://github.com/Reshiram110/Dragon-Engine). The framework's dependencies use git submodules, so you will also need to bump the submodules to the latest version from origin when desired.