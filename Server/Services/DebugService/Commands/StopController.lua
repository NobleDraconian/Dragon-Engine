return{
	Name="DragonEngine.StopController",
	Aliases={"de.stopcont"},
	Description="Stops the specified controller.",
	Group="DefaultAdmin",
	Args={
		{
			Type="string",
			Name="Controllere Name",
			Description="The name of the controller to stop."
		}
	},

	Run=function(Context,ControllerName)
		Context:Reply("Stopping controller '"..ControllerName.."'...")

		if shared.DragonEngine.Controllers[ControllerName]~=nil then
			local Success,Error=shared.DragonEngine:StopController(ControllerName)
			if Success then
				return "Controller stopped successfully."
			else
				return "Controller could not be stopped : "..Error
			end
		else
			return "Controller '"..ControllerName.."' not found."
		end
	end
}