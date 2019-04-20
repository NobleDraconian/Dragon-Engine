return{
	Name="DragonEngine.StopService",
	Aliases={"de.stopserv"},
	Description="Stops the specified service.",
	Group="DefaultAdmin",
	Args={
		{
			Type="string",
			Name="Service Name",
			Description="The name of the service to stop."
		}
	}
}