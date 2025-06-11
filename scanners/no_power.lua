---@param ctx ScanContext
---@return boolean
local function scan_no_power(ctx)
	-- Just scan crafting machines for now
	local assemblers = ctx:get_crafting_machines()
	---@type table<uint,true>
	local networks_scanned = {}
	local no_power_assemblers = 0
	for _, assembler in ipairs(assemblers) do
		local network = assembler.electric_network_id
		if not network or not networks_scanned[network] then
			if network then networks_scanned[network] = true end
			local buffer = assembler.electric_buffer_size
			if buffer and buffer > 0 and assembler.energy == 0 then
				no_power_assemblers = no_power_assemblers + 1
				ctx:mark_entity(assembler, "no power", {
					type = "item",
					name = "big-electric-pole",
				})
			end
		end
	end
	if no_power_assemblers > 0 then
		ctx:print_summary { "rsbs-no-power.summary", no_power_assemblers }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-no-power"].value and scan_no_power(ctx)
end
