# HERE BE DRAGONS!
This framework is still a work in progress. I cannot guarantee its stability in stressful environments. Please be aware of this when utilizing it in your game.

<hr></hr>

# About
Dragon Engine is a Lua framework designed specifically for Roblox, it seamlessly bridges the server/client boundary.
It also features a `Service`->`Controller` relationship, with the ability to create Server APIs that clients can access.

# Installation instructions

## Easy installation
Place the [Framework rbxm file](DragonEngine.rbxm) into your game.
1. Drag the contents of the `ServerScriptService` folder into `game.ServerScriptService`.
2. Drag the contents of the `ServerStorage` folder into `game.ServerStorage`.
3. Drag the contents of the `ReplicatedStorage` folder into `game.ReplicatedStorage`.
4. Drag the contents of the `StarterPlayerScripts` folder into `game.StarterPlayer.StarterPlayerScripts`.

## Advanced installation
This project uses the [rofresh file syncer](https://github.com/osyrisrblx/rofresh) to sync files into studio. It can be easily ported to [rojo](https://github.com/LPGhatguy/rojo).
Please note that this project has [dependencies](Submodules/), so be sure to keep the dependencies up to date.