---
title: Welcome
permalink: /docs/home/
redirect_from: /docs/index.html
---

## Welcome to the documentation pages!
#### This section of the site contains useful documentation for the framework.
#### You can find service API pages, tutorials, and instructions here.
#### NOTE : These documentation pages are currently a work in progress, documentation is incomplete!

## Getting started
Ready to use Dragon Engine? If you haven't already, you'll want to install the framework into your game. Head over to the [installation page](../installation/) for installation instructions.

If you already have the framework installed, then great! We can drive straight into using the framework.

## How is the framework structured?
The framework is structured into 4 parts - `Services`, `Controllers`, `Classes` and `Utils`.
These 4 components work seamlessly together to run your game.

### Services
Services are special modules. Unlike a typical `Class` or `Util` module, Services have a specific format that they have to follow. When the engine server runs, it automatically loads, initializes, and starts any services that it finds (based on its configuration settings). Apon loading a service, the framework will expose itself to the service via the `__index` metatable method.

Essentially, services are designed to run all of the server-sided aspects of your game.

**NOTE: services can only run on the *server*. They are meant to be authoritative and control server state!**

For more information about services, please head over to the [services documentation page](../services/).