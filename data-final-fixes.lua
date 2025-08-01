function MakeProjectile(ThingData, speed)
	if (ThingData.icon_size == nil) then
		ThingData.icon_size = 64
	end
	local TheProjectile =
		{
			type = "stream",
			name = "RTItemProjectile-"..ThingData.name..(speed*100 or 18),
			flags = {"not-on-map"},
			hidden = true,
			particle_spawn_interval = 0,
			particle_spawn_timeout = 0,
			particle_vertical_acceleration = 0.0035,
			particle_horizontal_speed = speed or 0.18,
			particle_horizontal_speed_deviation = 0,
			particle =
				{
					layers =
					{
						{
							filename = "__RenaiTransportation__/graphics/icon.png",
							line_length = 1,
							frame_count = 1,
							priority = "high",
							size = 32,
							scale = 19.2/32
						}
					}
				},
			shadow =
				{
					layers =
					{
						{
							filename = "__RenaiTransportation__/graphics/icon.png",
							line_length = 1,
							frame_count = 1,
							priority = "high",
							size = 32,
							scale = 19.2/32,
							tint = {0,0,0,0.5}
						}
					}
				},
			oriented_particle = true,
			--shadow_scale_enabled = true
		}

	if (ThingData.icons) then
		TheProjectile.particle.layers = {}
		TheProjectile.shadow.layers = {}
		for iconlayer, iconspecs in pairs(ThingData.icons) do
			local eeee = 64
			local rrrr
			--[[ local shiftt = {0,0}
			if (iconspecs.shift) then
				shiftt = {iconspecs.shift[1]/32, iconspecs.shift[2]/32}
			end ]]
			if (iconspecs.icon_size) then
				eeee = iconspecs.icon_size
			end
			if (iconspecs.tint) then
				rrrr = iconspecs.tint
			end

			table.insert(TheProjectile.particle.layers,
				{
					filename = iconspecs.icon,
					line_length = 1,
					frame_count = 1,
					priority = "high",
					scale = (iconspecs.scale or 1) * (19.2/eeee),
					size = eeee,
					tint = rrrr,
					--shift = shiftt
				})
			table.insert(TheProjectile.shadow.layers,
				{
					filename = iconspecs.icon,
					line_length = 1,
					frame_count = 1,
					priority = "high",
					scale = (iconspecs.scale or 1) * (19.2/eeee),
					size = eeee,
					tint = {0,0,0,0.5}
				})
		end

	elseif (ThingData.icon) then
		TheProjectile.particle =
		{
			filename = ThingData.icon,
			line_length = 1,
			width = ThingData.icon_size,
			height = ThingData.icon_size,
			frame_count = 1,
			priority = "high",
			scale = 19.2/ThingData.icon_size --0.3 of a tile
			--animation_speed = 1,
		}
		TheProjectile.shadow =
		{
			filename = ThingData.icon,
			line_length = 1,
			width = ThingData.icon_size,
			height = ThingData.icon_size,
			frame_count = 1,
			--shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
			tint = {0,0,0,0.5},
			priority = "high",
			scale = 19.2/ThingData.icon_size --0.3 of a tile
			--animation_speed = 1,
		}
	else
		TheProjectile.particle =
		{
			filename = "__RenaiTransportation__/graphics/icon.png",
			line_length = 1,
			width = 32,
			height = 32,
			frame_count = 1,
			--shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
			--tint = data.tint,
			priority = "high",
			scale = 19.2/32 --0.3 of a tile
			--animation_speed = 1,
		}
	end
	data:extend({TheProjectile})

end

function MakeItemShellStuff(ThingData)
	for QualityName, quality in pairs(data.raw.quality) do
		data:extend({
			{
				type = "projectile",
				name = "RTItemShell"..ThingData.name.."-Q-"..QualityName,
				hidden = true,
				acceleration = 0,
				direction_only = true,
				collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
				--hit_collision_mask = {layers={object=true, player=true, train=true}},
				piercing_damage = 9999999999,
				--hit_at_collision_position = true,
				height = 1,
				animation =
				{
					layers =
					{
						{
							filename = renaiEntity .. "ItemCannon/EmptyItemShell.png",
							size = 64,
							frame_count = 1,
							priority = "high",
							scale = 0.5
						},
					}
				},
				shadow =
				{
					filename = renaiEntity .. "ItemCannon/EmptyItemShell_shadow.png",
					size = 64,
					frame_count = 1,
					priority = "high",
					draw_as_shadow = true,
					scale = 0.5
				},
				action =
				{
					type = "direct",
					action_delivery =
					{
						type = "instant",
						target_effects =
						{
							{
								type = "damage",
								damage = {amount = 9999999999, type = "impact"}
							}
						}
					}
				},
				final_action =
				{
					type = "direct",
					action_delivery =
					{
						type = "instant",
						target_effects =
						{
							{
								type = "script",
								effect_id = "RTItemShell"..ThingData.name.."-Q-"..QualityName
							},
						}
					}
				},
				smoke =
				{
					{
						name = "smoke-fast",
						frequency = 1,
					}
				},
			}
		})
	end
