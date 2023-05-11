---@param ctx ScanContext
---@return boolean
local function scan_missing_beacon_modules(ctx)
	local beacons = ctx.surface.find_entities_filtered {
		area = ctx.area,
		type = "beacon",
	}
	local beacons_missing = 0
	for _, beacon in pairs(beacons) do
		local module_inv = beacon.get_module_inventory()
		---@cast module_inv -nil
		if module_inv.find_empty_stack() then
			beacons_missing = beacons_missing + 1
			ctx:mark_entity(beacon, "missing modules", {
				type = "entity",
				name = beacon.name,
			})
		end
	end
	if beacons_missing > 0 then
		ctx:print { "rsbs-missing-beacon-modules.summary", beacons_missing }
		return true
	end
	return false
end

return scan_missing_beacon_modules
