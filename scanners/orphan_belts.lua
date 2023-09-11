local scan_underground_orphans = require "scanners.common.underground_orphans"

---@param ctx ScanContext
---@param options OrphanOptions
---@return boolean
local function scan_orphan_belts(ctx, options)
	return scan_underground_orphans(ctx, "underground-belt", options)
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-orphan-belts"].value and scan_orphan_belts(ctx, {
		only_possible_neighbor = settings["rsbs-scan-orphan-belts-only-possible-neighbor"].value,
		extra_search_distance = settings["rsbs-scan-orphans-neighbor-search-distance"].value,
	})
end
