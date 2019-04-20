return{
	Name="DragonEngine.InitializeController",
	Aliases={"de.initcont"},
	Description="Initializes the specified controller.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Controllere Name",
			Description="The name of the controller to initialize."
		}
	},

	Run=function(Context,ControllerName)
		Context:Reply("Initializing controller '"..ControllerName.."'...")

		if shared.DragonEngine.Controllers[ControllerName]~=nil then
			local Success,Error=shared.DragonEngine:InitializeController(ControllerName)
			if Success then
				return "Controller initialized successfully."
			else
				return "Controller could not be initialized : "..Error
			end
		else
			return "Controller '"..ControllerName.."' not found."
		end
	end
}