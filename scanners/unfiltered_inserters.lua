---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_unfiltered_inserters(ctx)
	-- This is not perfect, as it won't include all modded inserters.
	-- However, we don't know how far from the chest they can be
	local additional_inserter_search_radius = 2

	local assemblers = ctx:get_crafting_machines()
	local unfiltered_inserters = 0
	for _, assembler in pairs(assemblers) do
		local recipe = assembler.get_recipe()
		-- Filtering only makes sense if we have multiple products
		if recipe and #recipe.products > 1 then
			-- Inserters that may be taking items from this machine
			local inserters = ctx:find_entities {
				area = {
					left_top = {
						assembler.bounding_box.left_top.x - additional_inserter_search_radius,
						assembler.bounding_box.left_top.y - additional_inserter_search_radius,
					},
					right_bottom = {
						assembler.bounding_box.right_bottom.x + additional_inserter_search_radius,
						assembler.bounding_box.right_bottom.y + additional_inserter_search_radius,
					},
				},
				type = { "inserter" },
			}
			local has_filtered = false
			for _, inserter in pairs(inserters) do
				if inserter.pickup_target == assembler then
					if inserter.use_filters then
						has_filtered = true
						break
					end
				end
			end
			if has_filtered then
				for _, inserter in pairs(inserters) do
					if inserter.pickup_target == assembler then
						if not inserter.use_filters then
							unfiltered_inserters = unfiltered_inserters + 1
							ctx:mark_entity(inserter, "unfiltered inserter", {
								type = "entity",
								name = inserter.name,
							})
						end
					end
				end
			end
		end
	end

	if unfiltered_inserters > 0 then
		ctx:print_summary { "rsbs-unfiltered-inserters.summary", unfiltered_inserters }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-unfiltered-inserters"].value and scan_unfiltered_inserters(ctx)
end
