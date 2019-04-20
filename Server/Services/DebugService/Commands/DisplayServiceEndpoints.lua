local ReplicatedStorage = game:GetService("ReplicatedStorage")

return{
	Name="DragonEngine.DisplayServiceEndpoints",
	Aliases={"de.dispservep"},
	Description="Displays the given service's endpoints.",
	Group="DefaultAdmin",
	Args={
		{
			Type="string",
			Name="Service Name",
			Description="The name of the service"
		}
	},

	Run=function(Context,ServiceName)
		if ReplicatedStorage.DragonEngine.Network.Service_Endpoints:FindFirstChild(ServiceName)~=nil then
			for _,Endpoint in pairs(ReplicatedStorage.DragonEngine.Network.Service_Endpoints[ServiceName]:GetChildren()) do
				if Endpoint:IsA("RemoteFunction") then
					Context:Reply("Function '"..Endpoint.Name.."'")
				elseif Endpoint:IsA("RemoteEvent") then
					Context:Reply("Event '"..Endpoint.Name.."'")
				end
			end
		else
			return "Service '"..ServiceName.."' was not found or has no endpoints."
		end
	end
}