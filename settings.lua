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
	name = "RTThrowersDynamicRange",
	setting_type = "startup",
	default_value = false,
	order = "ab"
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
	type = "int-setting",
	name = "RTMagRampRange",
	setting_type = "runtime-global",
	default_value = 100,
	order = "da"
},
{
	type = "bool-setting",
	name = "RTTrainBounceSetting",
	setting_type = "startup",
	default_value = true,
	order = "ea"
},
{
	type = "bool-setting",
	name = "RTImpactSetting",
	setting_type = "startup",
	default_value = true,
	order = "eb"
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
	default_value = true,
	order = "aa"
},
{
	type = "string-setting",
	name = "RTSpillSetting",
	setting_type = "runtime-global",
	default_value = "Spill",
    allowed_values = {"Spill", "Spill and Mark", "Destroy"},
	order = "ab"
},
{
	type = "bool-setting",
	name = "RTShowRange",
	setting_type = "runtime-global",
	default_value = true,
	order = "ac"
},
{
	type = "int-setting",
	name = "RTImpactGrouping",
	setting_type = "runtime-global",
	default_value = 1000,
	minimum_value = 200, -- minimum fun
	order = "i"
}
})
