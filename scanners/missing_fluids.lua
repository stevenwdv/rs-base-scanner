---@param ctx ScanContext
---@return boolean
local function scan_missing_fluids(ctx)
	local assemblers = ctx:get_crafting_machines()
	local missing_fluids = 0
	for _, assembler in pairs(assemblers) do
		local fluidboxes = assembler.fluidbox
		for n_box = 1, #fluidboxes do
			---@cast n_box uint
			if #fluidboxes.get_connections(n_box) == 0 then
				local filter = fluidboxes.get_filter(n_box)
				if filter then
					missing_fluids = missing_fluids + 1
					ctx:mark_entity(assembler, "missing fluid connection", {
						type = "fluid",
						name = filter.name,
					})
				end
				break
			end
		end
	end
	if missing_fluids > 0 then
		ctx:print_summary { "rsbs-missing-fluids.summary", missing_fluids }
		return true
	end
	return false
end

return scan_missing_fluids
