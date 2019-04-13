return{
	Name="DragonEngine.DisplayControllers",
	Aliases={"de.dispcont"},
	Description="Dispalys a list of currently loaded controllers.",
	Group="Admin",
	Args={},

	Run=function(Context)
		Context:Reply("")
		Context:Reply("Currently loaded Controllers")
		Context:Reply("=========================")
		for ControllerName,_ in pairs(shared.DragonEngine.Controllers) do
			Context:Reply("- "..ControllerName)
		end
		Context:Reply("")
	end
}