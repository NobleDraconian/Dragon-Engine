--[[
	Debug Service

	This services handles various debugging tasks for the engine, such as displaying running services.
	It utilizes the Cmdr package.
--]]

local DebugService={}

---------------------
-- Roblox Services --
---------------------

--------------
-- REQUIRES --
--------------
local Cmdr; --The cmdr package

-------------
-- DEFINES --
-------------
local CommandWhitelist={  --Determines who can run which commands.
	["DefaultAdmin"]={game.CreatorId},
	["DefaultDebug"]={game.CreatorId},
	["DefaultUtil"]={game.CreatorId},
	["Help"]={game.CreatorId}
}


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : SetCommandWhitelist
-- @Description : Replaces the default command whitelist keys with the ones in the given dictionary table.
-- @Params : table "Whitelist" - The dictionary whitelist to replace the default one with.
--                               Any unknown default groups specified will be ignored.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugService:SetCommandWhitelist(Whitelist)
	for Key,Table in pairs(Whitelist) do
		if CommandWhitelist[Key]~=nil then
			CommandWhitelist[Key]=Table
		else --Developer tried patching a non-existant default group.
			self:Log("[Debug Service] SetCommandWhitelist() : Unknown default group '"..Key.."' specified, ignoring.","Warning")
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugService:Init()

	-----------------
	-- Set up Cmdr --
	-----------------
	Cmdr=self.Utils.Cmdr
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(script.Commands)

	----------------------------------
	-- Set up security for commands --
	----------------------------------
	Cmdr.Registry:RegisterHook("BeforeRun",function(Context)
		if CommandWhitelist[Context.Group]~=nil then --Wasn't a custom devloper Group
			local CanExecute=false

			for Index=1,#CommandWhitelist[Context.Group] do
				if CommandWhitelist[Context.Group][Index]==Context.Executor.UserId then
					CanExecute=true
					break
				end
			end
			if not CanExecute then
				return "You don't have permission to run this command!"
			end
		end
	end)

	self:DebugLog("[Debug Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugService:Start()
	self:DebugLog("[Debug Service] Started!")

end

return DebugService