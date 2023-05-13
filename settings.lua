data:extend {
	{
		type = "int-setting",
		name = "rsbs-print-location-min-dimension",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		default_value = 32 * 7,
		order = "0-a",
	},
	{
		type = "int-setting",
		name = "rsbs-print-location-max-count",
		setting_type = "runtime-per-user",
		minimum_value = 0,
		default_value = 4,
		order = "0-b",
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
		order = "a",
	},
	{
		type = "int-setting",
		name = "rsbs-scan-missing-productivity-tier",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 1,
		order = "a-a",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-beacon-modules",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "b",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-recipes",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "c",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-missing-fluids",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "d",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-tick-crafting-limit",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "e",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-backwards-belts",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "f",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-belts",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "g",
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-belts-only-possible-neighbor",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "g-a",
	},
	{
		type = "int-setting",
		name = "rsbs-scan-orphans-neighbor-search-distance",
		setting_type = "runtime-per-user",
		minimum_value = 1,
		default_value = 10,
		order = "g-b",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-belt-capacity",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "h",
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-splitters-only",
		setting_type = "runtime-per-user",
		default_value = false,
		order = "h-a",
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-single-only",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "h-b",
	},
	{
		type = "bool-setting",
		name = "rsbs-belt-capacity-strict-splitters",
		setting_type = "runtime-per-user",
		default_value = false,
		order = "h-c",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-stray-loader-items",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "i",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-pipes",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "j",
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-pipes-only-possible-neighbor",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "j-a",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-orphan-rail-signals",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "k",
	},

	{
		type = "bool-setting",
		name = "rsbs-scan-logistic-chest-capacity",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "l",
	},
	{
		type = "bool-setting",
		name = "rsbs-scan-logistic-chest-capacity-multiple-requests-only",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "l-a",
	},
}
