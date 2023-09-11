---@param ctx ScanContext
---@return boolean
local function scan_low_power(ctx)
	-- Just scan crafting machines for now
	local assemblers = ctx:get_crafting_machines()
	---@type table<uint,true>
	local networks_scanned = {}
	local low_power_assemblers = 0
	for _, assembler in pairs(assemblers) do
		local network = assembler.electric_network_id
		if network and not networks_scanned[network] then
			networks_scanned[network] = true
			local buffer = assembler.electric_buffer_size
			if buffer and buffer > 0 then
				local energy = assembler.energy
				if energy > 0 and energy < buffer then
					low_power_assemblers = low_power_assemblers + 1
					ctx:mark_entity(assembler, "low power", {
						type = "item",
						name = "big-electric-pole",
					})
				end
			end
		end
	end
	if low_power_assemblers > 0 then
		ctx:print_summary { "rsbs-low-power.summary", low_power_assemblers }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-low-power"].value and scan_low_power(ctx)
end
