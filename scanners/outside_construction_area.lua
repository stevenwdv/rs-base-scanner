local futils = require "factorio_utils"

---@param ctx ScanContext
---@return boolean @Found issue?
local function scan_outside_construction_area(ctx)
	---Maximum marked entities per chunk
	local max_per_chunk = 20

	local entities = ctx:find_entities { type = { "entity-ghost", "tile-ghost", "item-request-proxy" } }
	local outside_construction_area = 0
	local omitted_markings = false
	---@type table<ChunkID,integer>
	local entities_per_chunk = {}
	for _, entity in pairs(entities) do
		-- Note that indeed only the center of the entity is important
		if #ctx.surface.find_logistic_networks_by_construction_area(entity.position, entity.force) == 0 then
			outside_construction_area = outside_construction_area + 1

			local chunk_id      = futils.get_chunk_id(futils.get_chunk(entity.position))
			local in_this_chunk = entities_per_chunk[chunk_id] or 0
			if in_this_chunk < max_per_chunk then
				in_this_chunk = in_this_chunk + 1
				entities_per_chunk[chunk_id] = in_this_chunk
				local msg = "outside construction range"
				if in_this_chunk == max_per_chunk then
					msg = msg .. " (possibly more around here)"
				end
				ctx:mark_entity(entity, msg, {
					type = "entity",
					name = entity.name,
				})
			else
				omitted_markings = true
			end
		end
	end
	if outside_construction_area > 0 then
		---@type LocalisedString
		local msg = { "rsbs-outside-construction-area.summary", outside_construction_area }
		if omitted_markings then
			msg = { "", msg, " ", { "rsbs-outside-construction-area.markings-omitted" } }
		end
		ctx:print_summary(msg)
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-outside-construction-area"].value and scan_outside_construction_area(ctx)
end
