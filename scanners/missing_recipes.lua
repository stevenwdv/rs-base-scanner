---@param ctx ScanContext
---@return boolean
local function scan_missing_recipes(ctx)
	local assemblers = ctx:get_crafting_machines()
	local recipes_missing = 0
	for _, assembler in ipairs(assemblers) do
		if assembler.type == "assembling-machine" and not assembler.get_recipe() then
			local control_behavior = assembler.get_control_behavior() --[[@as LuaAssemblingMachineControlBehavior?]]
			if not (control_behavior and control_behavior.circuit_set_recipe) then
				recipes_missing = recipes_missing + 1
				ctx:mark_entity(assembler, "no recipe", {
					type = "entity",
					name = assembler.name,
				})
			end
		end
	end
	if recipes_missing > 0 then
		ctx:print_summary { "rsbs-missing-recipes.summary", recipes_missing }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-missing-recipes"].value and scan_missing_recipes(ctx)
end
