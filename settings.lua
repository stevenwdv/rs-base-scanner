---@class PlayerSettings : {[string]:nil}
---@field rsbs-print-location-min-dimension {value:int}
---@field rsbs-print-location-max-count {value:int}
---@field rsbs-scan-missing-productivity {value:"disable"|"empty-slots"|"non-productivity-slots"|"not-best-available"|"not-minimal-tier"}
---@field rsbs-scan-missing-productivity-tier {value:int}
---@field rsbs-scan-missing-beacon-modules {value:boolean}
---@field rsbs-scan-lone-beacons {value:boolean}
---@field rsbs-scan-missing-recipes {value:boolean}
---@field rsbs-scan-missing-fluids {value:boolean}
---@field rsbs-scan-no-power {value:boolean}
---@field rsbs-scan-low-power {value:boolean}
---@field rsbs-scan-tick-crafting-limit {value:boolean}
---@field rsbs-scan-backwards-belts {value:boolean}
---@field rsbs-scan-orphan-belts {value:boolean}
---@field rsbs-scan-orphan-belts-only-possible-neighbor {value:boolean}
---@field rsbs-scan-orphans-neighbor-search-distance {value:int}
---@field rsbs-scan-belt-capacity {value:boolean}
---@field rsbs-belt-capacity-splitters-only {value:boolean}
---@field rsbs-belt-capacity-single-only {value:boolean}
---@field rsbs-belt-capacity-strict-splitters {value:boolean}
---@field rsbs-scan-stray-loader-items {value:boolean}
---@field rsbs-scan-damaged-items {value:boolean}
---@field rsbs-scan-orphan-pipes {value:boolean}
---@field rsbs-scan-orphan-pipes-only-possible-neighbor {value:boolean}
---@field rsbs-scan-orphan-rail-signals {value:boolean}
---@field rsbs-scan-logistic-chest-capacity {value:boolean}
---@field rsbs-scan-logistic-chest-capacity-multiple-requests-only {value:boolean}
---@field rsbs-scan-unfiltered-chests {value:boolean}
---@field rsbs-scan-outside-construction-area {value:boolean}

--- a, b, ... z, za, zb, ...
---@param order string
---@return string
local function next_order(order)
	last_char = order:sub(#order)
	if last_char == "z" then
		return order .. "a"
	else
		return order:sub(1, #order - 1) .. string.char(last_char:byte() + 1)
	end
end

---@param otherdata data.AnyPrototype[]
local function extend_ordered(otherdata)
	order = "a"
	for _, proto in ipairs(otherdata) do
		proto.order = proto.order or order
		order = next_order(order)
	end
	data:extend(otherdata)
end

extend_ordered {
	{
		type = "int-setting",
		name = "rsbs-print-location-min-dimension",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		default_value = 32 * 7,
	},
	{
		type = "int-setting",
		name = "rsbs-print-location-max-count",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		default_value = 4,
	},

	{
		type = "string-setting",
		name = "rsbs-scan-missing-productivity",
		setting_type = "runtime-per-user",
		allowed_values = {
			"disable",
			"empty-slots",
			"non-productivity-slots",
			"not-best-available",
			"not-minimal-tier",
		},
		default_value = "non-productivity-slots",
	},
	{
		type = "int-setting",
		name = "rsbs-scan-missing-productivity-tier",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 1,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-beacon-modules",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-lone-beacons",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-recipes",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-fluids",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-no-power",
		setting_type = "runtime-per-user",
		default_value = false,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-low-power",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-tick-crafting-limit",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-backwards-belts",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-belts",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-belts-only-possible-neighbor",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "int-setting",
		name = "rsbs-scan-orphans-neighbor-search-distance",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 10,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-belt-capacity",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-splitters-only",
		setting_type = "runtime-per-user",
		default_value = false,
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-single-only",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-strict-splitters",
		setting_type = "runtime-per-user",
		default_value = false,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-stray-loader-items",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-damaged-items",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-pipes",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-pipes-only-possible-neighbor",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-rail-signals",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-logistic-chest-capacity",
		setting_type = "runtime-per-user",
		default_value = true,
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-logistic-chest-capacity-multiple-requests-only",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-unfiltered-chests",
		setting_type = "runtime-per-user",
		default_value = true,
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-outside-construction-area",
		setting_type = "runtime-per-user",
		default_value = true,
	},
}
