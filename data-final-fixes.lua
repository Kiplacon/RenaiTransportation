function MakeProjectile(ThingData)
  
TheProjectile = table.deepcopy(data.raw.stream["acid-stream-spitter-small"])
	TheProjectile.name = ThingData.name.."-projectileFromRenaiTransportation"
	TheProjectile.special_neutral_target_damage = {amount = 0, type = "acid"}
	--TheProjectile.scale = 5     --does nothing as far as i can tell
	--TheProjectile.particle_buffer_size = 90
    TheProjectile.particle_spawn_interval = 0
    TheProjectile.particle_spawn_timeout = 0
    TheProjectile.particle_vertical_acceleration = 0.0035 -- gravity, default 0.0045
    TheProjectile.particle_horizontal_speed = 0.18 -- speed, default 0.3375
    TheProjectile.particle_horizontal_speed_deviation = 0
    --TheProjectile.particle_start_alpha = 0.5
    --TheProjectile.particle_end_alpha = 1
    --TheProjectile.particle_alpha_per_part = 0.8
    --TheProjectile.particle_scale_per_part = 0.8
    --TheProjectile.particle_loop_frame_count = 15
    --TheProjectile.particle_fade_out_duration = 2
    --TheProjectile.particle_loop_exit_threshold = 0.25
	
	TheProjectile.working_sound = nil
	
	TheProjectile.initial_action =
	  {
		type = "direct",
		action_delivery =
		{
		  type = "instant",
		  target_effects =
		  {
			{
			  type = "script",
			  effect_id = ThingData.name.."-LandedRT"
			}
		  }
		}
	  }
	  
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
	end
else
	TheProjectile.particle = {
      filename = ThingData.icon,
      line_length = 1,
      width = ThingData.icon_size,
      height = ThingData.icon_size,
      frame_count = 1,
      --shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      --tint = data.tint,
      priority = "high",
      scale = 19.2/ThingData.icon_size --0.3
      --animation_speed = 1,
    }
end	
	
	TheProjectile.spine_animation = nil

	data:extend({TheProjectile})
end


function MakePrimedProjectile(ThingData)-------------------------------------------
  
TheProjectile = table.deepcopy(data.raw.stream["acid-stream-spitter-small"])
	TheProjectile.name = ThingData.name.."-projectileFromRenaiTransportationPrimed"
	TheProjectile.special_neutral_target_damage = {amount = 0, type = "acid"}
    TheProjectile.particle_spawn_interval = 0
    TheProjectile.particle_spawn_timeout = 0
    TheProjectile.particle_vertical_acceleration = 0.004 -- gravity, default 0.0045
    TheProjectile.particle_horizontal_speed = 0.3 -- speed, default 0.3375
    TheProjectile.particle_horizontal_speed_deviation = 0
	TheProjectile.working_sound = nil
	
	if (ThingData.ammo_type and ThingData.ammo_type.category == "cannon-shell") then -- tank shells
		TheProjectile.initial_action = data.raw.projectile[ThingData.ammo_type.action.action_delivery.projectile].final_action
		  
	elseif (ThingData.capsule_action) then --capsules with thrown actions: grenades, combat robots, poison, slowdown
		if (ThingData.capsule_action.attack_parameters.ammo_type.action[1]) then
			TheProjectile.initial_action = data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile].action
		elseif (ThingData.capsule_action.attack_parameters.ammo_type.action) then
			TheProjectile.initial_action = data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile].action
		end
	elseif (data.raw["land-mine"][ThingData.place_result]) then  --landmines
		TheProjectile.initial_action = 
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
		
	else -- rockets/atomic bombs/other
		TheProjectile.initial_action = data.raw.projectile[ThingData.ammo_type.action.action_delivery.projectile].action
		 
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
				scale = 19.2/eeee,
				size = eeee,
				tint = {200,0,0}
			})
	end
