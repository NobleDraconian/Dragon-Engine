return{
	Name="DragonEngine.StartController",
	Aliases={"de.startcont"},
	Description="Starts the specified controller.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Controllere Name",
			Description="The name of the controller to start."
		}
	},

	Run=function(Context,ControllerName)
		Context:Reply("Starting controller '"..ControllerName.."'...")

		if shared.DragonEngine.Controllers[ControllerName]~=nil then
			local Success,Error=shared.DragonEngine:StartController(ControllerName)
			if Success then
				return "Controller started successfully."
			else
				return "Controller could not be started : "..Error
			end
		else
			return "Controller '"..ControllerName.."' not found."
		end
	end
}