---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_lone_beacons(ctx)
	local beacons = ctx:find_entities { type = "beacon" }
	local lone_beacons = 0
	for _, beacon in pairs(beacons) do
		if #beacon.get_beacon_effect_receivers() == 0 then
			lone_beacons = lone_beacons + 1
			ctx:mark_entity(beacon, "lone beacon", {
				type = "entity",
				name = beacon.name,
			})
		end
	end
	if lone_beacons > 0 then
		ctx:print_summary { "rsbs-lone-beacons.summary", lone_beacons }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-lone-beacons"].value and scan_lone_beacons(ctx)
end
