return{
	Name="DragonEngine.UnloadService",
	Aliases={"de.rmserv"},
	Description="Unloads the specified service.",
	Group="Admin",
	Args={
		{
			Type="string",
			Name="Service Name",
			Description="The name of the service to unload."
		}
	}
}