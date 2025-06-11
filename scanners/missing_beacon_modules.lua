---@param ctx ScanContext
---@return boolean
local function scan_missing_beacon_modules(ctx)
	local beacons = ctx:find_entities { type = "beacon" }
	local beacons_missing = 0
	for _, beacon in ipairs(beacons) do
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
		ctx:print_summary { "rsbs-missing-beacon-modules.summary", beacons_missing }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-missing-beacon-modules"].value and scan_missing_beacon_modules(ctx)
end
