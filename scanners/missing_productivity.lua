---@class MissingProductivityOptions
---@field mode "empty-slots"|"non-productivity-slots"|"not-best-available"|"not-minimal-tier"
---@field minimal_tier int?

---@param ctx ScanContext
---@param options MissingProductivityOptions
---@return boolean
local function scan_missing_productivity(ctx, options)
	local mode = options.mode

	local module_exists = false
	---@type LuaItemPrototype?
	local productivity_module

	local modules = game.get_filtered_item_prototypes { {
		filter = "type",
		type = "module",
	} }
	local best_enabled_tier = 0
	-- Find best or just first productivity module, depending on mode
	for _, module in pairs(modules) do
		if module.category == "productivity" then
			local recipes = game.get_filtered_recipe_prototypes { {
				filter = "has-product-item",
				elem_filters = { { filter = "name", name = module.name } }
			} }
			local available = false
			for recipe_name in pairs(recipes) do
				-- Note that LuaRecipePrototype.enabled means something completely different
				local force_recipe = ctx.player.force.recipes[recipe_name]
				if force_recipe and force_recipe.enabled then
					available = true
					break
				end
			end
			if mode == "not-best-available" then
				if module.tier > best_enabled_tier then
					module_exists = true
					if available then
						productivity_module = module
						best_enabled_tier = module.tier
					end
				end
			elseif mode == "not-minimal-tier" then
				if module.tier == options.minimal_tier then
					module_exists = true
					if available then
						productivity_module = module
					end
				end
			else
				module_exists = true
				if available then
					productivity_module = module
				end
			end
		end
	end
	if not productivity_module then
		if mode == "not-minimal-tier" and not module_exists then
			ctx:print { "rsbs-missing-productivity.error-tier-nonexistent", options.minimal_tier }
		end
		return false
	end

	---@type table<string,true>
	local limitations = {}
	for _, recipe_name in pairs(productivity_module.limitations) do
		limitations[recipe_name] = true
	end

	local assemblers = ctx:get_crafting_machines()
	local assemblers_lacking = 0
	for _, assembler in pairs(assemblers) do
		if assembler.prototype.allowed_effects["productivity"] then
			local recipe = assembler.get_recipe()
			if recipe and (#productivity_module.limitations == 0 or limitations[recipe.name]) then
				local module_inv = assembler.get_module_inventory()
				if module_inv then
					local icon = "productivity-module"
					local is_missing = false
					if mode == "empty-slots" then
						is_missing = module_inv.find_empty_stack() ~= nil
					else
						for i = 1, #module_inv do
							local stack = module_inv[i]
							if not stack.valid_for_read or stack.prototype.category ~= "productivity" or
								mode ~= "non-productivity-slots" and stack.prototype.tier < productivity_module.tier then
								is_missing = true
							end
						end
					end
					if is_missing then
						assemblers_lacking = assemblers_lacking + 1
						ctx:mark_entity(assembler, "missing productivity", {
							type = "item",
							name = icon,
						})
					end
				end
			end
		end
	end
	if assemblers_lacking > 0 then
		if mode == "not-best-available" then
			ctx:print_summary { "rsbs-missing-productivity.summary-specific", assemblers_lacking, productivity_module.name }
		elseif mode == "not-minimal-tier" then
			ctx:print_summary { "rsbs-missing-productivity.summary-minimal", assemblers_lacking, productivity_module.name }
		else
			ctx:print_summary { "rsbs-missing-productivity.summary-any", assemblers_lacking }
		end
		return true
	end
	return false
end

return scan_missing_productivity
