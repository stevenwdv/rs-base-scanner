local futils = require "factorio_utils"
local player_data = futils.player_data
local ScanContext = require "ScanContext"
local scanners = {
	require "scanners.missing_productivity",
	require "scanners.missing_beacon_modules",
	require "scanners.lone_beacons",
	require "scanners.missing_recipes",
	require "scanners.missing_fluids",
	require "scanners.no_power",
	require "scanners.low_power",
	require "scanners.tick_crafting_limit",
	require "scanners.backwards_belts",
	require "scanners.orphan_belts",
	require "scanners.belt_capacity",
	require "scanners.stray_loader_items",
	require "scanners.orphan_pipes",
	require "scanners.orphan_rail_signals",
	require "scanners.logistic_chest_capacity",
}

local scan_base_item = "rsbs-scan-base"

script.on_configuration_changed(function (change)
	if change.mod_changes[script.mod_name] then
		if global.render_objs then
			---@param prop string Property name (on `global`)
			function migrate(prop)
				---@type table<uint,any> Indexed by player ID
				tbl = global[prop] or {}
				for player_index, val in pairs(tbl) do
					if game.players[player_index] then
						player_data.set(player_index, prop, val)
					end
				end
			end
			migrate("render_objs")
			migrate("chart_tags")
			migrate("explained_clear_objects")
			migrate("explained_visibility")
		end
	end
end)

---@param player LuaPlayer
local function clear_objects(player)
	for _, obj in pairs(player_data.get(player.index, "render_objs", {})) do
		rendering.destroy(obj)
	end
	for _, tag in pairs(player_data.get(player.index, "chart_tags", {})) do
		if tag.valid then
			tag.destroy()
		end
	end
end

script.on_event(defines.events.on_player_removed, function (event)
	clear_objects(game.players[event.player_index])
	player_data.purge(event.player_index)
end)

script.on_event(defines.events.on_player_cursor_stack_changed,
	---@param event EventData.on_player_cursor_stack_changed
	function(event)
		local player = game.players[event.player_index]
		if not player.cursor_stack.valid_for_read or player.cursor_stack.name ~= scan_base_item then
			return
		end

		-- Clear markers when player clicks selection tool
		clear_objects(player)
	end)

---@param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function handle_select_event(event)
	if event.item ~= scan_base_item then
		return
	end

	local player = game.players[event.player_index]
	clear_objects(player)

	local settings = player.mod_settings --[[@as PlayerSettings]]

	local is_alt = event.name == defines.events.on_player_alt_selected_area
	local ctx = ScanContext.new {
		player = player,
		surface = event.surface,
		area = event.area,
		enable_map_markers = is_alt,
		enable_force_visibility = is_alt,
		print_location_min_dimension = settings["rsbs-print-location-min-dimension"].value,
		print_location_max_count = settings["rsbs-print-location-max-count"].value,
	}

	local found_issues = false
	for _, scanner in ipairs(scanners) do
		found_issues = scanner(settings, ctx) or found_issues
	end

	if found_issues then
		if not player_data.set(player.index, "explained_clear_objects", true) then
			player.print { "rsbs-message.clear-objects-info" }
		end
		if not ctx.enable_map_markers and not player_data.set(player.index, "explained_visibility", true) then
			player.print { "rsbs-message.visibility-info" }
		end
	else
		player.print { "rsbs-message.no-issues" }
	end
	player.clear_cursor()
end

script.on_event({ defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area },
	handle_select_event)

if __Profiler then
	-- justarandomgeek/vscode-factoriomod-debug#60
	script.on_event(defines.events.on_tick, function()
	end)
end
