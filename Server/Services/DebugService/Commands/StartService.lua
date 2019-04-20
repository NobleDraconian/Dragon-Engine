return{
	Name="DragonEngine.StartService",
	Aliases={"de.startserv"},
	Description="Starts the specified service.",
	Group="DefaultAdmin",
	Args={
		{
			Type="string",
			Name="Service Name",
			Description="The name of the service to start."
		}
	}
}