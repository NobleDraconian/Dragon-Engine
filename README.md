# HERE BE DRAGONS!
This framework is still a work in progress. I cannot guarantee its stability in stressful environments. Please be aware of this when utilizing it in your game.

<hr></hr>

# About
Dragon Engine is a Lua framework designed specifically for Roblox, it seamlessly bridges the server/client boundary.
It also features a `Service`->`Controller` relationship, with the ability to create Server APIs that clients can access.

# Installation instructions

## Easy installation
Place the [Framework rbxm file](DragonEngine.rbxm) into your game. Open the `Dragon_Engine` folder that has appeared in the explorer.

1. Drag the contents of the `ServerScriptService` folder into `game.ServerScriptService`.
2. Drag the contents of the `ServerStorage` folder into `game.ServerStorage`.
3. Drag the contents of the `ReplicatedStorage` folder into `game.ReplicatedStorage`.
4. Drag the contents of the `StarterPlayerScripts` folder into `game.StarterPlayer.StarterPlayerScripts`.

## Advanced installation
This project uses the [rofresh file syncer](https://github.com/osyrisrblx/rofresh) to sync files into studio. It can be easily ported to [rojo](https://github.com/LPGhatguy/rojo).
Please note that this project has [dependencies](Submodules/) via submodules.

# Updating the framework
You can update the framework by following the steps in the "Easy installation" section.

If you installed the framework via rofresh/rojo, you will need to fetch the latest version of the framework from the [master branch](https://github.com/Reshiram110/Dragon-Engine).

PRO TIP : If you plan on using the framework across multiple games/places, I would suggest that you convert the framework root folders into packages, so you can push updates to every place that uses them.
Here's an example of how I auto update the framework across my games/places:
[](Docs/Img/PackageUpdating.PNG)
Notice how instead of being regular folders, every framework root folder is actually a package. This allows you to easily push framework updates across your games/places. It also has the benefit of being able to roll back framework updates if you wish to roll back the framework version installed in your games/places.