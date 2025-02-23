function MakeProjectile(ThingData, speed)
	if (ThingData.icon_size == nil) then
		ThingData.icon_size = 64
	end
	local TheProjectile =
		{
			type = "stream",
			name = "RTItemProjectile-"..ThingData.name..(speed*100 or 18),
			flags = {"not-on-map"},
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
		if (ThingData.icon_size) then
			TheProjectile.particle.size = ThingData.icon_size
		else
			TheProjectile.particle.size = ThingData.icons[1].icon_size
		end

		TheProjectile.particle.layers = {}
		TheProjectile.shadow.layers = {}
		for iconlayer, iconspecs in pairs(ThingData.icons) do
			local eeee
			local rrrr
			if (iconspecs.icon_size) then
				eeee = iconspecs.icon_size
			else
				eeee = TheProjectile.particle.size
			end

			if (iconspecs.tint) then
				rrrr = iconspecs.tint
			else
				rrrr = nil
			end

			table.insert(TheProjectile.particle.layers,
				{
					filename = iconspecs.icon,
					line_length = 1,
					frame_count = 1,
					priority = "high",
					scale = 19.2/eeee,
					size = eeee,
					tint = rrrr
				})
			table.insert(TheProjectile.shadow.layers,
				{
					filename = iconspecs.icon,
					line_length = 1,
					frame_count = 1,
					priority = "high",
					scale = 19.2/eeee,
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
				icon_size = 64, icon_mipmaps = 4,
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
				folded_animation = {direction_count=4, filename = "__RenaiTransportation__/graphics/nothing.png", size=1},
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
function MakeThrowerVariant(ThingData)

TheItem = table.deepcopy(data.raw.item[ThingData.minable.result])
	TheItem.name = "RTThrower-"..TheItem.name.."-Item"
	TheItem.subgroup = "throwers"
	TheItem.place_result = "RTThrower-"..ThingData.name
	if (TheItem.icon) then
		TheItem.icons =
			{
				{
				icon = TheItem.icon,
				icon_size = TheItem.icon_size,
				icon_mipmaps = TheItem.icon_mipmaps
				},

				{
				icon = "__RenaiTransportation__/graphics/ThrowerInserter/overlay.png",
				icon_size = 64,
				icon_mipmaps = 4
				}
			}
	else
		table.insert(TheItem.icons, {icon = "__RenaiTransportation__/graphics/ThrowerInserter/overlay.png",	icon_size = 64, icon_mipmaps = 4})
	end

if (ThingData.name == "inserter" or ThingData.name == "burner-inserter") then
	isitenabled = true
else
	isitenabled = false
end
TheRecipe =
	{
		type = "recipe",
		name = "RTThrower-"..ThingData.name.."-Recipe",
		enabled = isitenabled,
		energy_required = 1,
		localised_name =  "Thrower "..ThingData.name:gsub("-i"," i"), 
		ingredients =
			{
				{type="item", name=ThingData.minable.result, amount=1},
				{type="item", name="copper-cable", amount=4}
			},
		results = {
			{type="item", name=TheItem.name, amount=1}
		}
	}

TheThrower = table.deepcopy(data.raw.inserter[ThingData.name])
	TheThrower.name = "RTThrower-"..ThingData.name
	TheThrower.minable = {mining_time = 0.1, result = TheItem.name}
	TheThrower.localised_name ="Thrower "..ThingData.name:gsub("-i"," i")
	--TheThrower.localised_name = {"thrower-gen.name", {"entity-name."..ThingData.name}}
	TheThrower.insert_position = {0, 15.2}
	TheThrower.allow_custom_vectors = true
	ItsRange = 15

	if (TheThrower.energy_per_rotation) then
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
		ItsRange = math.floor(math.sqrt(original_inserter.insert_position[1]^2 + original_inserter.insert_position[2]^2)) * 10 + 5
		TheThrower.insert_position = {0, ItsRange+0.2}
	end

	if (TheThrower.localised_description) then
		TheThrower.localised_description = {"thrower-gen.HasDesc", tostring(ItsRange), TheThrower.localised_description}
	else
		TheThrower.localised_description = {"thrower-gen.DefaultDesc", tostring(ItsRange)}
	end
	TheThrower.hand_size = 0
	TheThrower.hand_base_picture =
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
		}
	TheThrower.hand_closed_picture =
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
		}
	TheThrower.hand_open_picture =
		{
		filename = "__RenaiTransportation__/graphics/ThrowerInserter/hr-inserter-hand-open.png",
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
		table.insert(data.raw["technology"]["RTThrowerTime"].effects,{type="unlock-recipe",recipe=TheRecipe.name})
	end
end
end

----- Get the sprites of the carriage to use during a jump
function MakeCarriageSprites(ThingData)
	log("--------Extracting train sprites for "..ThingData.type..": "..ThingData.name.."-----------")
	--if (ThingData.pictures and ThingData.pictures.rotated.layers) then
		local UpSprites = {{
							filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/WheelsVertical.png",
							size = {200,500},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
						  }}
		local RightSprites = {{
							filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/WheelsHorizontal.png",
							size = {500,200},
							shift = {0,-0.5},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local DownSprites = {{
							filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/WheelsVertical.png",
							size = {200,500},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local LeftSprites = {{
							filename = "__RenaiTransportation__/graphics/TrainRamp/trains/base/WheelsHorizontal.png",
							size = {500,200},
							shift = {0,-0.5},
							scale = 0.5,
							tint = {0.5, 0.5, 0.5}
							}}
		local MaskUpSprites = {{
							filename = "__RenaiTransportation__/graphics/nothing.png",
							size = 1,
							}}
		local MaskRightSprites = {{
							filename = "__RenaiTransportation__/graphics/nothing.png",
							size = 1,
							}}
		local MaskDownSprites = {{
							filename = "__RenaiTransportation__/graphics/nothing.png",
							size = 1,
							}}
		local MaskLeftSprites = {{
							filename = "__RenaiTransportation__/graphics/nothing.png",
							size = 1,
							}}
		-- local SpriteSize = {1,1}
		-- local SpriteScale = 1
		local SpriteSets
		if (ThingData.pictures
		and ThingData.pictures.rotated) then
			if (ThingData.pictures.rotated.layers) then
				SpriteSets = ThingData.pictures.rotated.layers
			else
				SpriteSets = ThingData.pictures.rotated
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
		if (ThingData.type == "inserter"
			and ThingData.energy_source.type ~= "void"
			and ThingData.draw_held_item ~= false
			and ThingData.selectable_in_game ~= false
			and ThingData.minable
			and ThingData.minable.result
			and ThingData.rotation_speed ~= 0
			and ThingData.extension_speed ~= 0
			and data.raw.item[ThingData.minable.result] ~= nil
			and ThingData.selection_box[1][1] >= -0.5
			and ThingData.selection_box[1][2] >= -0.5
			and ThingData.selection_box[2][1] <= 0.5
			and ThingData.selection_box[2][2] <= 0.5
			and not string.find(ThingData.name, "RTThrower-")
			--and (not ThingData.name ~= "thrower-inserter")
		)then
			MakeThrowerVariant(ThingData)
		end
	elseif (settings.startup["RTThrowersSetting"].value == true and settings.startup["RTModdedThrowers"].value == false) then
		if (ThingData.name == "burner-inserter"
		or ThingData.name == "inserter"
		or ThingData.name == "fast-inserter"
		or ThingData.name == "long-handed-inserter"
		or ThingData.name == "filter-inserter"
		or ThingData.name == "stack-filter-inserter"
		or ThingData.name == "stack-inserter")
		then
			MakeThrowerVariant(ThingData)
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
								sprite.filename = "__RenaiTransportation__/graphics/nothing.png"
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
	end
end

if (settings.startup["RTZiplineSetting"].value == true) then
	for _, ingredient in pairs(data.raw.recipe.RTZiplineRecipe4.ingredients) do
		if (ingredient.type and ingredient.type == "fluid") then
			data.raw.recipe.RTZiplineRecipe4.category = "crafting-with-fluid"
			break
		end
	end
end