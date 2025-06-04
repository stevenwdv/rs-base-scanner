local scan_base_item = "rsbs-scan-base"

---@type data.SelectionToolPrototype
local selection_tool = {
	type = "selection-tool",
	name = scan_base_item,
	order = "o[scan-base]",

	select = {
		mode = "nothing",
		cursor_box_type = "entity",
		border_color = { .8, 0, 1 },
	},

	alt_select = {
		mode = "nothing",
		cursor_box_type = "entity",
		border_color = { .8, 0, .5 },
	},

	-- Transparent
	reverse_select = {
		mode = "nothing",
		cursor_box_type = "entity",
		border_color = { 0, 0, 0, 0 },
	},
	alt_reverse_select = {
		mode = "nothing",
		cursor_box_type = "entity",
		border_color = { 0, 0, 0, 0 },
	},

	always_include_tiles = true,

	subgroup = "tool",
	flags = { "only-in-cursor", "not-stackable", "spawnable" },
	hidden = true,
	draw_label_for_cursor_render = true,
	stack_size = 1,

	icon = "__rs-base-scanner__/graphics/scan-base-tool.png",
	icon_size = 64,
	small_icon = "__rs-base-scanner__/graphics/scan-base-tool.png",
	small_icon_size = 64,
}

---@type data.ShortcutPrototype
local shortcut = {
	type = "shortcut",
	name = scan_base_item,
	order = "o[scan-base]",

	action = "spawn-item",
	item_to_spawn = scan_base_item,
	associated_control_input = scan_base_item,

	icon = "__rs-base-scanner__/graphics/scan-base-tool.png",
	icon_size = 64,
	small_icon = "__rs-base-scanner__/graphics/scan-base-tool.png",
	small_icon_size = 64,
}

---@type data.CustomInputPrototype
local custom_input = {
	type = "custom-input",
	name = scan_base_item,

	key_sequence = "CONTROL + S",
	alternative_key_sequence = "CONTROL + SHIFT + S",
	action = "spawn-item",
	item_to_spawn = scan_base_item,
}

data:extend { selection_tool, shortcut, custom_input }
