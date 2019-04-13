return function(Context)
	Context:Reply("")
	Context:Reply("Currently loaded services")
	Context:Reply("=========================")
	for ServiceName,_ in pairs(shared.DragonEngineServer.Services) do
		Context:Reply("- "..ServiceName)
	end
	Context:Reply("")
end