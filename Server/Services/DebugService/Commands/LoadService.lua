return{
	Name="DragonEngine.LoadService",
	Aliases={"de.loadserv","de.addserv","de.mkserv"},
	Description="Loads the specified service.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Service Module",
			Description="The service module to load"
		}
	}
}