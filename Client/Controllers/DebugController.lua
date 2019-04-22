--[[
	Debug Controller

	This controller handles various debugging tasks for the engine, such as displaying running controllers.
	It utilizes the Cmdr package.
--]]

local DebugController={}

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage=game:GetService("ReplicatedStorage")

-------------
-- DEFINES --
-------------
local Cmdr;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugController:Init()
	Cmdr=require(ReplicatedStorage:WaitForChild("CmdrClient"))
	Cmdr:SetPlaceName(game.Name)
	Cmdr:SetActivationKeys({ Enum.KeyCode.RightControl })

	----------------------------------
	-- Set up security for commands --
	----------------------------------
	Cmdr.Registry:RegisterHook("BeforeRun",function(Context)
		local CommandWhitelist=self.Services.DebugService:GetCommandWhitelist()

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

	self:DebugLog("[Debug Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebugController:Start()
	self:DebugLog("[Debug Controller] Started!")

end

return DebugController