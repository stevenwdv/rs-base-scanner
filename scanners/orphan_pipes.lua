local scan_underground_orphans = require "scanners.common.underground_orphans"

---@param ctx ScanContext
---@param options OrphanOptions
---@return boolean
local function scan_orphan_pipes(ctx, options)
	return scan_underground_orphans(ctx, "pipe-to-ground", options)
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-orphan-pipes"].value and scan_orphan_pipes(ctx, {
		only_possible_neighbor = settings["rsbs-scan-orphan-pipes-only-possible-neighbor"].value,
		extra_search_distance = settings["rsbs-scan-orphans-neighbor-search-distance"].value,
	})
end
