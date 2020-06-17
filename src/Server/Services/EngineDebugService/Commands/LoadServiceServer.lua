return function(Context,ServiceRef)
	Context:Reply("Loading service '"..ServiceRef.."'...")

	local ServiceModule=shared.DragonEngine.Modules.Instance.GetInstanceFromPath(ServiceRef)
	if ServiceModule~=nil then
		local Success,Error=shared.DragonEngine:LoadService(ServiceModule)
		if Success then
			return "Service loaded successfully."
		else
			return "Service could not be loaded : "..Error
		end
	else
		return "Service '"..ServiceRef.."' was not found."
	end
end