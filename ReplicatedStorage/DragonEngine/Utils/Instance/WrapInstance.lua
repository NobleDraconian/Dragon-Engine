return function(RealObject)
	local wrapped, Custom;
	local Childs = setmetatable({}, {
		__index = function(t, k)
			--print("__index of Childs:", t, k)
			local stat, val = pcall(function() return RealObject[k] end)
			if stat then
				if type(val) == "function" then
					-- return a wrapper
					return function(a, ...)
						if a == wrapped and k:lower() == "remove" or k:lower() == "destroy" then
							AddChild(nil, wrapped, Custom)
						end
						RealObject[k](RealObject, ...)
					end
				else
					return RealObject[k]
				end
			else
				return RealObject[k] -- this will error, but we want it to
			end
		end,
		__newindex = function() error("This table is read-only") end
	})
	Custom = setmetatable({
			Children = Childs,
			Parent = "nil"		
		}, {
		__index = Childs, 
		__call = function() return RealObject end, 
		__metatable = "The metatable is locked"
	})
	wrapped = setmetatable({}, {
		__index = function(t, k)
			if k == "FindFirstChild" then
				return FindFirstChild
			elseif k == "GetChildren" then
				return GetChildren
			else
				return Custom[k]
			end
		end, 
		__call = function() return RealObject end, 
		__tostring = function() return tostring(RealObject) end,
		__newindex = function(t, k, v)
			if k == "Parent" then
				AddChild(v, t, Custom)
				return
			end
			local stat = pcall(function() return RealObject[k] end)
			if stat then 
				-- Property exists in real object
				-- if name, change name in Childs table
				if k == "Name" then
					if t.Parent ~= "nil" then
						rawset(t.Parent.Children, v, t)
--						print("Changed entry [", v, "] to", t)
						rawset(t.Parent.Children, tostring(t), nil)
--						print("Changed entry [", tostring(t), "] to nil")
--						for _, v in pairs(t.Parent.Children) do
--							print(_)
--						end
					end
				end
				RealObject[k] = v
--				print("Changed name to", RealObject.Name)
--				print("Verification (raw):", rawget(Childs, v))
--				print("Varification (std):", Childs[v])
			else
				-- Property is not real. Add to custom props
				Custom[k] = v 
			end
		end,
		__metatable = "The metatable is locked",
	})
	return wrapped
end