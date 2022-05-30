---@param player LuaPlayer
---@param surface LuaSurface
---@param area BoundingBox
---@return boolean
local function scan_missing_productivity(player, surface, area)
	local productivity_module = game.item_prototypes["productivity-module-3"] --TODO find best enabled module
	local limitations = {}
	for _, recipe_name in pairs(productivity_module.limitations) do
		limitations[recipe_name] = true
	end

	local assemblers = GetAssemblers(surface, area)
	local assemblers_missing = 0
	for _, assembler in pairs(assemblers) do
		local recipe = assembler.get_recipe()
		if recipe and (#productivity_module.limitations == 0 or limitations[recipe.name]) then
			local module_inv = assembler.get_module_inventory()
			if module_inv and module_inv.get_item_count(productivity_module.name) ~= #module_inv then
				assemblers_missing = assemblers_missing + 1
				MarkEntity(assembler, player, "missing productvitity", {
					type = "item",
					name = productivity_module.name,
				})
			end
		end
	end
	if assemblers_missing > 0 then
		player.print { "rsbs-missing-productivity.summary", assemblers_missing, productivity_module.name }
		return true
	end
	return false
end

return scan_missing_productivity
