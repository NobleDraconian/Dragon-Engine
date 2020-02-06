return function(Context)
	Context:Reply(string.format("%-24s│ %-24s","Service Name","Status"))
	Context:Reply(string.rep("▬",48))
	for ServiceName,Service in pairs(shared.DragonEngine.Services) do
		Context:Reply(string.format("%-24s│ %-24s",ServiceName,Service.Status))
		Context:Reply(string.rep("-",48))
	end

	return "All Services listed."
end