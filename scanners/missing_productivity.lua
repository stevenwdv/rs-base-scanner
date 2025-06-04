local lualib_util = require "__core__.lualib.util"

---@class MissingProductivityOptions
---@field mode "empty-slots"|"non-productivity-slots"|"not-best-available"|"not-minimal-tier"
---@field minimal_tier int?
---@field exclude_recipes string[]

---@param ctx ScanContext
---@param options MissingProductivityOptions
---@return boolean
local function scan_missing_productivity(ctx, options)
	local mode = options.mode

	---@type LuaItemPrototype?
	local productivity_module

	if mode == "not-best-available" or mode == "not-minimal-tier" then
		local modules = prototypes.get_item_filtered { {
			filter = "type",
			type = "module",
		} }
		local best_enabled_tier = 0
		local module_exists = false
		local category_exists = false
		-- Find best or just first productivity module, depending on mode
		for _, module in pairs(modules) do
			if module.category == "productivity" then
				category_exists = true
				local recipes = prototypes.get_recipe_filtered { {
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
				end
			end
		end
		-- Module not found, report error where applicable or return if it just wasn't researched yet
		if not productivity_module then
			if not module_exists then
				if not category_exists then
					ctx:print { "rsbs-missing-productivity.error-category-nonexistent" }
				elseif mode == "not-minimal-tier" then
					ctx:print { "rsbs-missing-productivity.error-tier-nonexistent", options.minimal_tier }
				end
			end
			return false
		end
	end

	local exclude_recipes = util.list_to_map(options.exclude_recipes)

	local assemblers = ctx:get_crafting_machines()
	local assemblers_lacking = 0
	for _, assembler in pairs(assemblers) do
		local assembler_allowed_effects = assembler.prototype.allowed_effects
		if assembler_allowed_effects and assembler_allowed_effects["productivity"] then
			local recipe = assembler.get_recipe()
			if recipe and not exclude_recipes[recipe.name] then
				local recipe_allowed_effects = recipe.prototype.allowed_effects
				if recipe_allowed_effects and recipe_allowed_effects["productivity"] then
					local module_inv = assembler.get_module_inventory()
					if module_inv then
						local is_missing = false
						if mode == "empty-slots" then
							is_missing = module_inv.find_empty_stack() ~= nil
						else
							for i = 1, #module_inv do
								local stack = module_inv[i]
								if stack.valid_for_read then
									local proto = stack.prototype
									if mode == "non-productivity-slots" then
										local effects = proto.module_effects
										---@cast effects -?
										if not (effects.productivity and effects.productivity > 0) then
											is_missing = true
											break
										end
									else
										---@cast productivity_module -?
										if proto.category ~= "productivity" or proto.tier < productivity_module.tier then
											is_missing = true
											break
										end
									end
								else
									is_missing = true
									break
								end
							end
						end
						if is_missing then
							assemblers_lacking = assemblers_lacking + 1
							ctx:mark_entity(assembler, "missing productivity", {
								type = "item",
								name = "productivity-module",
							})
						end
					end
				end
			end
		end
	end
	if assemblers_lacking > 0 then
		if mode == "not-best-available" then
			---@cast productivity_module -?
			ctx:print_summary { "rsbs-missing-productivity.summary-specific", assemblers_lacking,
				productivity_module.name }
		elseif mode == "not-minimal-tier" then
			---@cast productivity_module -?
			ctx:print_summary { "rsbs-missing-productivity.summary-minimal", assemblers_lacking,
				productivity_module.name }
		else
			ctx:print_summary { "rsbs-missing-productivity.summary-any", assemblers_lacking }
		end
		return true
	end
	return false
end

---@param player LuaPlayer
function MissingProductivityCheckSetting(player)
	---@type PlayerSettings
	local mod_settings = player.mod_settings
	local exclude_recipes = lualib_util.split(mod_settings["rsbs-scan-missing-productivity-exclude-recipes"].value, ",%s")
	for _, name in ipairs(exclude_recipes) do
		local recipe = prototypes.recipe[name]
		if recipe then
			local recipe_allowed_effects = recipe.allowed_effects
			if not (recipe_allowed_effects and recipe_allowed_effects["productivity"]) then
				player.print { "rsbs-missing-productivity.warn-excluded-recipe-disallows-productivity", name }
			end
		else
			player.print { "rsbs-missing-productivity.warn-excluded-recipe-nonexistent", name }
		end
	end
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	local mode = settings["rsbs-scan-missing-productivity"].value
	return mode ~= "disable" and scan_missing_productivity(ctx, {
		mode = mode,
		minimal_tier = settings["rsbs-scan-missing-productivity-tier"].value,
		exclude_recipes = lualib_util.split(settings["rsbs-scan-missing-productivity-exclude-recipes"].value, ",%s"),
	})
end
