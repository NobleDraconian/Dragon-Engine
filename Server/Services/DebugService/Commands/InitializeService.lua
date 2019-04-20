return{
	Name="DragonEngine.InitializeService",
	Aliases={"de.initserv"},
	Description="Initializes the specified service.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Service Name",
			Description="The name of the service to initialize."
		}
	}
}