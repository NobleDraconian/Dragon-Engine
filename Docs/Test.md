hero: This is a test page.

```lua
--[[
	Example Service

	This is an example service to display how a service is created and how it should be formatted.
--]]

local ExampleService={}

---------------------
-- Roblox Services --
---------------------


-------------
-- DEFINES --
-------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Init()

	self:DebugLog("[Example Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ExampleService:Start()
	self:DebugLog("[Example Service] Started!")

end

return ExampleService
```

!!! note
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

Lorem ipsum[^1] dolor sit amet, consectetur adipiscing elit.[^2]