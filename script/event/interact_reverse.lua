local function ReverseInteract(event)
    local player = game.get_player(event.player_index)
	local PlayerProperties = storage.AllPlayers[event.player_index]
	local CursorPosition = event.cursor_position
	local ThingHovering = player.selected
    if (ThingHovering and settings.startup["RTThrowersSetting"].value == true and player.force.technologies["RTFocusedFlinging"].researched == true) then
        local DestroyNumber = script.register_on_object_destroyed(ThingHovering)
        if (ThingHovering.valid and ThingHovering.type == "inserter" and string.find(ThingHovering.name, "RTThrower-") and ThingHovering.name ~= "RTThrower-PrimerThrower" and storage.CatapultList[DestroyNumber].RangeAdjustable == true) then
            DecreaseThrowerRange(ThingHovering)
            player.create_local_flying_text
                {
                    position = ThingHovering.position,
                    text = "Range: "..storage.CatapultList[DestroyNumber].range
                }
            player.play_sound{
                path="utility/gui_click",
                position=player.position,
                volume_modifier=1
                }
        end
        
    elseif (settings.startup["RTThrowersSetting"].value == true and player.force.technologies["RTFocusedFlinging"].researched == true) then
        if (--player.character and
				player.cursor_stack.valid_for_read
				and string.find(player.cursor_stack.name, "RTThrower-")
				and player.cursor_stack.name ~= "RTThrower-EjectorHatchRT"
				and player.cursor_stack.name ~= "RTThrower-FilterEjectorHatchRT"
                and player.cursor_stack.name ~= "RTThrower-PrimerThrower"
			)
		or (
				player.cursor_ghost ~= nil
				and string.find(player.cursor_ghost.name.name, "RTThrower-")
				and player.cursor_ghost.name.name ~= "RTThrower-EjectorHatchRT"
				and player.cursor_ghost.name.name ~= "RTThrower-FilterEjectorHatchRT"
                and player.cursor_stack.name.name ~= "RTThrower-PrimerThrower"
		) then
            local ThrowerName
			if (player.cursor_stack.valid_for_read) then
				ThrowerName = string.gsub(player.cursor_stack.name, "-Item", "")
			else
				ThrowerName = string.gsub(player.cursor_ghost.name.name, "-Item", "")
			end
			local ThrowerNormalRange = math.sqrt(RealMaxRange(ThrowerName).x^2 + RealMaxRange(ThrowerName).y^2)
			local ThrowerUnitX = RealMaxRange(ThrowerName).x/ThrowerNormalRange
			local ThrowerUnitY = RealMaxRange(ThrowerName).y/ThrowerNormalRange
			player.clear_cursor()
			player.cursor_stack.set_stack({name = "blueprint"})
			player.cursor_stack.set_blueprint_entities(
			{
				{entity_number = 1, name = ThrowerName, position = {0,0}, direction = 8, drop_position = {-ThrowerUnitX * (ThrowerNormalRange-1) - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY * (ThrowerNormalRange-1) - ((ThrowerUnitY ~= 0) and (0.2) or 0)} }
			})
			player.cursor_stack_temporary = true
			player.play_sound{
				path="utility/gui_click",
				position=player.position,
				volume_modifier=1
				}
			player.create_local_flying_text
				{
					position = CursorPosition,
					text = "Range: "..math.floor(ThrowerNormalRange-1)
				}
			PlayerProperties.RangeAdjusting = true
			PlayerProperties.RangeAdjustingDirection = 8
			PlayerProperties.RangeAdjustingRange = math.floor(ThrowerNormalRange-1)
        elseif (PlayerProperties.RangeAdjusting == true) then
            if (player.is_cursor_blueprint() == true) then
                local thrower = player.cursor_stack.get_blueprint_entities()[1]
                local ThrowerName = thrower.name
                local ThrowerNormalRange = math.sqrt(RealMaxRange(ThrowerName).x^2 + RealMaxRange(ThrowerName).y^2)
                local ThrowerUnitX = RealMaxRange(ThrowerName).x/ThrowerNormalRange
                local ThrowerUnitY = RealMaxRange(ThrowerName).y/ThrowerNormalRange
                local CurrentRange = PlayerProperties.RangeAdjustingRange
                local NewDrop
                --game.print("CurrentRange: "..CurrentRange.." ThrowerNormalRange: "..ThrowerNormalRange)
                if (CurrentRange <= 1) then
                    CurrentRange = math.floor(ThrowerNormalRange)
                    NewDrop = {-ThrowerUnitX * math.floor(ThrowerNormalRange) - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY * math.floor(ThrowerNormalRange) - ((ThrowerUnitY ~= 0) and (0.2) or 0)}
                else
                    CurrentRange = CurrentRange - 1
                    NewDrop = {-ThrowerUnitX * CurrentRange - ((ThrowerUnitX ~= 0) and (0.2) or 0), -ThrowerUnitY * CurrentRange - ((ThrowerUnitY ~= 0) and (0.2) or 0)}
                end
                player.cursor_stack.set_blueprint_entities(
                    {
                        {entity_number = 1, name = thrower.name, position = {0,0}, direction = 8, drop_position = NewDrop}
                    })
                player.play_sound{
                    path="utility/gui_click",
                    position=player.position,
                    volume_modifier=1
                    }
                PlayerProperties.RangeAdjusting = true
                PlayerProperties.RangeAdjustingRange = CurrentRange
                player.create_local_flying_text
                    {
                        position = CursorPosition,
                        text = "Range: "..CurrentRange
                    }
            else
                PlayerProperties.RangeAdjusting = false
            end
        end
    end
end

return ReverseInteract