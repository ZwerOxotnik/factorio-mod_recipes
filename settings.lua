data:extend({
	{
		type = "double-setting",
		name = "mod_recipes_speed_multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.0001,
		maximum_value = 100
	}, {
		type = "int-setting",
		name = "mod_recipes_multiplier",
		setting_type = "startup",
		default_value = 40,
		minimum_value = 1,
		maximum_value = 1000000
	}
})
