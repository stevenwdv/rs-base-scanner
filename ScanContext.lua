local futils = require "factorio_utils"
local player_data = futils.player_data
local lualib_math2d = require "__core__.lualib.math2d"

---@class ScanOptions
---@field player LuaPlayer
---@field surface LuaSurface
---@field area BoundingBox
---@field enable_map_markers boolean
---@field enable_force_visibility boolean Enable visibility of drawn markings for the whole force
---@field print_location_min_dimension integer
---@field print_location_max_count integer

---@class ScanContext : ScanOptions
local ScanContext = {
	---@type LuaSurface
	surface = nil,
	---@type BoundingBox
	area = nil,

	enable_map_markers = false,
	enable_force_visibility = false,

	print_location_min_dimension = 0,
	print_location_max_count = math.huge,

	---@protected
	---@type table<ChunkID,LuaEntity> Maps large chunks to an entity with issues in that chunk, for the current scan type
	issue_chunks = nil,

	---@protected
	nr_issue_chunks = 0,

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
	obj.marked_entities = {}
	obj.issue_chunks = {}
	---@cast obj ScanContext
	return obj
end

---@param param EntitySearchFilters
---@return LuaEntity[]
function ScanContext:find_entities(param)
	if param.area == nil then
		param.area = self.area
	end
	if param.to_be_deconstructed == nil then
		param.to_be_deconstructed = false
	end
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
		if self.nr_issue_chunks < self.print_location_max_count
			and (self.area.right_bottom.x - self.area.left_top.x > self.print_location_min_dimension
				or self.area.right_bottom.y - self.area.left_top.y > self.print_location_min_dimension)
		then
			local pos = entity.position
			local large_chunk_size = self.print_location_min_dimension
			local large_chunk_x, large_chunk_y =
				math.floor(pos.x / large_chunk_size),
				math.floor(pos.y / large_chunk_size)
			local large_chunk_id = futils.get_chunk_id(large_chunk_x, large_chunk_y)
			if not self.issue_chunks[large_chunk_id] then
				self.issue_chunks[large_chunk_id] = entity
				self.nr_issue_chunks = self.nr_issue_chunks + 1
			end
		end

		table.insert(player_data.get(self.player.index, "render_objs", {}, true),
			rendering.draw_rectangle {
				surface = entity.surface,
				left_top = {
					entity = entity,
					offset = lualib_math2d.position.subtract(entity.selection_box.left_top, entity.position),
				},
				right_bottom = {
					entity = entity,
					offset = lualib_math2d.position.subtract(entity.selection_box.right_bottom, entity.position),
				},
				players = not self.enable_force_visibility and { self.player } or nil,
				forces = self.enable_force_visibility and { self.player.force } or nil,

				color = { .90, .30, .03, .4 },
				filled = false,
				width = 5,
			})
	end
	table.insert(player_data.get(self.player.index, "render_objs", {}, true),
		rendering.draw_text {
			surface = entity.surface,
			target = {
				entity = entity,
				offset = { 0, math.floor((times_marked + 1) / 2) * (times_marked % 2 * 2 - 1) * 1 },
			},
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
				local entity_items = prototypes.get_item_filtered { {
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
		table.insert(player_data.get(self.player.index, "chart_tags", {}, true),
			self.player.force.add_chart_tag(entity.surface, {
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

---@param message LocalisedString
function ScanContext:print_summary(message)
	if self.nr_issue_chunks > 0 then
		message = { "", message }
		table.insert(message, self.nr_issue_chunks > 1 and ", e.g. " or " ")
		for _, entity in pairs(self.issue_chunks) do
			local pos = entity.position
			local surface = entity.surface
			table.insert(message,
				surface.index == 1 and ("[gps=%s,%s]"):format(pos.x, pos.y)
				or ("[gps=%s,%s,%s]"):format(pos.x, pos.y, entity.surface.name))
		end
		self.issue_chunks = {}
		self.nr_issue_chunks = 0
	end
	self:print(message)
end

return ScanContext
