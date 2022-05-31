local belt_types = { "linked-belt", "loader-1x1", "loader", "transport-belt", "underground-belt", "splitter" }

---@class ScanBeltOptions
---@field splitters_only boolean
---@field single_only boolean
---@field strict_splitters boolean

---@param player LuaPlayer
---@param surface LuaSurface
---@param area BoundingBox<int,Position<int,int>>
---@param options ScanBeltOptions
---@return boolean
local function scan_belt_capacity(player, surface, area, options)
	local belts = surface.find_entities_filtered {
		area = area,
		type = splitters_only and { "splitter" } or belt_types,
	}
	local slow_belts = 0
	for n_belt = 1, #belts do
		local belt = belts[n_belt]
		local neighbors = belt.belt_neighbours
		local speed = belt.prototype.belt_speed
		if options.single_only then
			local outputs = neighbors.outputs
			if #outputs > 0 then
				local out_speed = 0
				for _, output in pairs(outputs) do
					out_speed = out_speed + output.prototype.belt_speed
				end
				if out_speed <= speed then
					goto next_belt
				end
			elseif belt.type == "loader-1x1" or belt.type == "loader" then
				goto next_belt
			end
		end
		local inputs = neighbors.inputs

		-- Count belt as too slow if it has an input that is faster
		-- 	Or for splitters: if the sum of the splitter inputs minus the other splitter outputs (capping all at splitter speed) is faster
		-- Unless the input is an underground/linked belt that has no slower belts as input

		local check_sum = options.strict_splitters and belt.type == "splitter"
		local tot_inp_speed = 0
		for n_inp = 1, #inputs do
			local input = inputs[n_inp]

			local inp_speed = input.prototype.belt_speed

			if check_sum or inp_speed > speed then
				while input.type == "underground-belt" or input.type == "linked-belt" do
					local neighbor = input[
						({ ["underground-belt"] = "neighbours", ["linked-belt"] = "linked_belt_neighbour" })[input.type]]
					if not neighbor then
						break
					end

					local inputs = neighbor.belt_neighbours.inputs
					if #inputs ~= 1 then
						break
					end
					input = inputs[1]
					inp_speed = math.min(inp_speed, input.prototype.belt_speed)
					if not check_sum and inp_speed <= speed then
						goto next_input
					end
				end

				if input.type == "splitter" then
					local neighbors = input.belt_neighbours
					local split_speed = 0
					for _, split_inp in pairs(neighbors.inputs) do
						split_speed = split_speed + math.min(inp_speed, split_inp.prototype.belt_speed)
					end
					for _, split_out in pairs(neighbors.outputs) do
						if split_out ~= belt then
							split_speed = split_speed - math.min(inp_speed, split_out.prototype.belt_speed)
						end
					end
					inp_speed = math.min(inp_speed, split_speed)
				end
			end

			tot_inp_speed = tot_inp_speed + inp_speed

			if check_sum and tot_inp_speed > speed or inp_speed > speed then
				slow_belts = slow_belts + 1
				MarkEntity(belt, player, "too slow", {
					type = "item",
					name = belt.name,
				})
				break
			end

			::next_input::
		end

		::next_belt::
	end
	if slow_belts > 0 then
		player.print { "rsbs-belt-capacity.summary", slow_belts }
		return true
	end
	return false
end

return scan_belt_capacity
