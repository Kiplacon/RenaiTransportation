if (settings.startup["RTTrapdoorSetting"].value == true) then
	for _, surface in pairs(game.surfaces) do
		local switches = surface.find_entities_filtered
		{
			name = "RTTrapdoorSwitch"
		}
		for _, switch in pairs(switches) do
			local TriggerDestroyNumber = script.register_on_object_destroyed(switch)
			if (storage.DestructionLinks[TriggerDestroyNumber] == nil) then
				storage.DestructionLinks[TriggerDestroyNumber] = {}
			end
			if (switch.rail_layer == defines.rail_layer.ground) then
				local detector = switch.surface.create_entity
				{
					name = "RTTrainDetector",
					position = switch.position,
					force = "neutral", -- makes it deal collision damage even if friendly fire is off
					create_build_effect_smoke = false,
					raise_built = true
				}
			elseif (switch.rail_layer == defines.rail_layer.elevated) then
				local detector = switch.surface.create_entity
				{
					name = "RTTrainDetectorElevated",
					position = switch.position,
					force = "neutral", -- makes it deal collision damage even if friendly fire is off
					create_build_effect_smoke = false,
					raise_built = true
				}
			end
		end
	end
end