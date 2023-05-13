---@param ctx ScanContext
---@return boolean
local function scan_tick_crafting_limit(ctx)
	local assemblers = ctx:get_crafting_machines()
	local limited_assemblers = 0
	for _, assembler in pairs(assemblers) do
		local recipe = assembler.get_recipe()
		if recipe then
			local recipes_per_tick = assembler.crafting_speed / recipe.energy / 60
			local productivity_recipes_per_tick = recipes_per_tick * assembler.productivity_bonus
			if recipes_per_tick > 1 then
				if not recipe.hidden or assembler.beacons_count and assembler.beacons_count > 0 then
					limited_assemblers = limited_assemblers + 1
					local msg = ("trying to craft %.2f recipes per tick"):format(recipes_per_tick)
					if productivity_recipes_per_tick > 0 then
						if productivity_recipes_per_tick > 1 then
							msg = msg .. (", and productivity also tries to add %.2f"):format(productivity_recipes_per_tick)
						else
							msg = msg .. ("; although productivity still adds %.2f"):format(productivity_recipes_per_tick)
						end
					end
					ctx:mark_entity(assembler, msg, {
						type = "entity",
						name = assembler.name,
					})
				end
			end
		end
	end
	if limited_assemblers > 0 then
		ctx:print_summary { "rsbs-tick-craft-limit.summary", limited_assemblers }
		return true
	end
	return false
end

return scan_tick_crafting_limit
