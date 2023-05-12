---@param orientation RealOrientation
---@return RealOrientation
local function opposite_orientation(orientation)
	return (orientation + .5) % 1
end

local belt_types = { "linked-belt", "loader-1x1", "loader", "transport-belt", "underground-belt", "splitter" }

---Get number of adjacent belts that were maybe meant to be connected
---@param belt LuaEntity
---@param adjacent LuaEntity[]
---@return integer
local function count_relevant_adjacent(belt, adjacent)
	local adjacent_count = 0
	for _, adj_belt in pairs(adjacent) do
		-- Disregard e.g. perpendicular splitters/loaders just passing by
		if adj_belt ~= belt and (adj_belt.type == "transport-belt" or
				adj_belt.orientation == opposite_orientation(belt.orientation)) then
			adjacent_count = adjacent_count + 1
		end
	end
	return adjacent_count
end

---Get number of adjacent belts that were maybe meant to be connected
---@param belt LuaEntity
---@return integer
local function get_adjacent_belts(belt)
	local vertical = belt.orientation % .5 == 0
	local add = (vertical and belt.bounding_box.right_bottom.y - belt.bounding_box.left_top.y or
		belt.bounding_box.right_bottom.x - belt.bounding_box.left_top.x) / 2 + .5
	local adjacent = belt.surface.find_entities_filtered {
		area = {
			left_top = {
				x = vertical and belt.position.x or belt.position.x - add,
				y = vertical and belt.position.y - add or belt.position.y,
			},
			right_bottom = {
				x = vertical and belt.position.x or belt.position.x + add,
				y = vertical and belt.position.y + add or belt.position.y,
			},
		},
		type = belt_types,
	}
	return count_relevant_adjacent(belt, adjacent)
end

---@param ctx ScanContext
---@return boolean
local function scan_backwards_belts(ctx)
	local belts = ctx:find_entities {
		type = { "linked-belt", "loader-1x1", "loader", "transport-belt", "underground-belt" },
	}
	local backwards_belts = 0
	for i = 1, #belts do
		local belt = belts[i]
		if belt.type == "transport-belt" then
			local belt_neighbours = belt.belt_neighbours
			-- If belt has no connected belts
			if #belt_neighbours.inputs == 0 and #belt_neighbours.outputs == 0 then
				-- But it should probably have been connected to belts on both sides
				if get_adjacent_belts(belt) >= 2 then
					backwards_belts = backwards_belts + 1
					ctx:mark_entity(belt, "backwards belt", {
						type = "entity",
						name = belt.name,
					})
				end
			end
		elseif belt.type == "underground-belt" or belt.type == "linked-belt" then
			---@type LuaEntity?
			local neighbor
			if belt.type == "underground-belt" then
				neighbor = belt.neighbours
			else
				neighbor = belt.linked_belt_neighbour
			end

			if neighbor then
				---Number of backwards belts in this underground pair
				local backwards = 0
				for _, belt in pairs { belt, neighbor } do
					local belt_neighbours = belt.belt_neighbours
					local type = belt.type == "underground-belt" and belt.belt_to_ground_type or belt.linked_belt_type
					-- If underground belt has no connected regular belts
					if (type == "input" and #belt_neighbours.inputs or #belt_neighbours.outputs) == 0 then
						local vertical = belt.orientation % .5 == 0
						local add = (vertical and belt.bounding_box.right_bottom.y - belt.bounding_box.left_top.y or
							belt.bounding_box.right_bottom.x - belt.bounding_box.left_top.x) / 2 + .5
						local orientation = type == "output" and
							belt.orientation or opposite_orientation(belt.orientation)
						local adjacent = belt.surface.find_entities_filtered {
							area = {
								left_top = {
									x = orientation == .75 and belt.position.x - add or belt.position.x,
									y = orientation == 0 and belt.position.y - add or belt.position.y,
								},
								right_bottom = {
									x = orientation == .25 and belt.position.x + add or belt.position.x,
									y = orientation == .5 and belt.position.y + add or belt.position.y,
								},
							},
							type = belt_types,
						}
						-- But it has an adjacent belt in the other direction
						if count_relevant_adjacent(belt, adjacent) >= 1 then
							backwards = backwards + 1
							goto next
						end
					end
					--else:
					break

					::next::
				end
				if backwards == 2 then -- Both belts in the pair are backwards
					backwards_belts = backwards_belts + 1
					ctx:mark_entity(belt,
						belt.type == "underground-belt" and "backwards underground belt" or "backwards linked belt", {
							type = "entity",
							name = belt.name,
						})
				end
			end
		elseif belt.type == "loader-1x1" or belt.type == "loader" then
			if not belt.loader_container then
				backwards_belts = backwards_belts + 1
				ctx:mark_entity(belt, "unconnected loader", {
					type = "entity",
					name = belt.name,
				})
			else
				local belt_neighbours = belt.belt_neighbours
				if (belt.loader_type == "input" and #belt_neighbours.inputs or #belt_neighbours.outputs) == 0 then
					if get_adjacent_belts(belt) >= 1 then
						backwards_belts = backwards_belts + 1
						ctx:mark_entity(belt, "backwards loader", {
							type = "entity",
							name = belt.name,
						})
					end
				end
			end
		end
		--TODO splitter
	end
	if backwards_belts > 0 then
		ctx:print { "rsbs-backwards-belts.summary", backwards_belts }
		return true
	end
	return false
end

return scan_backwards_belts
