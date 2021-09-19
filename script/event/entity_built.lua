local trainHandler = require("__RenaiTransportation__/script/trains/entity_built")

local function entity_built(event)
	local entity = event.created_entity or event.entity or event.destination

	local player = nil

	--game.print(entity.name)

	if event.player_index then
		player = game.players[event.player_index]
		if (global.AllPlayers[event.player_index].RangeAdjusting
		and entity.name == "entity-ghost"
		and string.find(entity.ghost_prototype.name, "RTThrower-")
		and player.get_main_inventory().find_item_stack(entity.ghost_prototype.name.."-Item")
		) then
			player.get_main_inventory().remove({name=entity.ghost_prototype.name.."-Item", count=1})
			entity.revive({raise_revive = true})
			return
		end
	elseif event.robot then
		player = event.robot.last_user
	end

	if trainHandler(entity, player) then
		return
	end

	if (string.find(entity.name, "RTThrower-")) then
		global.CatapultList[entity.unit_number] = {entity = entity, target = "nothing"}
		if (entity.name == "RTThrower-EjectorHatchRT") then
			global.CatapultList[entity.unit_number].sprite = rendering.draw_animation
				{
					animation = "EjectorHatchFrames",
					surface = entity.surface,
					target = entity,
					animation_offset = global.EjectorPointing[entity.direction],
					render_layer = 131,
					animation_speed = 0,
					only_in_alt_mode = false
				}
		end
	elseif (entity.name == "PlayerLauncher") then
		entity.operable = false
		entity.active = false

	elseif (string.find(entity.name, "BouncePlate") and not string.find(entity.name, "Train")) then
		global.BouncePadList[entity.unit_number] = {TheEntity = entity}
		if (entity.name == "DirectedBouncePlate") then
			entity.operable = false
			if (entity.orientation == 0) then
				direction = "UD"
				xflip = 1
				yflip = 1
			elseif (entity.orientation == 0.25) then
				direction = "RL"
				xflip = 1
				yflip = 1
			elseif (entity.orientation == 0.5) then
				direction = "UD"
				xflip = 1
				yflip = -1
			elseif (entity.orientation == 0.75) then
				direction = "RL"
				xflip = -1
				yflip = 1
			end
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "BouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "SignalBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0}
				}
		elseif (entity.name == "PrimerBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		elseif (entity.name == "PrimerSpreadBouncePlate") then
			global.BouncePadList[entity.unit_number].arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0}
				}
		end

	elseif (entity.name == "RTTrainRamp" or entity.name == "RTTrainRampNoSkip" or entity.name == "RTMagnetTrainRamp" or entity.name == "RTMagnetTrainRampNoSkip") then
		entity.rotatable = false
	end
end

return entity_built
