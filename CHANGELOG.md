## v0.1.0-rc.7
- Expanded logging APIs have been added (#70)

## v0.1.0-rc.6
- Fixed a problem that was missed in the `v0.1.0-rc.5` release (#68).

## v0.1.0-rc.5
- Changes were made to how the framework loads its own resources internally (#65)
- Unnecessary services & controllers have been removed from the framework (#67)

## v0.1.0-rc.4
- Modules that are inside of nested folders are now supported (#54)
- Fixed a bug regarding module lazy-loading (#55)

## v0.1.0-rc.3
- Added API `GetService` to the framework client

## v0.1.0-rc.2
- Fixed an issue regarding settings loading (#52). Developer-specified settings should now load properly when the framework runs.

## v0.1.0-rc.1
- Module APIs have been rewritten, and modules are now lazy-loaded (#50).
- APIs like `GetService()`, `GetController()` and `GetModule()` are now the conventional method of accessing framework resources. Directly referencing internal tables such as `DragonEngine.Modules` is not safe as the internal table structure may change in the future. The APIs ensure a safe way to access these resources.
- The framework is now broken down into 3 packages via rojo project files : the server, the client, and the core/shared part.
- A bug regarding when the framework exposes itself to the global environment has been fixed. The framework will not expose itself to shared until it is finished loading.