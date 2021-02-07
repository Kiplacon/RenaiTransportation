data:extend({
{
	type = "bool-setting",
	name = "RTThrowersSetting",
	setting_type = "startup",
	default_value = true,
	order = "a"
},
{
	type = "bool-setting",
	name = "RTModdedThrowers",
	setting_type = "startup",
	default_value = true,
	order = "b"
},
{
	type = "bool-setting",
	name = "RTBounceSetting",
	setting_type = "startup",
	default_value = true,
	order = "c"
},
{
	type = "bool-setting",
	name = "RTTrainRampSetting",
	setting_type = "startup",
	default_value = true,
	order = "d"
},
{
	type = "bool-setting",
	name = "RTTrainBounceSetting",
	setting_type = "startup",
	default_value = true,
	order = "e"
},
{
	type = "bool-setting",
	name = "RTZiplineSetting",
	setting_type = "startup",
	default_value = true,
	order = "f"
},
{
	type = "string-setting",
	name = "RTZiplineSmoothSetting",
	setting_type = "runtime-per-user",
	default_value = "Bobbing Motion",
    allowed_values = {"Bobbing Motion", "Level Motion"},
	order = "g"
},
{
	type = "bool-setting",
	name = "RTOverflowComp",
	setting_type = "runtime-global",
	default_value = false,
	order = "h"
}
})