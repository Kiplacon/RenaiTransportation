---@diagnostic disable: need-check-nil
function GetOnZipline(player, PlayerProperties, pole)
	---------- get on zipline -----------------
	local OG = SwapToGhost(player)
	local TheGuy = player
	local FromXWireOffset = prototypes.recipe["RTGetTheGoods-"..pole.name.."X"].emissions_multiplier
	local FromYWireOffset = prototypes.recipe["RTGetTheGoods-"..pole.name.."Y"].emissions_multiplier
	local EquippedTrolley = player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name
	local SpookySlideGhost = pole.surface.create_entity
		({
			name = "RTPropCar",
			position = {pole.position.x+FromXWireOffset, pole.position.y+FromYWireOffset},
			--force = TheGuy.force,
			create_build_effect_smoke = false
		})
	local trolley = pole.surface.create_entity
		({
			name = "RTZipline",
			position = {pole.position.x+FromXWireOffset, pole.position.y+FromYWireOffset},
			force = TheGuy.force,
			create_build_effect_smoke = false
		})

	local drain
	local shade
	if (EquippedTrolley == "RTZiplineItem") then
		drain = pole.surface.create_entity
			({
				name = "RTZiplinePowerDrain",
				position = pole.position,
				force = TheGuy.force,
				create_build_effect_smoke = false
			})
		shade = {1,1,1}
	elseif (EquippedTrolley == "RTZiplineItem2") then
		drain = pole.surface.create_entity
			({
				name = "RTZiplinePowerDrain2",
				position = pole.position,
				force = TheGuy.force,
				create_build_effect_smoke = false
			})
		shade = {1,0.9,0}
	elseif (EquippedTrolley == "RTZiplineItem3") then
		drain = pole.surface.create_entity
			({
				name = "RTZiplinePowerDrain3",
				position = pole.position,
				force = TheGuy.force,
				create_build_effect_smoke = false
			})
		shade = {255,35,35}
	elseif (EquippedTrolley == "RTZiplineItem4") then
		drain = pole.surface.create_entity
			({
				name = "RTZiplinePowerDrain4",
				position = pole.position,
				force = TheGuy.force,
				create_build_effect_smoke = false
			})
		shade = {18,201,233}
	elseif (EquippedTrolley == "RTZiplineItem5") then
		drain = pole.surface.create_entity
			({
				name = "RTZiplinePowerDrain5",
				position = pole.position,
				force = TheGuy.force,
				create_build_effect_smoke = false
			})
		shade = {83,255,26}
	end

	rendering.draw_animation
		{
			animation = "RTZiplineOverGFX",
			surface = TheGuy.surface,
			tint = shade,
			target = trolley,
			target_offset = {0, -0.3},
			x_scale = 0.5,
			y_scale = 0.5,
			render_layer = "wires-above"
		}
	rendering.draw_sprite
		{
			sprite = "RTZiplineHarnessGFX",
			surface = TheGuy.surface,
			tint = shade,
			target = trolley,
			target_offset = {0.03, 0.1},
			x_scale = 0.5,
			y_scale = 0.5,
			render_layer = "128"
		}
	trolley.destructible = false
	SpookySlideGhost.destructible = false
	drain.destructible = false
	TheGuy.teleport({SpookySlideGhost.position.x, 2+SpookySlideGhost.position.y})
	trolley.teleport({SpookySlideGhost.position.x, 0.5+SpookySlideGhost.position.y})
	PlayerProperties.zipline.LetMeGuideYou = SpookySlideGhost
	PlayerProperties.zipline.ChuggaChugga = trolley
	PlayerProperties.zipline.WhereDidYouComeFrom = pole
	PlayerProperties.zipline.AreYouStillThere = true
	PlayerProperties.zipline.succ = drain
	--game.print("Attached to track")
	PlayerProperties.state = "zipline"
	PlayerProperties.zipline.StartingSurface = TheGuy.surface
	PlayerProperties.SwapBack = OG
	--PlayerProperties.OGSpeed = player.character.character_running_speed_modifier
	pole.surface.play_sound
		{
			path = "RTZipAttach",
			position = pole.position,
			volume = 0.7
		}
