local scan_base_item = "rsbs-scan-base"

data:extend {
	{
		type = "selection-tool",
		name = scan_base_item,
		order = "o[scan-base]",

		selection_mode = "nothing",
		selection_cursor_box_type = "entity",
		selection_color = { .8, 0, 1 },

		alt_selection_mode = "nothing",
		alt_selection_cursor_box_type = "entity",
		alt_selection_color = { .8, 0, .5 },
		always_include_tiles = true,

		reverse_selection_color = { 0, 0, 0, 0 },
		alt_reverse_selection_color = { 0, 0, 0, 0 },

		subgroup = "tool",
		flags = { "only-in-cursor", "hidden", "not-stackable", "spawnable" },
		draw_label_for_cursor_render = true,
		stack_size = 1,
		icon = "__rs-base-scanner__/graphics/scan-base-tool.png",
		icon_size = 64,
	},

	{
		type = "shortcut",
		name = scan_base_item,
		order = "o[scan-base]",

		action = "spawn-item",
		item_to_spawn = scan_base_item,
		associated_control_input = scan_base_item,
		icon = {
			filename = "__rs-base-scanner__/graphics/scan-base-tool.png",
			priority = "extra-high-no-scale",
			size = 64,
			scale = 1,
			flags = { "icon" },
		},
	},
	{
		type = "custom-input",
		name = scan_base_item,

		key_sequence = "CONTROL + S",
		alternative_key_sequence = "CONTROL + SHIFT + S",
		action = "spawn-item",
		item_to_spawn = scan_base_item,
	}
}