end

function MakePrimedProjectile(ThingData, ProjectileType)-------------------------------------------
log("--------Creating primed projectile for "..ThingData.type..": "..ThingData.name.."-----------")
TheProjectile = table.deepcopy(data.raw.stream["acid-stream-spitter-small"])
	TheProjectile.name = ThingData.name.."-projectileFromRenaiTransportationPrimed"
	TheProjectile.special_neutral_target_damage = {amount = 0, type = "acid"}
    TheProjectile.particle_spawn_interval = 0
    TheProjectile.particle_spawn_timeout = 0
    TheProjectile.particle_vertical_acceleration = 0.004 -- gravity, default 0.0045
    TheProjectile.particle_horizontal_speed = 0.3 -- speed, default 0.3375
    TheProjectile.particle_horizontal_speed_deviation = 0
	TheProjectile.working_sound = nil
	TheProjectile.lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 *1.5
	-- convert respective action to the primed projectile
	local ProjectileInitialAction = nil
	local ProjectileFinalAction = nil
	if (ThingData.capsule_action) then --capsules with thrown actions: grenades, combat robots, poison, slowdown
		if (ThingData.capsule_action.attack_parameters.ammo_type.action[1]) then
			log(ThingData.type..": "..ThingData.name.." has multiple actions.")
			ProjectileInitialAction = table.deepcopy(data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile].action)
		elseif (ThingData.capsule_action.attack_parameters.ammo_type.action) then
			log(ThingData.type..": "..ThingData.name.." has 1 action.")
			ProjectileInitialAction = table.deepcopy(data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile].action)
		end
	elseif (ThingData.place_result and data.raw["land-mine"][ThingData.place_result]) then  --landmines
		log(ThingData.type..": "..ThingData.name.." places "..ThingData.place_result)
		ProjectileInitialAction =
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
				{
					type = "create-entity",
					entity_name = ThingData.place_result --ThingData.name
				}
				}
			}
		}
	elseif (ProjectileType == "artillery") then -- artillery
		if (ThingData.ammo_type.action[1]) then
			log(ThingData.type..": "..ThingData.name.." has multiple actions.")
			for i, action in pairs(ThingData.ammo_type.action) do
				if (action.action_delivery.projectile) then
					ProjectileInitialAction = table.deepcopy(data.raw["artillery-projectile"][ThingData.ammo_type.action[1].action_delivery.projectile].action)
					ProjectileFinalAction = table.deepcopy(data.raw["artillery-projectile"][ThingData.ammo_type.action[1].action_delivery.projectile].final_action)
				end
			end
		elseif (ThingData.ammo_type.action) then
			log(ThingData.type..": "..ThingData.name.." has 1 action.")
			ProjectileInitialAction = table.deepcopy(data.raw["artillery-projectile"][ThingData.ammo_type.action.action_delivery.projectile].action)
			ProjectileFinalAction = table.deepcopy(data.raw["artillery-projectile"][ThingData.ammo_type.action.action_delivery.projectile].final_action)
		end
	else -- rockets/atomic bombs/other
		if (ThingData.ammo_type.action[1]) then
			log(ThingData.type..": "..ThingData.name.." has multiple actions.")
			for i, action in pairs(ThingData.ammo_type.action) do
				if (action.action_delivery.projectile) then
					ProjectileInitialAction = table.deepcopy(data.raw.projectile[ThingData.ammo_type.action[i].action_delivery.projectile].action)
					ProjectileFinalAction = table.deepcopy(data.raw.projectile[ThingData.ammo_type.action[i].action_delivery.projectile].final_action)
				end
			end
		elseif (ThingData.ammo_type.action) then
			log(ThingData.type..": "..ThingData.name.." has 1 action.")
			ProjectileInitialAction = table.deepcopy(data.raw.projectile[ThingData.ammo_type.action.action_delivery.projectile].action)
			ProjectileFinalAction = table.deepcopy(data.raw.projectile[ThingData.ammo_type.action.action_delivery.projectile].final_action)
		end
	end
	if (ProjectileInitialAction) then
		log("an initial action.")
	end
	if (ProjectileFinalAction) then
		log("a final action.")
	end

	-- build the effect stack
	local combined = {}
	if (ProjectileInitialAction) then
		if (ProjectileInitialAction.type == nil) then -- multiple effects
			log("adding initial actionS to combined list")
			for all, effect in pairs(ProjectileInitialAction) do
				table.insert(combined, effect)
			end
		else --1 effect
			log("adding initial action to combined list")
			table.insert(combined, ProjectileInitialAction)
		end
	end
	if (ProjectileFinalAction) then
		if (ProjectileFinalAction.type == nil) then -- multiple effects
			log("adding final actionS to combined list")
			for all, effect in pairs(ProjectileFinalAction) do
				table.insert(combined, effect)
			end
		else --1 effect
			log("adding final action to combined list")
			table.insert(combined, ProjectileFinalAction)
		end
	end
	-- specific whitelist of single-target projectiles (base rocket/cannon shell) to AOE
	if (ThingData.name == "rocket"
	or ThingData.name == "cannon-shell"
	or ThingData.name == "uranium-cannon-shell") then
		for sbeve, effect in pairs(combined) do
			effect.type = "area"
			effect.radius = 3
		end
	end
	TheProjectile.initial_action = combined

	local RedTint = {255,100,100}
	local ScaleSize = 1.5
	if (ThingData.icon_size == nil) then
		ThingData.icon_size = 64
	end
	if (ThingData.icons) then
		if (ThingData.icon_size) then
			TheProjectile.particle.size = ThingData.icon_size
		else
			TheProjectile.particle.size = ThingData.icons[1].icon_size
		end

		TheProjectile.particle.layers = {}
		for iconlayer, iconspecs in pairs(ThingData.icons) do
			if (iconspecs.icon_size) then
				eeee = iconspecs.icon_size
			else
				eeee = TheProjectile.particle.size
			end

			table.insert(TheProjectile.particle.layers,
				{
					filename = iconspecs.icon,
					line_length = 1,
					frame_count = 1,
					priority = "high",
					scale = (19.2/eeee)*ScaleSize,
					size = eeee,
					tint = RedTint
				})
		end
	else
		TheProjectile.particle =
		{
			filename = ThingData.icon,
			line_length = 1,
			width = ThingData.icon_size,
			height = ThingData.icon_size,
			frame_count = 1,
			tint = RedTint,
			--shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
			priority = "high",
			scale = (19.2/ThingData.icon_size)*ScaleSize --0.3*ScaleSize (0.3 is how big an item is on the ground)
			--animation_speed = 1,
		}
	end
	TheProjectile.spine_animation = nil

	if (TheProjectile.initial_action.type or (TheProjectile.initial_action[1] and TheProjectile.initial_action[1].type and TheProjectile.initial_action[1].action_delivery)) then
		data:extend({
			TheProjectile,
			{
				type = "turret",
				name = "RTPrimerThrowerShooter-"..ThingData.name,
				icon = "__base__/graphics/icons/big-worm.png",
				icon_size = 64,
				flags = {"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-selectable-in-game"},
				hidden = true,
				max_health = 750,
				alert_when_attacking = false,
				resistances =
				{
					{
					type = "physical",
					percent = 100
					},
					{
					type = "explosion",
					percent = 100
					},
					{
					type = "fire",
					percent = 100
					}
				},
				collision_box = nil,
				--selection_box = {{-1.4, -1.2}, {1.4, 1.2}},
				selection_box = nil,
				rotation_speed = 1,
				folded_animation = {direction_count=4, filename = emptypng, size=1},
				graphics_set = {},
				starting_attack_speed = 1,
				ending_attack_speed = 1,
				allow_turning_when_starting_attack = true,
				attack_parameters =
				{
					type = "stream",
					cooldown = 4,
					range = 51,
					min_range = 25,
					turn_range = 0.155,
					lead_target_for_projectile_speed = 0.3, -- this should be the horizontal speed of the thrown thing
					ammo_category = "melee",
					ammo_type =
					{
						category = "biological",
						action =
						{
							type = "direct",
							action_delivery =
							{
							type = "stream",
							stream = ThingData.name.."-projectileFromRenaiTransportationPrimed",
							source_offset = {0.15, -0.5}
							}
						}
					},
				},
				call_for_help_radius = 40,
			}
		})
	else
		log("Failed making "..ThingData.name.."-projectileFromRenaiTransportationPrimed.")
	end
