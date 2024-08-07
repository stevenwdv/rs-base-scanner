---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_unfiltered_chests(ctx)
	-- This is not perfect, as it won't include all modded inserters.
	-- However, we don't know how far from the chest they can be
	local additional_inserter_search_radius = 2
	local allowed_input_types = { ["logistic-container"] = true, ["container"] = true }

	---@type string[]
	local storage_chest_names = {}
	local logistic_chest_protos = game.get_filtered_entity_prototypes { {
		filter = "type",
		type = "logistic-container",
	} }
	for _, proto in pairs(logistic_chest_protos) do
		if proto.logistic_mode == "storage" then
			table.insert(storage_chest_names, proto.name)
		end
	end
	local storage_chests = ctx:find_entities { name = storage_chest_names }
	local unfiltered_chests = 0
	for _, storage_chest in pairs(storage_chests) do
		if not storage_chest.storage_filter then
			-- Inserters and loaders that may be pointing into this chest
			local inserters = ctx:find_entities {
				area = {
					left_top = {
						storage_chest.bounding_box.left_top.x - additional_inserter_search_radius,
						storage_chest.bounding_box.left_top.y - additional_inserter_search_radius,
					},
					right_bottom = {
						storage_chest.bounding_box.right_bottom.x + additional_inserter_search_radius,
						storage_chest.bounding_box.right_bottom.y + additional_inserter_search_radius,
					},
				},
				type = {"inserter", "loader", "loader-1x1"},
			}
			for _, inserter in pairs(inserters) do
				if (inserter.type == "inserter" and inserter.drop_target == storage_chest
					and inserter.pickup_target and not allowed_input_types[inserter.pickup_target.type])
					or (inserter.type ~= "inserter" and inserter.loader_type == "input" and inserter.loader_container == storage_chest) then
					unfiltered_chests = unfiltered_chests + 1
					ctx:mark_entity(storage_chest, "unfiltered storage chest", {
						type = "entity",
						name = storage_chest.name,
					})
					break
				end
			end
		end
	end

	if unfiltered_chests > 0 then
		ctx:print_summary { "rsbs-unfiltered-chests.summary", unfiltered_chests }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-unfiltered-chests"].value and scan_unfiltered_chests(ctx)
end
