return function(Context,ServiceName)
	Context:Reply("Unloading service '"..ServiceName.."'...")

	if shared.DragonEngineServer.Services[ServiceName]~=nil then
		local Success,Error=shared.DragonEngineServer:UnloadService(ServiceName)
		if Success then
			return "Service unloaded successfully."
		else
			return "Service could not be unloaded : "..Error
		end
	else
		return "Service '"..ServiceName.."' was not found."
	end
end