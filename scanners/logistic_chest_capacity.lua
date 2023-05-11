---@param ctx ScanContext
---@return boolean
local function scan_logistic_chest_capacity(ctx)
	local chests = ctx.surface.find_entities_filtered {
		area = ctx.area,
		type = "logistic-container",
	}
	local overfull_chests = 0
	for _, chest in pairs(chests) do
		---@type table<string,integer>
		local requests = {}
		for slot = 1, chest.request_slot_count do
			local stack = chest.get_request_slot(slot)
			if stack then
				local prev_count = requests[stack.name]
				if not prev_count then
					prev_count = 0
				end
				requests[stack.name] = prev_count + stack.count
			end
		end

		local n_requested_slots = 0
		for item, count in pairs(requests) do
			n_requested_slots = n_requested_slots + math.ceil(count / game.item_prototypes[item].stack_size)
		end
		local n_total_slots = chest.prototype.get_inventory_size(defines.inventory.chest)
		if n_requested_slots > n_total_slots then
			overfull_chests = overfull_chests + 1
			local extra_slots = n_requested_slots - n_total_slots
			local msg = ("requests %s %s too many"):format(extra_slots, extra_slots == 1 and "slot" or "slots")
			ctx:mark_entity(chest, msg, {
				type = "entity",
				name = chest.name,
			})
		end
	end
	if overfull_chests > 0 then
		ctx:print { "rsbs-logistic-chest-capacity.summary", overfull_chests }
		return true
	end
	return false
end

return scan_logistic_chest_capacity
