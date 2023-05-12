local scan_underground_orphans = require "scanners.common.underground_orphans"

---@param ctx ScanContext
---@param options OrphanOptions
---@return boolean
local function scan_orphan_pipes(ctx, options)
	return scan_underground_orphans(ctx, "pipe-to-ground", options)
end

return scan_orphan_pipes
