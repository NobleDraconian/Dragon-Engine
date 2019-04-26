return{
	Name="DragonEngine.UnloadController",
	Aliases={"de.rmcont"},
	Description="Unloads the specified controller.",
	Group="DefaultAdmin",
	Args={
		{
			Type="string",
			Name="Controllere Name",
			Description="The name of the controller to unload."
		}
	},

	Run=function(Context,ControllerName)
		Context:Reply("Unloading controller '"..ControllerName.."'...")

		if shared.DragonEngine.Controllers[ControllerName]~=nil then
			local Success,Error=shared.DragonEngine:UnloadController(ControllerName)
			if Success then
				return "Controller unloaded successfully."
			else
				return "Controller could not be unloaded : "..Error
			end
		else
			return "Controller '"..ControllerName.."' not found."
		end
	end
}