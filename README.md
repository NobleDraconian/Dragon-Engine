# HERE BE DRAGONS!
This framework is still a work in progress. I cannot guarantee its stability in stressful environments. Please be aware of this when utilizing it in your game.

Documentation is coming soon™.

# About
![](images/Dragon_Engine_Logo.png)

Dragon Engine is a Lua framework designed specificially for Roblox.
It bridges the gap between the server and client, globally loads modules to allow for easy communication (this also helps to prevent [cyclic requiring](https://en.wikipedia.org/wiki/Circular_dependency)), and is designed to serve as the 'backbone' of the game it is in.

The general relationship between the server and client in the framework is `Service`->`Controller`, where services are authoritative, and manage server state while `Controllers` manage client state. `Controllers` can call APIs that the services define.

# Installation
There are a few ways to install the framework into your game.

## Easy installation
TBD

## Advanced installation
This project uses [rojo](https://github.com/LPGhatguy/rojo) to sync into studio. If you have rojo, simply sync the framework into your game.

This framework can also be added as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) if you have your own method of syncing the framework files into the game. If you choose to use this method, please consult [the rojo project configuration file](default.project.json) for information on where the files should be placed in the game.

### Dependencies
This project depends on [my library repo](https://github.com/Reshiram110/Roblox-LibModules) as a submodule.

# Documentation
For full documentation, please click [here](https://Reshiram110.github.io/Dragon-Engine)