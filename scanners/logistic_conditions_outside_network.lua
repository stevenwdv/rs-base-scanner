---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_logistic_conditions_outside_network(ctx)
	local entities = ctx:find_entities {
		-- See https://lua-api.factorio.com/stable/classes/LuaGenericOnOffControlBehavior.html
		type = {
			'agricultural-tower',
			'artillery-turret',
			'assembling-machine',
			'asteroid-collector',
			'furnace',
			'inserter',
			'lamp',
			'loader',
			'mining-drill',
			'pump',
			'train-stop',
			'transport-belt',
			'turret',
		},
	}
	local outside_network = 0
	for _, entity in ipairs(entities) do
		local control_behavior = entity.get_control_behavior() --[[@as LuaGenericOnOffControlBehavior?]]
		if control_behavior and control_behavior.connect_to_logistic_network and not entity.logistic_network then
			outside_network = outside_network + 1
			ctx:mark_entity(entity, "logistic condition outside network", {
				type = "entity",
				name = entity.name,
			})
		end
	end

	if outside_network > 0 then
		ctx:print_summary { "rsbs-logistic-conditions-outside-network.summary", outside_network }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-logistic-conditions-outside-network"].value and scan_logistic_conditions_outside_network(ctx)
end
