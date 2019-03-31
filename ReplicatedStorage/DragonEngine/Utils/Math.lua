--[[
	Math library
	
	Contains useful math functions
--]]

-------------
-- DEFINES --
-------------
local Rand=Random.new()

local Math={}

function Math:GetRandomVec3FromPart(Part)
    local x = Part.Position.X
	local xS = Part.Size.X / 2
	local y = Part.Position.Y
	local z = Part.Position.Z
	local zS = Part.Size.Z / 2
	local pos = Vector3.new(Rand:NextNumber(math.min(x - xS), math.max(xS + x)), y, Rand:NextNumber(math.min(z - zS), math.max(zS + z)))
	return pos
end

return Math