return function(Context)
	Context:Reply(string.format("%-24s│ %-24s","Module Name","Module Type"))
	Context:Reply(string.rep("▬",48))

	for ModuleName,_ in pairs(shared.DragonEngine.Modules) do
		Context:Reply(string.format("%-24s│ %-24s",ModuleName,"N/A"))
		Context:Reply(string.rep("-",48))
	end

	return "All modules listed."
end