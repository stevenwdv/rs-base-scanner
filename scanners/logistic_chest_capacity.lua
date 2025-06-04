---@param logistic_point LuaLogisticPoint
---@return table<string,integer> # Maps item names to max counts
local function get_max_logistic_requests(logistic_point)
	---@type table<string,integer>
	local requests = {}
	for _, section in ipairs(logistic_point.sections) do
		if section.active then
			local multiplier = section.multiplier
			for _, filter in ipairs(section.filters) do
				local value = filter.value
				if value and value.type == "item" then
					local count = (filter.max or filter.min) * multiplier
					-- We ignore quality filters for now
					--TODO is it worth supporting these, or at least exact ones?
					-- Usually you probably only request a single quality
					local name = value.name
					local prev_count = requests[name]
					if not prev_count then
						prev_count = 0
					end
					requests[name] = prev_count + count
				end
			end
		end
	end
	return requests
end

---@class LogisticChestCapacityOptions
---@field multiple_requests_only boolean

---@param ctx ScanContext
---@param options LogisticChestCapacityOptions
---@return boolean
local function scan_logistic_chest_capacity(ctx, options)
	local max_robot_payload_size = 1
	local robot_protos = prototypes.get_entity_filtered { {
		filter = "type",
		type = "logistic-robot",
	} }
	for _, robot in pairs(robot_protos) do
		max_robot_payload_size = math.max(max_robot_payload_size, robot.max_payload_size) --[[@as uint]]
	end

	local chests = ctx:find_entities { type = { "logistic-container", "cargo-landing-pad", "space-platform-hub" } }
	local overfull_chests = 0
	for _, chest in pairs(chests) do
		local type = chest.type
		local logistic_point = chest.get_requester_point()
		if logistic_point then
			local requests = get_max_logistic_requests(logistic_point)

			local req_1 = next(requests)
			if not req_1 then
				goto next -- Quick exit
			end
			local multiple_requests = next(requests, req_1) ~= nil
			if not multiple_requests and options.multiple_requests_only then
				goto next
			end

			local hard_limit = logistic_point.exact or logistic_point.trash_not_requested

			--TODO count items already in chest

			local requested_slots = 0
			for item, count in pairs(requests) do
				local stack_size = prototypes.item[item].stack_size
				-- Robots may try to take as much as they can carry, which means they may deposit too much
				if type == "logistic-container" and multiple_requests and not hard_limit then
					count = count + (math.min(max_robot_payload_size, stack_size) - 1)
				end
				requested_slots = requested_slots + math.ceil(count / stack_size) --[[@as uint]]
			end
			local total_slots = #chest.get_inventory(({
				["logistic-container"] = defines.inventory.chest,
				["cargo-landing-pad"] = defines.inventory.cargo_landing_pad_main,
				["space-platform-hub"] = defines.inventory.hub_main,
			})[type])
			if requested_slots > total_slots then
				overfull_chests = overfull_chests + 1
				local extra_slots = requested_slots - total_slots
				local msg = ("requests %s %s too many"):format(extra_slots, extra_slots == 1 and "slot" or "slots")
				ctx:mark_entity(chest, msg, {
					type = "entity",
					name = chest.name,
				})
			end
		end

		::next::
	end
	if overfull_chests > 0 then
		ctx:print_summary { "rsbs-logistic-chest-capacity.summary", overfull_chests }
		return true
	end
	return false
end

---@param settings PlayerSettings
---@param ctx ScanContext
---@return boolean @Found issue?
return function(settings, ctx)
	return settings["rsbs-scan-logistic-chest-capacity"].value and scan_logistic_chest_capacity(ctx, {
		multiple_requests_only =
			settings["rsbs-scan-logistic-chest-capacity-multiple-requests-only"].value,
	})
end