else
	TheProjectile.particle = {
      filename = ThingData.icon,
      line_length = 1,
      width = ThingData.icon_size,
      height = ThingData.icon_size,
      frame_count = 1,
	  tint = {200,0,0},
      --shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      priority = "high",
      scale = 19.2/ThingData.icon_size --0.3
      --animation_speed = 1,
    }
end	
	TheProjectile.spine_animation = nil

	data:extend({TheProjectile})
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
		ingredients = 
			{
				{ThingData.minable.result, 1},
				{"copper-cable", 4}
			},
		result = TheItem.name
	}

TheThrower = table.deepcopy(data.raw.inserter[ThingData.name])
	TheThrower.name = "RTThrower-"..ThingData.name
	TheThrower.minable = {mining_time = 0.1, result = TheItem.name}
	TheThrower.localised_name ="Thrower "..ThingData.name
	TheThrower.insert_position = {0, 14.9}
	TheThrower.allow_custom_vectors = true
	ItsRange = 15

	if (TheThrower.name == "RTThrower-inserter") then
	    TheThrower.extension_speed = 0.027 -- default 0.03, needs to be a but slower so we don't get LongB0is
		TheThrower.rotation_speed = 0.020 -- default 0.014
	elseif (TheThrower.name == "RTThrower-long-handed-inserter") then
		TheThrower.insert_position = {0, 24.9}
		ItsRange = 25
	end
	
	if (TheThrower.localised_description) then
		TheThrower.localised_description = {"test.combo", "This inserter has been re-wired to throw items "..ItsRange.." tiles through the air. Range can be configured with the right research.", TheThrower.localised_description}
	else
		TheThrower.localised_description = "This inserter has been re-wired to throw items "..ItsRange.." tiles through the air. Range can be configured with the right research."
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
data:extend({TheThrower, TheItem, TheRecipe})
if (isitenabled == false) then
	table.insert(data.raw["technology"]["RTThrowerTime"].effects,{type="unlock-recipe",recipe=TheRecipe.name})	
end
end
---------------------------------------------------------- loop through data.raw ---------------------------------
for Category, ThingsTable in pairs(data.raw) do
	for ThingID, ThingData in pairs(ThingsTable) do
		if (ThingData.stack_size) then
		
			MakeProjectile(ThingData)
			
			if (ThingData.type == "ammo" 
				and ThingData.ammo_type.action --if this ammo does something
				and ThingData.ammo_type.action.action_delivery --in the form of
				and ThingData.ammo_type.action.action_delivery.type == "projectile" --a projectile
				) then
				MakePrimedProjectile(ThingData)
			elseif 
				(
					(
						Category == "capsule" --if its a capsule
						and ThingData.capsule_action.type == "throw" --with a thrown action
						and 
						(
							( -- 0.18.36 capsule action notation
							ThingData.capsule_action.attack_parameters.ammo_type.action[1]
							and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile]--that has an associated projectile
							and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action[1].action_delivery.projectile].action --that does something
							)
							or	
							( -- old capsule action notation
							ThingData.capsule_action.attack_parameters.ammo_type.action
							and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile]--that has an associated projectile
							and data.raw.projectile[ThingData.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile].action --that does something
							)
						)
					) 
					or data.raw["land-mine"][ThingData.place_result]
				) then
				MakePrimedProjectile(ThingData)
			end
			
		-- lots of requirements to make sure not pick up any repurposed inserters from other mods --
		elseif (ThingData.type == "inserter" 
			and ThingData.energy_source.type ~= "void" 
			and ThingData.draw_held_item ~= false 
			and ThingData.selectable_in_game ~= false 
			and ThingData.minable 
			and not string.find(ThingData.name, "RTThrower-")) then
			MakeThrowerVariant(ThingData)
		end
	end
end

MakeProjectile(
	{
		name = "test",
		icon = "__RenaiTransportation__/graphics/nothing.png",
		icon_size = 32
	}
)
