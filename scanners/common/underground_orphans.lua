local gutils = require "generic_utils"
local futils = require "factorio_utils"
local lualib_util = require "__core__.lualib.util"

local sign = gutils.sign

---@param underground LuaEntity
---@return boolean
local function has_neighbor(underground)
	if underground.type == "pipe-to-ground" then
		local neighbors = underground.neighbours[1]
		-- Quick exit
		if #neighbors == 0 then
			return false
		end
		if #neighbors == 2 then
			return true
		end

		local neighbor = neighbors[1]
		if futils.get_type(neighbor) == "pipe-to-ground" then
			local opposite_dir = lualib_util.oppositedirection(underground.direction)
			if neighbor.direction == opposite_dir then
				local pos = underground.position
				local underground_dir = futils.rotate_quarters({ 0, 1 }, underground.orientation)
				local neighbor_pos = neighbor.position
				local dx, dy = neighbor_pos.x - pos.x, neighbor_pos.y - pos.y
				if sign(dx) == underground_dir[1] and sign(dy) == underground_dir[2] then
					return true
				end
			end
		end
		return false
	else
		return underground.neighbours ~= nil
	end
end

---@class OrphanOptions
---@field only_possible_neighbor boolean
---@field extra_search_distance integer Extra search distance if `only_possible_neighbor` is true

---@param ctx ScanContext
---@param type "underground-belt"|"pipe-to-ground"
---@param options OrphanOptions
---@return boolean
local function scan_underground_orphans(ctx, type, options)
	local scan_belts = type == "underground-belt"

	local undergrounds = ctx:find_entities { type = type }
	local orphans = 0

	---@param underground LuaEntity
	local function mark(underground)
		orphans = orphans + 1
		ctx:mark_entity(underground,
			("orphan %s"):format(scan_belts and "underground belt" or "pipe to ground"), {
				type = "entity",
				name = underground.name,
			})
	end

	---@type table<ChunkID,LuaEntity[]>
	local maybe_orphan = {}
	for _, underground in pairs(undergrounds) do
		if not has_neighbor(underground) then
			local belt_neighbours = scan_belts and underground.belt_neighbours
			if not belt_neighbours or #belt_neighbours.inputs == 0 or #belt_neighbours.outputs == 0 then
				if not options.only_possible_neighbor or (
						belt_neighbours and #belt_neighbours.inputs == 0 and #belt_neighbours.outputs == 0
						or not belt_neighbours and #underground.neighbours[1] == 0)
				then
					mark(underground)
				else
					local chunk_id = futils.get_chunk_id(futils.get_chunk(underground.position))
					local chunk_orphans = maybe_orphan[chunk_id]
					if not chunk_orphans then
						chunk_orphans = {}
						maybe_orphan[chunk_id] = chunk_orphans
					end
					table.insert(chunk_orphans, underground)
				end
			end
		end
	end

	for _, chunk_orphans in pairs(maybe_orphan) do
		for _, underground in pairs(chunk_orphans) do
			local chunk_x, chunk_y = futils.get_chunk(underground.position)

			local underground_distance = underground.prototype.max_underground_distance + options.extra_search_distance
			local underground_chunks = math.ceil(underground_distance / 32)

			local pos = underground.position
			local opposite_dir = lualib_util.oppositedirection(underground.direction)
			local is_belt_input = scan_belts and underground.belt_to_ground_type == "input"
			local underground_dir = futils.rotate_quarters(is_belt_input and { 0, -1 } or { 0, 1 },
				underground.orientation)
			for _chunk_offset = 0, underground_chunks do
				local neighbor_orphans = maybe_orphan[futils.get_chunk_id(chunk_x, chunk_y)]
				if neighbor_orphans then
					for _, neighbor in pairs(neighbor_orphans) do
						if scan_belts and neighbor.name == underground.name and neighbor.direction == underground.direction and
							(neighbor.belt_to_ground_type == "input") ~= is_belt_input
							or not scan_belts and neighbor.direction == opposite_dir
						then
							local neighbor_pos = neighbor.position
							local dx, dy = neighbor_pos.x - pos.x, neighbor_pos.y - pos.y
							if sign(dx) == underground_dir[1] and sign(dy) == underground_dir[2]
								and math.abs(dx) < underground_distance and math.abs(dy) < underground_distance
							then
								mark(underground)
								goto end_search
							end
						end
					end
				end

				chunk_x = chunk_x + underground_dir[1]
				chunk_y = chunk_y + underground_dir[2]
			end
			::end_search::
		end
	end

	if orphans > 0 then
		ctx:print_summary { scan_belts and "rsbs-orphan-belts.summary" or "rsbs-orphan-pipes.summary", orphans }
		return true
	end
	return false
end

return scan_underground_orphans
