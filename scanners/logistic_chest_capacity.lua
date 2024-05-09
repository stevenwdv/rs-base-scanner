---@class LogisticChestCapacityOptions
---@field multiple_requests_only boolean

---@param ctx ScanContext
---@param options LogisticChestCapacityOptions
---@return boolean
local function scan_logistic_chest_capacity(ctx, options)
	local chests = ctx:find_entities { type = "logistic-container" }
	local overfull_chests = 0
	for _, chest in pairs(chests) do
		---@type table<string,integer>
		local requests = {}
		local nr_requests = 0
		for slot = 1, chest.request_slot_count do
			---@cast slot uint
			local stack = chest.get_request_slot(slot)
			if stack then
				local prev_count = requests[stack.name]
				if not prev_count then
					prev_count = 0
					nr_requests = nr_requests + 1
				end
				requests[stack.name] = prev_count + stack.count
			end
		end

		if nr_requests == 0 then
			goto next -- Quick exit
		end

		if options.multiple_requests_only and nr_requests == 1 then
			goto next
		end

		local requested_slots = 0
		for item, count in pairs(requests) do
			requested_slots = requested_slots + math.ceil(count / game.item_prototypes[item].stack_size)
		end
		local total_slots = chest.prototype.get_inventory_size(defines.inventory.chest)
		if requested_slots > total_slots then
			overfull_chests = overfull_chests + 1
			local extra_slots = requested_slots - total_slots
			local msg = ("requests %s %s too many"):format(extra_slots, extra_slots == 1 and "slot" or "slots")
			ctx:mark_entity(chest, msg, {
				type = "entity",
				name = chest.name,
			})
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
