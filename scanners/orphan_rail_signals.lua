---@param ctx ScanContext
---@return boolean
local function scan_orphan_rail_signals(ctx)
	local signals = ctx:find_entities { type = {"rail-signal", "rail-chain-signal"} }
	local orphan_signals = 0
	for _, signal in pairs(signals) do
		if #signal.get_connected_rails() == 0 then
			orphan_signals = orphan_signals + 1
			ctx:mark_entity(signal, "orphan rail signal", {
				type = "entity",
				name = signal.name,
			})
		end
	end
	if orphan_signals > 0 then
		ctx:print_summary { "rsbs-orphan-rail-signals.summary", orphan_signals }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-orphan-rail-signals"].value and scan_orphan_rail_signals(ctx)
end
