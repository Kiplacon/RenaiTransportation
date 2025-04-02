function RampPictureSets(FilePath)
	return
	{
		structure =
		{
			layers =
			{
				{
					filename = FilePath,
					size = 128,
					frame_count = 1,
					direction_count = 4,
					line_length = 4,
				}
			}
		},
		signal_color_to_structure_frame_index =
		{
			green  = 0,
			yellow = 1,
			red    = 2,
		},
		lights =
		{
			green  = { light = {intensity = 0, size = 0, color={r=0, g=1,   b=0 }}, shift = { 0, -0.5 }},
			yellow = { light = {intensity = 0, size = 0, color={r=1, g=0.5, b=0 }}, shift = { 0,  0   }},
			red    = { light = {intensity = 0, size = 0, color={r=1, g=0,   b=0 }}, shift = { 0,  0.5 }},
		},
		structure_align_to_animation_index =
		{
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
		}
	}
end
function makeRampPlacerEntity(name, icon, pictureFileName, placerItem, hidden)
	local PictureSet =
	{
		structure =
		{
			layers =
			{
				{
					filename = pictureFileName,
					width = 200,
					height = 200,
					frame_count = 1,
					direction_count = 4,
				}
			}
		},
		signal_color_to_structure_frame_index =
		{
			green  = 0,
			yellow = 1,
			red    = 2,
		},
		lights =
		{
			green  = { light = {intensity = 0, size = 4, color={r=0, g=1,   b=0 }}, shift = { 0, -0.5 }},
			yellow = { light = {intensity = 0, size = 4, color={r=1, g=0.5, b=0 }}, shift = { 0,  0   }},
			red    = { light = {intensity = 0, size = 4, color={r=1, g=0,   b=0 }}, shift = { 0,  0.5 }},
		},
		structure_align_to_animation_index =
		{
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			0,  0,  0,  0,   0,  0,  0,  0,   0,  0,  0,  0,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			1,  1,  1,  1,   1,  1,  1,  1,   1,  1,  1,  1,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			2,  2,  2,  2,   2,  2,  2,  2,   2,  2,  2,  2,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
			3,  3,  3,  3,   3,  3,  3,  3,   3,  3,  3,  3,
		}
	}
	return {
		type = "rail-signal",
		name = name,
		icon = icon,
		icon_size = 64,
		flags = {"filter-directions", "not-on-map", "player-creation"},
		hidden = hidden,
		minable = { mining_time = 0.5, result = placerItem },-- Minable so they can get the item back if the placer swap bugs out
		render_layer = "elevated-object",
		collision_mask = {layers={["train"]=true}}, -- these masks interact with the blocker
		elevated_collision_mask = {layers={["elevated_train"]=true}},
		selection_priority = 100,
		elevated_selection_priority = 100,
		--collision_box = {{-0.01, -2.35}, {2.25, 1.30}},
		--selection_box = {{-0.01, -2.35}, {2.25, 1.30}},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		ground_picture_set = PictureSet,
		elevated_picture_set = PictureSet
	}
end
function CreateRampSprites(name, FilePath)
	data:extend({
		{ -- up
			type = "sprite",
			name = name..8,
			filename = FilePath,
			size = 128,
			x = 128*2
		},
		{ -- right
			type = "sprite",
			name = name..12,
			filename = FilePath,
			size = 128,
			x = 128*3
		},
		{ -- down
			type = "sprite",
			name = name..0,
			filename = FilePath,
			size = 128,
			x = 0
		},
		{ -- left
			type = "sprite",
			name = name..4,
			filename = FilePath,
			size = 128,
			x = 128
		},
	})
end

-- placeholder stuff for 2.0 -> 2.1 migration
for _, placeholder in pairs({"Up", "Down", "Left", "Right"}) do
	for _, varient in pairs({"", "NoSkip"}) do
		data:extend({
			{
				type = "simple-entity-with-owner",
				name = "RTTrainRamp-Elevated"..placeholder..varient,
				flags = {"not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-selectable-in-game"},
				hidden = true,
				max_health = 420,
				picture =
				{
					filename = "__RenaiTransportation__/graphics/Untitled.png",
					size = 32,
					priority = "very-low",
				}
			}
		})
	end
end

-- collision boxes for the ramps/impact unloader
for name, mask in pairs({
	RTTrainRampCollisionBox={layers={["train"]=true}},
	RTElevatedTrainRampCollisionBox={layers={["elevated_train"]=true}},
	RTRailSignalBlocker={layers={["RTRampsAndPlacers"]=true}}
}) do
	data:extend({
		{
			type = "simple-entity-with-owner",
			name = name,
			flags = {"not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "not-selectable-in-game", "building-direction-16-way"},
			hidden = true,
			max_health = 420,
			collision_box = {{-1.32, -1.9}, {1.32, 1.9}},
			collision_mask = mask,
			resistances = {
				{
					type = "impact",
					percent = 100
				},
				{
					type = "fire",
					percent = 100
				},
				{
					type = "explosion",
					percent = 100
				},
				{
					type = "physical",
					percent = 100
				},
				{
					type = "poison",
					percent = 100
				},
				{
					type = "acid",
					percent = 100
				}
			},
			picture = {
				filename = "__RenaiTransportation__/graphics/nothing.png",
				size = 1,
				priority = "very-low",
			}
		},
	})
end