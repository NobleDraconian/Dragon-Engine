---
hero: This is a test page.
title: Custom title
---

# Header

Some text

## Testing stuff

???+ warning "CAUTION!"
	Put very very scary text in here. :scream:

!!! note
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

`#!lua setmetatable(Table_1,{__index=Table_2})`

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

!!! note "Code is cool"
	Text describing code
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

???+ note "Collapsable code"
	Text describing code
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

???+ note "Tabbed code blocks"
	This is a block of tabbed code.

	```Bash tab=
	#!/bin/bash
	STR="Hello World!"
	echo $STR
	```

	```C tab=
	#include 

	int main(void) {
	printf("hello, world\n");
	}
	```

	```C++ tab=
	#include <iostream>

	int main() {
	std::cout << "Hello, world!\n";
	return 0;
	}
	```

	```C# tab=
	using System;

	class Program {
	static void Main(string[] args) {
		Console.WriteLine("Hello, world!");
	}
	}
	```

## The bottom
Oh no you've reached the bottom!