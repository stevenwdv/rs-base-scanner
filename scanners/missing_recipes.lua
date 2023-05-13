---@param ctx ScanContext
---@return boolean
local function scan_missing_recipes(ctx)
	local assemblers = ctx:get_crafting_machines()
	local recipes_missing = 0
	for _, assembler in pairs(assemblers) do
		if assembler.type == "assembling-machine" and not assembler.get_recipe() then
			recipes_missing = recipes_missing + 1
			ctx:mark_entity(assembler, "no recipe", {
				type = "entity",
				name = assembler.name,
			})
		end
	end
	if recipes_missing > 0 then
		ctx:print_summary { "rsbs-missing-recipes.summary", recipes_missing }
		return true
	end
	return false
end

return scan_missing_recipes
