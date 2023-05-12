local ScanContext = require "scan_context"
local scan_backwards_belts = require "scanners.backwards_belts"
local scan_belt_capacity = require "scanners.belt_capacity"
local scan_logistic_chest_capacity = require "scanners.logistic_chest_capacity"
local scan_missing_beacon_modules = require "scanners.missing_beacon_modules"
local scan_missing_fluids = require "scanners.missing_fluids"
local scan_missing_productivity = require "scanners.missing_productivity"
local scan_missing_recipes = require "scanners.missing_recipes"
local scan_orphan_belts = require "scanners.orphan_belts"
local scan_orphan_pipes = require "scanners.orphan_pipes"
local scan_orphan_rail_signals = require "scanners.orphan_rail_signals"
local scan_stray_loader_items = require "scanners.stray_loader_items"
local scan_tick_crafting_limit = require "scanners.tick_crafting_limit"

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
	---@param event EventData.on_player_cursor_stack_changed
	function(event)
		local player = game.get_player(event.player_index)
		---@cast player -nil
		if not player.cursor_stack.valid_for_read or player.cursor_stack.name ~= scan_base_item then
			return
		end

		-- Clear markers when player clicks selection tool
		init_globals(player)
		clear_objects(player)
	end)

---@param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function handle_select_event(event)
	if event.item ~= scan_base_item then
		return
	end

	local player = game.get_player(event.player_index)
	---@cast player -nil
	init_globals(player)
	clear_objects(player)

	local is_alt = event.name == defines.events.on_player_alt_selected_area
	local ctx = ScanContext.new {
		player = player,
		surface = event.surface,
		area = event.area,
		enable_map_markers = is_alt,
		enable_force_visibility = is_alt,
	}

	local found_issues = false
	local settings = player.mod_settings
	local scan_missing_productivity_setting = settings["rsbs-scan-missing-productivity"].value
	found_issues = scan_missing_productivity_setting ~= "disable" and
		scan_missing_productivity(ctx, {
			mode = scan_missing_productivity_setting,
			minimal_tier = settings["rsbs-scan-missing-productivity-tier"].value,
		}) or found_issues
	found_issues = settings["rsbs-scan-missing-beacon-modules"].value and
		scan_missing_beacon_modules(ctx) or found_issues
	found_issues = settings["rsbs-scan-missing-recipes"].value and
		scan_missing_recipes(ctx) or found_issues
	found_issues = settings["rsbs-scan-missing-fluids"].value and
		scan_missing_fluids(ctx) or found_issues
	found_issues = settings["rsbs-scan-tick-crafting-limit"].value and
		scan_tick_crafting_limit(ctx) or found_issues
	found_issues = settings["rsbs-scan-backwards-belts"].value and
		scan_backwards_belts(ctx) or found_issues
	found_issues = settings["rsbs-scan-orphan-belts"].value and
		scan_orphan_belts(ctx, {
			only_possible_neighbor = settings["rsbs-scan-orphan-belts-only-possible-neighbor"].value,
			extra_search_distance = settings["rsbs-scan-orphans-neighbor-search-distance"].value,
		}) or found_issues
	found_issues = settings["rsbs-scan-belt-capacity"].value and
		scan_belt_capacity(ctx, {
			splitters_only = settings["rsbs-belt-capacity-splitters-only"].value,
			single_only = settings["rsbs-belt-capacity-single-only"].value,
			strict_splitters = settings["rsbs-belt-capacity-strict-splitters"].value,
		}) or found_issues
	found_issues = settings["rsbs-scan-stray-loader-items"].value and
		scan_stray_loader_items(ctx) or found_issues
	found_issues = settings["rsbs-scan-orphan-pipes"].value and
		scan_orphan_pipes(ctx, {
			only_possible_neighbor = settings["rsbs-scan-orphan-pipes-only-possible-neighbor"].value,
			extra_search_distance = settings["rsbs-scan-orphans-neighbor-search-distance"].value,
		}) or found_issues
	found_issues = settings["rsbs-scan-orphan-rail-signals"].value and
		scan_orphan_rail_signals(ctx) or found_issues
	found_issues = settings["rsbs-scan-logistic-chest-capacity"].value and
		scan_logistic_chest_capacity(ctx, {
			multiple_requests_only = settings["rsbs-scan-logistic-chest-capacity-multiple-requests-only"].value,
		}) or found_issues

	if found_issues then
		if not global.explained_clear_objects[player.index] then
			player.print { "rsbs-message.clear-objects-info" }
			global.explained_clear_objects[player.index] = true
		end
		if not ctx.enable_map_markers and not global.explained_visibility[player.index] then
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
	script.on_event(defines.events.on_tick, function()
	end)
end
