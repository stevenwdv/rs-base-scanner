---@param player LuaPlayer
---@param surface LuaSurface
---@param area BoundingBox
---@return boolean
local function scan_stray_loader_items(player, surface, area)
	local loaders = surface.find_entities_filtered {
		area = area,
		type = { "loader", "loader-1x1" },
	}
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
							MarkEntity(loader, player, "loader with stray items", {
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
		player.print { "rsbs-stray-loader-items.summary", affected_loaders }
		return true
	end
	return false
end

return scan_stray_loader_items
