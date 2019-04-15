return{
	Name="DragonEngine.DisplayControllers",
	Aliases={"de.dispcont"},
	Description="Dispalys a list of currently loaded controllers.",
	Group="Admin",
	Args={},

	Run=function(Context)
		Context:Reply(string.format("%-24s│ %-24s","Controller Name","Status"))
		Context:Reply(string.rep("▬",48))
		for ControllerName,Controller in pairs(shared.DragonEngine.Controllers) do
			Context:Reply(string.format("%-24s│ %-24s",ControllerName,Controller.Status))
			Context:Reply(string.rep("-",48))
		end

		return "All controllers listed."
	end
}