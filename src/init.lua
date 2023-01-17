local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Server.Core.DragonEngine)
else
	return require(script.Client.Core.DragonEngine)
end