end

function GetOffZipline(player, PlayerProperties)
	local ZiplineStuff = PlayerProperties.zipline
	SwapBackFromGhost(player)
	ZiplineStuff.LetMeGuideYou.surface.play_sound
		{
			path = "RTZipDettach",
			position = ZiplineStuff.LetMeGuideYou.position,
			volume = 0.4
		}
	ZiplineStuff.LetMeGuideYou.surface.play_sound
		{
			path = "RTZipWindDown",
			position = ZiplineStuff.LetMeGuideYou.position,
			volume = 0.4
		}
	ZiplineStuff.LetMeGuideYou.destroy()
	ZiplineStuff.ChuggaChugga.destroy()
	ZiplineStuff.succ.destroy()
	ZiplineStuff.braking = nil
	if (player.character.get_inventory(defines.inventory.character_armor)
	and player.character.get_inventory(defines.inventory.character_armor).is_full()
	and player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == true) then
		-- don't drop
	else
		player.teleport(player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 0, 0.01))
	end
	PlayerProperties.zipline = {}
	PlayerProperties.state = "default"
	--player.character.character_running_speed_modifier = PlayerProperties.OGSpeed
	PlayerProperties.OGSpeed = nil
end

local function GetOnOrOffZipline(event) -- has .name = event ID number, .tick = tick number, .player_index, and .input_name = custom input name
	local player = game.get_player(event.player_index)
	local PlayerProperties = storage.AllPlayers[event.player_index]
	local CursorPosition = event.cursor_position
	local ThingHovering = player.selected

    --| Drop from ziplining
	if (PlayerProperties.state == "zipline" and (player.selected == nil or player.selected.type ~= "electric-pole")) then
        if (player.character.get_inventory(defines.inventory.character_armor)
        and player.character.get_inventory(defines.inventory.character_armor).is_full()
        and player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == true) then
            GetOffZipline(player, PlayerProperties)

        elseif (player.surface.find_non_colliding_position("character", {player.position.x, player.position.y+2}, 5, 0.01)
        and player.character.get_inventory(defines.inventory.character_armor)
        and (
                (player.character.get_inventory(defines.inventory.character_armor).is_full()
                and player.character.get_inventory(defines.inventory.character_armor)[1].prototype.provides_flight == false)
            or
                (player.character.get_inventory(defines.inventory.character_armor).is_empty())
            )
        ) then
            GetOffZipline(player, PlayerProperties)

        else
            player.print({"zipline-stuff.NoFreeSpot"})
        end
		--game.print("manually detached")
	end

    --| Hovering something
	if (ThingHovering) then
    --|| Zipline
		if (player.character
		and player.character.driving == false
		and (not string.find(player.character.name, "RTGhost"))
		and (not string.find(player.character.name, "-jetpack"))
		and PlayerProperties.state == "default"
		and ThingHovering.type == "electric-pole"
		and ElectricPoleBlackList[ThingHovering.name] == nil
		and ThingHovering.get_wire_connector(defines.wire_connector_id.pole_copper, true).connection_count > 0) then
			if (math.sqrt((player.position.x-ThingHovering.position.x)^2+(player.position.y-ThingHovering.position.y)^2) <= 6) then
				if (player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].valid_for_read
				and string.find(player.character.get_inventory(defines.inventory.character_guns)[player.character.selected_gun_index].name, "RTZiplineItem")
				and player.character.get_inventory(defines.inventory.character_ammo)[player.character.selected_gun_index].valid_for_read)
				then
					GetOnZipline(player, PlayerProperties, ThingHovering)
				else
					player.print({"zipline-stuff.reqs"})
				end
			else
				player.print({"zipline-stuff.range"})
			end

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and string.find(player.character.name, "-jetpack")) then
			player.print({"zipline-stuff.range"})

		elseif (player.character and player.character.driving == false and PlayerProperties.state == "default" and ThingHovering.type == "electric-pole" and #ThingHovering.neighbours == 0) then
			player.print({"zipline-stuff.NotConnected"})

		end
    end
end

return GetOnOrOffZipline