end

---------------------------------------Thrower----------------------------------------------------------------------
function MakeThrowerVariant(ThingData, PlacingItemName)
	log("--------Creating thrower variant for "..ThingData.name.."-----------")
	if (PlacingItemName == nil) then
		if (ThingData.minable.result) then
			PlacingItemName = ThingData.minable.result
		elseif (ThingData.minable.results) then
			for _, result in pairs(ThingData.minable.results) do
				if (result.type == "item") then
					PlacingItemName = result.name
				end
			end
		end
	end

	local TheItem = table.deepcopy(data.raw.item[PlacingItemName])
	TheItem.name = "RTThrower-"..TheItem.name.."-Item"
	TheItem.subgroup = "throwers"
	TheItem.place_result = "RTThrower-"..ThingData.name
	if (TheItem.icon) then
		TheItem.icons =
		{
			{
				icon = TheItem.icon,
				icon_size = TheItem.icon_size
			},

			{
				icon = renaiIcons .. "ThrowerInserteroverlay.png",
				icon_size = 64
			}
		}
	else
		table.insert(TheItem.icons, {icon = renaiIcons .. "ThrowerInserteroverlay.png",	icon_size = 64, icon_mipmaps = 4})
	end

	if (ThingData.name == "inserter" or ThingData.name == "burner-inserter") then
		isitenabled = true
	else
		isitenabled = false
	end
	local TheRecipe =
	{
		type = "recipe",
		name = "RTThrower-"..ThingData.name.."-Recipe",
		enabled = isitenabled,
		energy_required = 1,
		localised_name =  "Thrower "..ThingData.name:gsub("-i"," i"),
		ingredients =
		{
			{type="item", name=PlacingItemName, amount=1},
			{type="item", name="copper-cable", amount=4}
		},
		results = {
			{type="item", name=TheItem.name, amount=1}
		},
		auto_recycle = true
	}

	local TheThrower = table.deepcopy(data.raw.inserter[ThingData.name])
	if (TheThrower.icon) then
		TheThrower.icons =
		{
			{
				icon = TheThrower.icon,
				icon_size = TheThrower.icon_size
			},
			{
				icon = renaiIcons .. "ThrowerInserteroverlay.png",
				icon_size = 64
			}
		}
	else
		table.insert(TheThrower.icons, {icon = renaiIcons .. "ThrowerInserteroverlay.png",	icon_size = 64})
	end
	TheThrower.name = "RTThrower-"..ThingData.name
	TheThrower.minable = {mining_time = 0.1, result = TheItem.name}
	TheThrower.localised_name ="Thrower "..ThingData.name:gsub("-i"," i")
	--TheThrower.localised_name = {"thrower-gen.name", {"entity-name."..ThingData.name}}
	TheThrower.insert_position = {0, 15.2}
	TheThrower.allow_custom_vectors = true
	local ItsRange = 15
	if (TheThrower.fast_replaceable_group ~= nil) then
		TheThrower.fast_replaceable_group = "thrower-"..TheThrower.fast_replaceable_group
	else
		TheThrower.fast_replaceable_group = "ThrowerInserters"
	end
	if (TheThrower.next_upgrade and TheThrower.next_upgrade ~= "") then
		TheThrower.next_upgrade = "RTThrower-"..TheThrower.next_upgrade
	end

	if (TheThrower.energy_per_rotation) then
		local MovementEnergy = util.parse_energy(TheThrower.energy_per_movement) * 3  -- for some reason x2.5 makes the total energy even out
		local RotationEnergy = util.parse_energy(TheThrower.energy_per_rotation)
		TheThrower.energy_per_rotation = (RotationEnergy + MovementEnergy).."J"
		TheThrower.energy_per_movement = "1J" -- this prevents inserters from elongating first and then rotating when energy is low
	end

	if (TheThrower.name == "RTThrower-inserter") then
		TheThrower.extension_speed = 0.027 -- default 0.03, needs to be a but slower so we don't get LongB0is
		TheThrower.rotation_speed = 0.020 -- default 0.014
	elseif (TheThrower.name == "RTThrower-long-handed-inserter") then
		TheThrower.insert_position = {0, 25.2}
		ItsRange = 25
	end

	if settings.startup["RTThrowersDynamicRange"].value == true then
		local original_inserter = data.raw.inserter[ThingData.name]
		ItsRange = math.sqrt(original_inserter.insert_position[1]^2 + original_inserter.insert_position[2]^2)
		local unitX = original_inserter.insert_position[1] / ItsRange
		local unitY = original_inserter.insert_position[2] / ItsRange
		TheThrower.insert_position = 
			{
				unitX*math.floor(ItsRange)*10 + ((original_inserter.insert_position[1] ~= 0) and (unitX*5 + 0.2) or 0),
				unitY*math.floor(ItsRange)*10 + ((original_inserter.insert_position[2] ~= 0) and (unitY*5 + 0.2) or 0)
			}
		--TheThrower.insert_position = {0, ItsRange+0.2}
	end

	local EffectiveRange = math.sqrt(TheThrower.insert_position[1]^2 + TheThrower.insert_position[2]^2)
	if (TheThrower.localised_description) then
		TheThrower.localised_description = {"thrower-gen.HasDesc", tostring(math.floor(EffectiveRange)), TheThrower.localised_description}
	else
		TheThrower.localised_description = {"thrower-gen.DefaultDesc", tostring(math.floor(EffectiveRange))}
	end
	TheThrower.hand_size = 0
	TheThrower.hand_base_picture =
		{
		filename = renaiEntity .. "ThrowerInserter/hr-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
		}
	TheThrower.hand_closed_picture =
		{
		filename = renaiEntity .. "ThrowerInserter/hr-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
		}
	TheThrower.hand_open_picture =
		{
		filename = renaiEntity .. "ThrowerInserter/hr-inserter-hand-open.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
		}

	if mods["Ultracube"] then
		data:extend({TheThrower, TheItem}) -- Recipes and tech will be handled by Ultracube
	else
		data:extend({TheThrower, TheItem, TheRecipe})
		if (isitenabled == false) then
			table.insert(data.raw["technology"]["RTThrowerTime"].effects, {type="unlock-recipe", recipe=TheRecipe.name})
		end
		if mods["quality"] then
			local icons =
			{
				{
					icon = "__quality__/graphics/icons/recycling.png"
				}
			}
			if TheItem.icons then
				for i = 1, #TheItem.icons do
					local icon = table.deepcopy(TheItem.icons[i]) -- we are gonna change the scale, so must copy the table
					icon.scale = ((icon.scale == nil) and (0.5 * defines.default_icon_size / (icon.icon_size or defines.default_icon_size)) or icon.scale) * 0.8
					icon.shift = util.mul_shift(icon.shift, 0.8)
					icons[#icons + 1] = icon
				end
			else
				icons[#icons + 1] =
				{
					icon = TheItem.icon,
					icon_size = TheItem.icon_size,
					scale = (0.5 * defines.default_icon_size / (TheItem.icon_size or defines.default_icon_size)) * 0.8,
				}
			end
			icons[#icons + 1] =
			{
				icon = "__quality__/graphics/icons/recycling-top.png"
			}
			data:extend({
				{
					type = "recipe",
					name = TheRecipe.name.."-recycling",
					icons = icons,
					category = "recycling",
					subgroup = TheRecipe.subgroup,
					enabled = true,
					hidden = true,
					unlock_results = false,
					ingredients = {{type = "item", name = TheItem.name, amount = 1, ignored_by_stats = 1}},
					results = {{type = "item", name = TheItem.name, amount = 1, probability = 0.25, ignored_by_stats = 1}}, -- Will show as consumed when item is destroyed
					energy_required = (data.raw.recipe[TheItem.name] and data.raw.recipe[TheItem.name].energy_required or 0.5 )/16,
				}
			})
		end
	end
end

----- Get the sprites of the carriage to use during a jump
function MakeCarriageSprites(ThingData)
	log("--------Extracting train sprites for "..ThingData.type..": "..ThingData.name.."-----------")
	--if (ThingData.pictures and ThingData.pictures.rotated.layers) then
		local UpSprites = {{
							filename = renaiEntity .. "trains/WheelsVertical.png",
							size = {200,500},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local RightSprites = {{
							filename = renaiEntity .. "trains/WheelsHorizontal.png",
							size = {500,200},
							shift = {0,-0.5},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local DownSprites = {{
							filename = renaiEntity .. "trains/WheelsVertical.png",
							size = {200,500},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local LeftSprites = {{
							filename = renaiEntity .. "trains/WheelsHorizontal.png",
							size = {500,200},
							shift = {0,-0.5},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local MaskUpSprites = {emptypic}
		local MaskRightSprites = {emptypic}
		local MaskDownSprites = {emptypic}
		local MaskLeftSprites = {emptypic}
		-- local SpriteSize = {1,1}
		-- local SpriteScale = 1
		local SpriteSets
		if (ThingData.pictures
		and ThingData.pictures.rotated) then
			if (ThingData.pictures.rotated.layers) then
				SpriteSets = ThingData.pictures.rotated.layers
			else
				SpriteSets = {ThingData.pictures.rotated}
			end
		else
			-- no images (invisibel)
		end
		if (SpriteSets ~= nil) then
			for each, SpriteSet in pairs(SpriteSets) do
				if ((SpriteSet.flags == nil or (SpriteSet.flags and SpriteSet.flags[1] ~= "mask" and SpriteSet.flags[1] ~= "shadow")) and SpriteSet.draw_as_shadow == nil) then  -- carriage "body" sprite
					if (SpriteSet.filenames and (SpriteSet.line_length*SpriteSet.lines_per_file)%4 == 0) then
						if (SpriteSet.back_equals_front ~= true) then
							table.insert(UpSprites, {filename = SpriteSet.filenames[1+0],
												x = SpriteSet.width*(0%SpriteSet.line_length),
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(RightSprites, {filename = SpriteSet.filenames[1+math.floor(0.25*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.25*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.25*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(DownSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(LeftSprites, {filename = SpriteSet.filenames[1+math.floor(0.75*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.75*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.75*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
						else
							table.insert(UpSprites, {filename = SpriteSet.filenames[1+0],
												x = SpriteSet.width*(0%SpriteSet.line_length),
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(RightSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(DownSprites, {filename =SpriteSet.filenames[1+0], 
												x = SpriteSet.width*(0%SpriteSet.line_length), 
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(LeftSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)], 
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
						end
					end


				elseif (SpriteSet.flags and SpriteSet.flags[1] == "mask" and SpriteSet.draw_as_shadow == nil) then	-- carriage mask
					if (SpriteSet.filenames and (SpriteSet.line_length*SpriteSet.lines_per_file)%4 == 0) then
						if (SpriteSet.back_equals_front ~= true) then
							table.insert(MaskUpSprites, {filename = SpriteSet.filenames[1+0],
												x = SpriteSet.width*(0%SpriteSet.line_length),
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskRightSprites, {filename = SpriteSet.filenames[1+math.floor(0.25*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.25*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.25*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskDownSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskLeftSprites, {filename = SpriteSet.filenames[1+math.floor(0.75*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.75*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.75*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
						else
							table.insert(MaskUpSprites, {filename = SpriteSet.filenames[1+0],
												x = SpriteSet.width*(0%SpriteSet.line_length),
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskRightSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskDownSprites, {filename = SpriteSet.filenames[1+0], 
												x = SpriteSet.width*(0%SpriteSet.line_length),
												y = SpriteSet.height*math.floor((0%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height}, 
												scale = SpriteSet.scale, 
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
							table.insert(MaskLeftSprites, {filename = SpriteSet.filenames[1+math.floor(0.5*#SpriteSet.filenames)],
												x = SpriteSet.width*((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%SpriteSet.line_length),
												y = SpriteSet.height*math.floor(((0.5*#SpriteSet.filenames*SpriteSet.line_length*SpriteSet.lines_per_file)%(SpriteSet.line_length*SpriteSet.lines_per_file))/SpriteSet.line_length),
												size = {SpriteSet.width, SpriteSet.height},
												scale = SpriteSet.scale,
												shift = SpriteSet.shift,
												tint = SpriteSet.tint})
						end
					end
				end
			end -- for loop end
		end

		--if (#UpSprites>1 and #RightSprites>1 and #DownSprites>1 and #LeftSprites>1) then
			data:extend({
				{
					type = "sprite",
					name = "RT"..ThingData.name.."up",
					layers = UpSprites
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."right",
					layers = RightSprites
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."down",
					layers = DownSprites
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."left",
					layers = LeftSprites
				}
			})
		--end
		--if (#MaskUpSprites>1 and #MaskRightSprites>1 and #MaskDownSprites>1 and #MaskLeftSprites>1) then
			data:extend({
				{
					type = "sprite",
					name = "RT"..ThingData.name.."Maskup",
					flags = { "mask" },
					layers = MaskUpSprites,
					tint_as_overlay = true,
					apply_runtime_tint = true
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."Maskright",
					flags = { "mask" },
					layers = MaskRightSprites,
					tint_as_overlay = true,
					apply_runtime_tint = true
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."Maskdown",
					flags = { "mask" },
					layers = MaskDownSprites,
					tint_as_overlay = true,
					apply_runtime_tint = true
				},
				{
					type = "sprite",
					name = "RT"..ThingData.name.."Maskleft",
					flags = { "mask" },
					layers = MaskLeftSprites,
					tint_as_overlay = true,
					apply_runtime_tint = true
				}
			})
		--end
	--end
end

--- loop through data.raw ---------------------------------
---- Make thrower variants first so that the projectile generating will work

for ThingID, ThingData in pairs(data.raw.inserter) do
	-- lots of requirements to make sure not pick up any "function only" inserters from other mods --
	if (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTModdedThrowers"].value == true) then
		if (ThingData.type == "inserter") then
			log("--------Checking if "..ThingData.name.." should have thrower varient-----------")
			if
				(ThingData.energy_source.type ~= "void"
				and ThingData.draw_held_item ~= false
				and ThingData.selectable_in_game ~= false
				and ThingData.minable
				and ThingData.rotation_speed ~= 0
				and ThingData.extension_speed ~= 0
				and ThingData.selection_box[1][1] >= -0.5
				and ThingData.selection_box[1][2] >= -0.5
				and ThingData.selection_box[2][1] <= 0.5
				and ThingData.selection_box[2][2] <= 0.5
				and not string.find(ThingData.name, "RTThrower-")
				--and (not ThingData.name ~= "thrower-inserter")
			)then
				local PlacingItem
				if (ThingData.minable.result) then
					PlacingItem = ThingData.minable.result
				elseif (ThingData.minable.results) then
					for _, result in pairs(ThingData.minable.results) do
						if (result.type == "item") then
							PlacingItem = result.name
						end
					end
				end
				if (PlacingItem and data.raw.item[PlacingItem]) then -- and ThingData.insert_position[1] == 0) then
					MakeThrowerVariant(ThingData, PlacingItem)
				else
					log("-----------"..ThingData.name.." doesn't have a valid item to place.")
				end
			else
				if (ThingData.energy_source.type == "void") then
					log("-----------"..ThingData.name.." is a void inserter.")
				elseif (ThingData.draw_held_item == false) then
					log("-----------"..ThingData.name.." is not a held item inserter.")
				elseif (ThingData.selectable_in_game == false) then
					log("-----------"..ThingData.name.." is not selectable in game.")
				elseif (ThingData.minable == nil) then
					log("-----------"..ThingData.name.." is not minable.")
				elseif (ThingData.minable.result == nil) then
					log("-----------"..ThingData.name.." doesn't have a mine result.")
					if (ThingData.minable.results) then
						log("-------------"..ThingData.name.." has a resultS table.")
					end
				elseif (ThingData.rotation_speed == 0) then
					log("-----------"..ThingData.name.." has no rotation speed.")
				elseif (ThingData.extension_speed == 0) then
					log("-----------"..ThingData.name.." has no extension speed.")
				elseif (data.raw.item[ThingData.minable.result] == nil) then
					log("-----------"..ThingData.name.."'s mine result item doesnt exist.")
				elseif (ThingData.selection_box[1][1] < -0.5) then
					log("-----------"..ThingData.name.." has a selection box top left that is too big.")
				elseif (ThingData.selection_box[1][2] < -0.5) then
					log("-----------"..ThingData.name.." has a selection box top left that is too big.")
				elseif (ThingData.selection_box[2][1] > 0.5) then
					log("-----------"..ThingData.name.." has a selection box bottom right that is too big.")
				elseif (ThingData.selection_box[2][2] > 0.5) then
					log("-----------"..ThingData.name.." has a selection box bottom right that is too big.")
				elseif (string.find(ThingData.name, "RTThrower-")) then
					log("-----------"..ThingData.name.." is already a thrower inserter.")
				end
			end
		end
	elseif (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTModdedThrowers"].value == false) then
		if (ThingData.name == "burner-inserter"
		or ThingData.name == "inserter"
		or ThingData.name == "fast-inserter"
		or ThingData.name == "long-handed-inserter"
		or ThingData.name == "bulk-inserter"
		or ThingData.name == "stack-inserter")
		then
			MakeThrowerVariant(ThingData)
		end
	end
end

-- item cannon shell projectils
for Category, ThingsTable in pairs(data.raw) do
	for ThingID, ThingData in pairs(ThingsTable) do
		if (ThingData.stack_size and ThingData.hidden ~= true and ThingData.parameter ~= true and (ThingID == "RTItemShellItem" or not string.find(ThingID, "RTItemShell"))) then
			log("==========Creating item cannon projectile for "..ThingData.type..": "..ThingData.name.."===========")
			MakeItemShellStuff(table.deepcopy(ThingData))
		end
	end
end

for Category, ThingsTable in pairs(data.raw) do
	for ThingID, ThingData in pairs(ThingsTable) do
		if (ThingData.stack_size) then
			log("==========Creating item projectile for "..ThingData.type..": "..ThingData.name.."===========")
			MakeProjectile(table.deepcopy(ThingData), 0.18) -- thrower inserter speed
			MakeProjectile(table.deepcopy(ThingData), 0.25) -- ejector hatch speed
			MakeProjectile(table.deepcopy(ThingData), 0.6) -- train bounce pad speed
			if (settings.startup["RTBounceSetting"].value == true) then
				if (ThingData.type == "ammo" -- looking for things like rockets, tank shells, missles, etc
				and ThingData.ammo_type.action --if this ammo does something
				) then
					if (ThingData.ammo_type.action[1]) then
						for i, action in pairs(ThingData.ammo_type.action) do
							if (action.action_delivery and action.action_delivery.type ~= "stream" and action.action_delivery.projectile) then
								MakePrimedProjectile(table.deepcopy(ThingData), action.action_delivery.type)
							end
						end
					elseif (ThingData.ammo_type.action and ThingData.ammo_type.action.action_delivery and ThingData.ammo_type.action.action_delivery.type ~= "stream" and ThingData.ammo_type.action.action_delivery.projectile) then
						MakePrimedProjectile(table.deepcopy(ThingData), ThingData.ammo_type.action.action_delivery.type)
					end
				elseif
					(
						(
							Category == "capsule" --if its a capsule
							and ThingData.capsule_action.type == "throw" --with a thrown action
							and
							(
								( -- 0.18.36+ capsule action notation
								ThingData.capsule_action.attack_parameters.ammo_type.action
								and ThingData.capsule_action.attack_parameters.ammo_type.action[1]
								and ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery
								and ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile
								and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile]--that has an associated projectile
								and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile].action --that does something
								)
								or
								( -- old capsule action notation
								ThingData.capsule_action.attack_parameters.ammo_type.action
								and ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery
								and ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile
								and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile]--that has an associated projectile
								and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile].action --that does something
								)
							)
						)
						or data.raw["land-mine"][ThingData.place_result]
					) then
					MakePrimedProjectile(table.deepcopy(ThingData), "capsule")
				end
			end
		end


		if (settings.startup["RTZiplineSetting"].value == true) then
			if (ThingData.type == "electric-pole") then
				if (ThingData.connection_points.wire and ThingData.connection_points.wire.copper) then
					Points = ThingData.connection_points.wire.copper
				elseif (ThingData.connection_points[1].wire and ThingData.connection_points[1].wire.copper) then
					xavg = 0
					yavg = 0
					for each, varient in pairs(ThingData.connection_points) do
						xavg = xavg + varient.wire.copper[1]
						yavg = yavg + varient.wire.copper[2]
					end
					Points = {xavg/#ThingData.connection_points, yavg/#ThingData.connection_points}
				end
				if (Points ~= nil) then
					data:extend
					({
						{
							type = "recipe",
							name = "RTGetTheGoods-"..ThingData.name.."X",
							enabled = false,
							hidden = true,
							emissions_multiplier = Points[1],
							ingredients =
								{
									{type="item", name="infinity-chest", amount=360}
								},
							results = {
								{type="item", name="infinity-chest", amount=1}
							}
						},
						{
							type = "recipe",
							name = "RTGetTheGoods-"..ThingData.name.."Y",
							enabled = false,
							hidden = true,
							emissions_multiplier = Points[2],
							ingredients =
								{
									{type="item", name="infinity-chest", amount=360}
								},
							results = {
								{type="item", name="infinity-pipe", amount=1}
							}
						},
					})
				end
			end
		end

		if (Category == "locomotive" or Category == "cargo-wagon" or Category == "fluid-wagon") then
			MakeCarriageSprites(table.deepcopy(ThingData))
		end

		if (Category == "character" and (not string.find(ThingID, "RTGhost")) and (not string.find(ThingID, "-jetpack"))) then
			local casper = table.deepcopy(ThingData)
			casper.name = casper.name.."RTGhost"
			casper.collision_mask = {layers={}}
			-- remove shadows
			for q = 1, #casper.animations do
				for ActionCategory, sprites in pairs(casper.animations[q]) do
					if (type(sprites) == "table" and sprites.layers) then
						for i, sprite in pairs(sprites.layers) do
							if (sprite.draw_as_shadow) then
								sprite.filename = emptypng
								sprite.size = 1
							end
						end
					end
				end
			end
			-- remove reflection
			if (casper.water_reflection) then
				casper.water_reflection = nil
			end

			if (casper.resistances) then
				table.insert(casper.resistances,
					{
						type = "fire",
						percent = 80
					}
				)
			else
				casper.resistances =
				{
					{
						type = "fire",
						percent = 80
					}
				}
			end
			data:extend({casper})
		end

		--[[ if (Category == "fluid") then
			data:extend({
				{
					type = "item",
					name = "RT"..ThingID.."SplashCapsule",
					icons =
					{
						{
							icon = "__RenaiTransportation__/graphics/SplashCapsule/SplashCapsuleFluid.png",
							tint = ThingData.base_color,
							icon_size = 64,
						},
						{
							icon = "__RenaiTransportation__/graphics/SplashCapsule/EmptySplashCapsule.png",
							icon_size = 64,
						}
					},
					subgroup = "intermediate-product",
					order = "z-a",
					stack_size = 50
				}
			})
		end ]]
	end
end

if (settings.startup["RTZiplineSetting"].value == true) then
	for _, ingredient in pairs(data.raw.recipe.RTZiplineTrolley4.ingredients) do
		if (ingredient.type and ingredient.type == "fluid") then
			data.raw.recipe.RTZiplineTrolley4.category = "crafting-with-fluid"
			break
		end
	end
end
-- some mods make land mines snap to grid, which causes a crash when it shifts these detector land mines to not be on top of the belt ramps
if (settings.startup["RTThrowersSetting"].value == true) then
	data.raw["land-mine"].RTBeltRampPlayerTrigger.flags = {"not-on-map", "placeable-off-grid", "not-selectable-in-game", "no-copy-paste", "not-blueprintable", "not-deconstructable"}
end