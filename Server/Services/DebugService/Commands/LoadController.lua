return{
	Name="DragonEngine.LoadController",
	Aliases={"de.addcont","de.loadcont","de.mkcont"},
	Description="Loads the specified controller.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Controller Module",
			Description="The controller module to load"
		}
	},

	Run=function(Context,ControllerRef)
		Context:Reply("Loading controller '"..ControllerRef.."'...")

		local ControllerModule=shared.DragonEngine.Utils.Instance.GetInstanceFromPath(ControllerRef)
		if ControllerModule~=nil then
			local Success,Error=shared.DragonEngine:LoadController(ControllerModule)
			if Success then
				return "Controller loaded successfully."
			else
				return "Controller could not be loaded : "..Error
			end
		else
			return "Controller '"..ControllerRef.."' was not found."
		end
	end
}