return function(Context,ServiceName)
	Context:Reply("Initializing service '"..ServiceName.."'...")

	if shared.DragonEngineServer.Services[ServiceName]~=nil then
		local Success,Error=shared.DragonEngineServer:InitializeService(ServiceName)

		if Success then
			return "Service initialized successfully."
		else
			return "Service could not be initialized : "..Error
		end
	else
		return "Service '"..ServiceName.."' was not found."
	end
end