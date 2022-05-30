---@param player LuaPlayer
---@param surface LuaSurface
---@param area BoundingBox<int,Position<int,int>>
---@return boolean
local function scan_missing_beacon_modules(player, surface, area)
	local beacons = surface.find_entities_filtered {
		area = area,
		type = "beacon",
	}
	local beacons_missing = 0
	for _, beacon in pairs(beacons) do
		local module_inv = beacon.get_module_inventory()
		if module_inv.find_empty_stack() then
			beacons_missing = beacons_missing + 1
			MarkEntity(beacon, player, "missing modules", {
				type = "item",
				name = "beacon",
			})
		end
	end
	if beacons_missing > 0 then
		player.print { "rsbs-missing-beacon-modules.summary", beacons_missing }
		return true
	end
	return false
end

return scan_missing_beacon_modules
