local futils = require "factorio_utils"

---@class ScanOptions
---@field player LuaPlayer
---@field surface LuaSurface
---@field area BoundingBox
---@field enable_map_markers boolean
---@field enable_force_visibility boolean Enable visibility of drawn markings for the whole force

---@class ScanContext : ScanOptions
local ScanContext = {
	---@type LuaSurface
	surface = nil,
	---@type BoundingBox
	area = nil,

	enable_map_markers = false,
	enable_force_visibility = false,

	---@protected
	---@type table<uint,integer> Maps unit numbers to number of times they were marked
	marked_entities = nil,

	---@protected
	---@type LuaEntity[]?
	crafting_machines = nil,

	---@protected
	printed_separator = false,
}
ScanContext.__index = ScanContext

---@param init ScanOptions
---@return ScanContext
---@nodiscard
function ScanContext.new(init)
	local obj = setmetatable(init, ScanContext)
	---@cast obj ScanContext
	obj.marked_entities = {}
	return obj
end

---@param param LuaSurface.find_entities_filtered_param
---@return LuaEntity[]
function ScanContext:find_entities(param)
	param.area = self.area
	param.to_be_deconstructed = false
	return self.surface.find_entities_filtered(param)
end

---Get assembling machines, rocket silos, and furnaces
---@return LuaEntity[]
function ScanContext:get_crafting_machines()
	self.crafting_machines = self.crafting_machines or
		self:find_entities { type = { "assembling-machine", "rocket-silo", "furnace" } }
	return self.crafting_machines
end

---@class MarkIcon
---@field type "item"|"fluid"|"virtual"|"entity"
---@field name string

---@param entity LuaEntity
---@param text string
---@param icon MarkIcon?
function ScanContext:mark_entity(entity, text, icon)
	local times_marked = self.marked_entities[entity.unit_number] or 0
	self.marked_entities[entity.unit_number] = times_marked + 1

	if times_marked == 0 then
		local prototype = futils.get_prototype(entity)
		table.insert(global.render_objs[self.player.index], rendering.draw_rectangle {
			surface = entity.surface,
			left_top = entity,
			left_top_offset = prototype.selection_box.left_top,
			right_bottom = entity,
			right_bottom_offset = prototype.selection_box.right_bottom,
			players = self.enable_force_visibility and nil or { self.player },
			forces = self.enable_force_visibility and { self.player.force } or nil,

			color = { .90, .30, .03, .4 },
			filled = false,
			width = 5,
		})
	end
	table.insert(global.render_objs[self.player.index], rendering.draw_text {
		surface = entity.surface,
		target = entity,
		target_offset = { 0, math.floor((times_marked + 1) / 2) * (times_marked % 2 * 2 - 1) * 1 },
		alignment = "center",
		vertical_alignment = "middle",
		orientation = .1,
		players = not self.enable_force_visibility and { self.player } or nil,
		forces = self.enable_force_visibility and { self.player.force } or nil,

		text = text,
		scale = 1.2,
		scale_with_zoom = true,
		color = { 0, 1, 1 },
	})
	if self.enable_map_markers then
		---@type SignalID?
		local signal
		local icon_text = ""

		if icon then
			if icon.type == "entity" then
				local entity_items = game.get_filtered_item_prototypes { {
					filter = "place-result",
					elem_filters = { { filter = "name", name = icon.name } },
				} }
				if #entity_items ~= 0 then
					for _, item in pairs(entity_items) do
						if not signal or item.has_flag("primary-place-result") then
							signal = {
								type = "item",
								name = item.name,
							}
						end
					end
				else
					icon_text = ("[img=entity.%s] "):format(icon.name)
				end
			else
				signal = {
					type = icon.type,
					name = icon.name,
				}
			end
		end
		table.insert(global.chart_tags[self.player.index], self.player.force.add_chart_tag(entity.surface, {
			position = entity.position,
			last_user = self.player,
			text = ("%s[color=red]%s[/color]"):format(icon_text, text), -- Unfortunately, chart tags do not accept LocalisedStrings
			icon = signal,
		}))
	end
end

---@param message LocalisedString
function ScanContext:print(message)
	if not self.printed_separator then
		self.printed_separator = true
		self.player.print ""
	end
	self.player.print(message)
end

return ScanContext
