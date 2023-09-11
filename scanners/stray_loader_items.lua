---@param ctx ScanContext
---@return boolean
local function scan_stray_loader_items(ctx)
	local loaders = ctx:find_entities { type = { "loader", "loader-1x1" } }
	local affected_loaders = 0
	for _, loader in pairs(loaders) do
		if loader.loader_type == "input" then
			local container = loader.loader_container
			if container then
				if container.type == "assembling-machine" then
					local recipe = container.get_recipe()
					if recipe then
						---@type table<string,boolean>
						local loader_items = {}
						for n_line = 1, 2 do
							---@cast n_line uint
							for name, _ in pairs(loader.get_transport_line(n_line).get_contents()) do
								loader_items[name] = true
							end
						end

						for _, ingredient in pairs(recipe.ingredients) do
							if ingredient.type == "item" and loader_items[ingredient.name] then
								loader_items[ingredient.name] = nil
							end
						end

						local stray_item = next(loader_items)
						if stray_item then
							affected_loaders = affected_loaders + 1
							ctx:mark_entity(loader, "loader with stray items", {
								type = "item",
								name = stray_item,
							})
						end
					end
				end
			end
		end
	end
	if affected_loaders > 0 then
		ctx:print_summary { "rsbs-stray-loader-items.summary", affected_loaders }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-stray-loader-items"].value and scan_stray_loader_items(ctx)
end
