require "common"
local scan_backwards_belts = require "scanners/backwards_belts"
local scan_belt_capacity = require "scanners/belt_capacity"
local scan_missing_beacon_modules = require "scanners/missing_beacon_modules"
local scan_missing_productivity = require "scanners/missing_productivity"
local scan_stray_loader_items = require "scanners/stray_loader_items"
local scan_tick_crafting_limit = require "scanners/tick_crafting_limit"

local scan_base_item = "rsbs-scan-base"

---Initialize state variables for this player
---@param player LuaPlayer
local function init_globals(player)
	---@type table<uint,uint64[]>
	global.render_objs = global.render_objs or {}
	---@type table<uint,LuaCustomChartTag[]>
	global.chart_tags = global.chart_tags or {}
	---@type table<uint,boolean>
	global.explained_clear_objects = global.explained_clear_objects or {}
	---@type table<uint,boolean>
	global.explained_visibility = global.explained_visibility or {}

	global.render_objs[player.index] = global.render_objs[player.index] or {}
	global.chart_tags[player.index] = global.chart_tags[player.index] or {}
end

---@param player LuaPlayer
local function clear_objects(player)
	for _, obj in pairs(global.render_objs[player.index]) do
		rendering.destroy(obj)
	end
	for _, tag in pairs(global.chart_tags[player.index]) do
		if tag.valid then
			tag.destroy()
		end
	end
	global.render_objs[player.index] = {}
	global.chart_tags[player.index] = {}
end

script.on_event(defines.events.on_player_cursor_stack_changed,
	---@param event on_player_cursor_stack_changed
	function(event)
		local player = game.get_player(event.player_index)
		if not player.cursor_stack.valid_for_read or player.cursor_stack.name ~= scan_base_item then
			return
		end

		-- Clear markers when player clicks selection tool
		init_globals(player)
		clear_objects(player)
	end)

---@param event on_player_selected_area|on_player_alt_selected_area
local function handle_select_event(event)
	if event.item ~= scan_base_item then
		return
	end

	local player = game.get_player(event.player_index)
	init_globals(player)
	clear_objects(player)

	local is_alt = event.name == defines.events.on_player_alt_selected_area
	EnableMapMarkers = is_alt
	EnableForceVisibility = is_alt

	local found_issues
	found_issues = player.mod_settings["rsbs-scan-missing-productivity"].value and
		scan_missing_productivity(player, event.surface, event.area) or found_issues
	found_issues = player.mod_settings["rsbs-scan-missing-beacon-modules"].value and
		scan_missing_beacon_modules(player, event.surface, event.area) or found_issues
	found_issues = player.mod_settings["rsbs-scan-tick-crafting-limit"].value and
		scan_tick_crafting_limit(player, event.surface, event.area) or found_issues
	found_issues = player.mod_settings["rsbs-scan-backwards-belts"].value and
		scan_backwards_belts(player, event.surface, event.area) or found_issues
	found_issues = player.mod_settings["rsbs-scan-belt-capacity"].value and
		scan_belt_capacity(player, event.surface, event.area, {
			splitters_only = player.mod_settings["rsbs-belt-capacity-splitters-only"].value,
			single_only = player.mod_settings["rsbs-belt-capacity-single-only"].value,
			strict_splitters = player.mod_settings["rsbs-belt-capacity-strict-splitters"].value,
		}) or found_issues
	found_issues = player.mod_settings["rsbs-scan-stray-loader-items"].value and
		scan_stray_loader_items(player, event.surface, event.area) or found_issues

	Marked = {}
	Assemblers = nil

	if found_issues then
		if not global.explained_clear_objects[player.index] then
			player.print { "rsbs-message.clear-objects-info" }
			global.explained_clear_objects[player.index] = true
		end
		if not EnableMapMarkers and not global.explained_visibility[player.index] then
			player.print { "rsbs-message.visibility-info" }
			global.explained_visibility[player.index] = true
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
	script.on_event(defines.events.on_tick, function() end)
end
