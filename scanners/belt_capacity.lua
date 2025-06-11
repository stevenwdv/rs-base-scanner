local futils = require "factorio_utils"

local belt_types = {
	"lane-splitter",
	"linked-belt",
	"loader-1x1",
	"loader",
	"splitter",
	"transport-belt",
	"underground-belt",
}

---@class ScanBeltOptions
---@field splitters_only boolean
---@field single_only boolean
---@field strict_splitters boolean

---@param ctx ScanContext
---@param options ScanBeltOptions
---@return boolean
local function scan_belt_capacity(ctx, options)
	local belts = ctx:find_entities {
		type = options.splitters_only and { "splitter" } or belt_types,
	}
	local single_only = options.single_only
	local strict_splitters = options.strict_splitters
	local slow_belts = 0
	for _, belt in ipairs(belts) do
		local neighbors = belt.belt_neighbours
		local speed = belt.prototype.belt_speed
		if single_only then
			local outputs = neighbors.outputs
			if #outputs > 0 then
				local out_speed = 0
				for _, output in ipairs(outputs) do
					out_speed = out_speed + futils.get_prototype(output).belt_speed
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

		local check_sum = strict_splitters and belt.type == "splitter"
		local tot_inp_speed = 0
		for _, input in ipairs(inputs) do
			local inp_speed = futils.get_prototype(input).belt_speed
			---@cast inp_speed -nil

			--FIXME sum if belt self is splitter

			if check_sum or inp_speed > speed then
				-- Get follow underground chain to first non-underground, capping inp_speed
				while input.type == "underground-belt" or input.type == "linked-belt" do
					---@type LuaEntity?
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
					inp_speed = math.min(inp_speed, input.prototype.belt_speed) --[[@as double]]
					if not check_sum and inp_speed <= speed then
						goto next_input
					end
				end

				if input.type == "splitter" then
					local neighbors = input.belt_neighbours
					local split_speed = 0
					for _, split_inp in ipairs(neighbors.inputs) do
						split_speed = split_speed +
							math.min(inp_speed, futils.get_prototype(split_inp).belt_speed) --[[@as double]]
					end
					for _, split_out in ipairs(neighbors.outputs) do
						if split_out ~= belt then
							split_speed = split_speed -
								math.min(inp_speed, futils.get_prototype(split_out).belt_speed) --[[@as double]]
						end
					end
					inp_speed = math.min(inp_speed, split_speed)
				end
			end

			tot_inp_speed = tot_inp_speed + inp_speed

			if check_sum and tot_inp_speed > speed or inp_speed > speed then
				slow_belts = slow_belts + 1
				ctx:mark_entity(belt, "too slow", {
					type = "entity",
					name = belt.name,
				})
				break
			end

			::next_input::
		end

		::next_belt::
	end
	if slow_belts > 0 then
		ctx:print_summary { "rsbs-belt-capacity.summary", slow_belts }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-belt-capacity"].value and scan_belt_capacity(ctx, {
		splitters_only = settings["rsbs-belt-capacity-splitters-only"].value,
		single_only = settings["rsbs-belt-capacity-single-only"].value,
		strict_splitters = settings["rsbs-belt-capacity-strict-splitters"].value,
	})
end
