if __DebugAdapter then
	for _, name in pairs { 'Contains', 'RoundTwoPlaces', 'Assemblers', 'GetAssemblers', 'EnableMapMarkers', 'EnableForceVisibility', 'Marked', 'MarkEntity' } do
		__DebugAdapter.defineGlobal(name)
	end
end

---@param number number
---@return number
function RoundTwoPlaces(number)
	return math.ceil(number * 1e2) / 1e2
end

Assemblers = nil

---@param surface LuaSurface
---@param area BoundingBox
---@return LuaEntity[]
function GetAssemblers(surface, area)
	Assemblers = Assemblers or surface.find_entities_filtered {
		area = area,
		type = { "assembling-machine", "rocket-silo", "furnace" },
	}
	return Assemblers
end

EnableMapMarkers = false
EnableForceVisibility = false
Marked = {}

---@param entity LuaEntity
---@param player LuaPlayer Player this entity should be marked for
---@param text string
---@param icon SignalID|nil
function MarkEntity(entity, player, text, icon)
	local times_marked = Marked[entity.unit_number] or 0
	Marked[entity.unit_number] = times_marked + 1

	table.insert(global.render_objs[player.index], rendering.draw_rectangle {
		surface = entity.surface,
		left_top = entity.bounding_box.left_top,
		right_bottom = entity.bounding_box.right_bottom,
		players = EnableForceVisibility and nil or { player },
		forces = EnableForceVisibility and { player.force } or nil,

		color = { .90, .30, .03, .4 },
		filled = false,
		width = 5,
	})
	table.insert(global.render_objs[player.index], rendering.draw_text {
		surface = entity.surface,
		target = entity,
		target_offset = { 0, math.floor((times_marked + 1) / 2) * (times_marked % 2 * 2 - 1) * 1 },
		alignment = "center",
		vertical_alignment = "middle",
		orientation = .1,
		players = EnableForceVisibility and nil or { player },
		forces = EnableForceVisibility and { player.force } or nil,

		text = text,
		font = "default-bold",
		scale = 1.2,
		scale_with_zoom = true,
		color = { 0, 1, 1 },
	})
	if EnableMapMarkers then
		table.insert(global.chart_tags[player.index], player.force.add_chart_tag(entity.surface, {
			position = entity.position,
			last_user = player,
			text = ("[color=red]%s[/color]"):format(text), -- Unfortunately, chart tags currently do not accept LocalisedStrings
			icon = icon,
		}))
	end
end
