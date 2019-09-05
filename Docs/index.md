!!! warning "These documentation pages are still a work in progress."
#
![](./Img/DragonEngine_Wallpaper.png)

Opensource singleton based MVC framework for creating your Roblox games

<hr/>

## Overview

Dragon Engine is a singleton-oriented MVC Lua framework designed specificially for Roblox. It seamlessly bridges the gap between the server and client, globally loads modules to allow for easy code communication (this also helps to prevent [cyclic requiring](https://en.wikipedia.org/wiki/Circular_dependency)), and is designed to serve as the 'backbone' of the game it is in, allowing you to build your game's specific codebase on top of it.

The framework features special singletons called "[Services](./Guide/Services_Controllers#services)" and "[Controllers](./Guide/Services_Controllers#controllers)". These are designed to handle your game's code, while keeping all of its independent systems seperate from eachother.

## Why Dragon Engine?

Dragon Engine is designed to unify your codebase and streamline the operations of your game. Instead of worrying about the boilerplate of your game (code communication, architecture, keeping various systems seperated, etc), the framework takes care of this for you, so you can focus on the more important things (like game features and mechanics).

It also forces you to [modularize](https://en.wikipedia.org/wiki/Modular_programming) your code, which has many benefits including reusable code, game systems are easier to reason about independently, development can be quicker when adding new features, code is easier to debug, etc. On top of this, by keeping your game's systems and features seperate, you can even implement flag-based [A/B testing](https://en.wikipedia.org/wiki/A/B_testing), giving you useful insight into how newly added features affect your game!

## Getting started

To get started with the framework, head on over to the [getting started](./Guide/GettingStarted) section!

If you haven't installed the framework already, head to the [installation page](./Guide/Intallation).

## Inspiration

This framework was originally inspired by Crazyman32's [Aero Game Framework](https://github.com/sleitnick/AeroGameFramework).