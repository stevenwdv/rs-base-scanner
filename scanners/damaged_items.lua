-- While magazines missing `ammo` and tools missing `durability` do stack and even out damage, items missing `health` do not stack

---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_damaged_items(ctx)
	local damaged_items = 0

	local assemblers = ctx:get_crafting_machines()
	for _, assembler in ipairs(assemblers) do
		local input_inventory = assembler.get_inventory(defines.inventory.assembling_machine_input)
		if input_inventory then
			for i = 1, #input_inventory do
				local stack = input_inventory[i]
				if stack.valid_for_read and stack.health < 1 then
					damaged_items = damaged_items + 1
					ctx:mark_entity(assembler, "machine contains damaged item", {
						type = "entity",
						name = assembler.name,
					})
				end
			end
		end
	end

	local inserters = ctx:find_entities { type = "inserter" }
	for _, inserter in ipairs(inserters) do
		local stack = inserter.held_stack
		if stack.valid_for_read and stack.health < 1 then
			damaged_items = damaged_items + 1
			ctx:mark_entity(inserter, "inserter is holding damaged item", {
				type = "entity",
				name = inserter.name,
			})
		end
	end

	local loaders = ctx:find_entities { type = { "loader", "loader-1x1" } }
	for _, loader in ipairs(loaders) do
		if loader.loader_type == "input" then
			for n_line = 1, 2 do
				local transport_line = loader.get_transport_line(n_line)
				for i = 1, #transport_line do
					local stack = transport_line[i]
					if stack.valid_for_read and stack.health < 1 then
						damaged_items = damaged_items + 1
						ctx:mark_entity(loader, "loader contains damaged item", {
							type = "entity",
							name = loader.name,
						})
					end
				end
			end
		end
	end

	if damaged_items > 0 then
		ctx:print_summary { "rsbs-damaged-items.summary", damaged_items }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-damaged-items"].value and scan_damaged_items(ctx)
end
