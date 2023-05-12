local scan_underground_orphans = require "scanners.common.underground_orphans"

---@param ctx ScanContext
---@param options OrphanOptions
---@return boolean
local function scan_orphan_belts(ctx, options)
	return scan_underground_orphans(ctx, "underground-belt", options)
end

return scan_orphan_belts
