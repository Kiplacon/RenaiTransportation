if (storage.FlyingItems) then
	for each, FlyingItem in pairs(storage.FlyingItems) do
		if (FlyingItem.sprite) then -- from impact unloader/space throw
			if (type(FlyingItem.sprite) == "number" and rendering.get_object_by_id(FlyingItem.sprite) ~= nil) then
				rendering.get_object_by_id(FlyingItem.sprite).destroy()
			else
				FlyingItem.sprite.destroy()
			end
		end
		if (FlyingItem.shadow) then -- from impact unloader/space throw
			if (type(FlyingItem.shadow) == "number" and rendering.get_object_by_id(FlyingItem.shadow) ~= nil) then
				rendering.get_object_by_id(FlyingItem.shadow).destroy()
			else
				FlyingItem.shadow.destroy()
			end
		end
	end
	storage.FlyingItems = {}
end

if (storage.CatapultList) then
	if (storage.ThrowerProcessing == nil) then
		local ProcessingGroups = 3
		storage.ThrowerProcessing = {}
		for i = 1, ProcessingGroups do
			storage.ThrowerProcessing[i] = {}
		end
		local group = 1
		for ThrowerDestroyNumber, properties in pairs(storage.CatapultList) do
			storage.ThrowerProcessing[group][ThrowerDestroyNumber] = properties
			group = group + 1
			if (group > ProcessingGroups) then
				group = 1
			end
		end
	end
end

if (storage.MagnetRamps) then
	storage.MagnetRamps = nil
end
if (storage.TrainRamps == nil) then
	storage.TrainRamps = {}
end
if (storage.TrainCollisionDetectors == nil) then
	storage.TrainCollisionDetectors = {}
end

local math2d = require('math2d')

for _, RampName in pairs({"RTTrainRamp", "RTTrainRampNoSkip", "RTImpactUnloader"}) do
	local RampType = "TrainRamp"
	if (RampName == "RTImpactUnloader") then
		RampType = "ImpactUnloader"
	end
	for _, surface in pairs(game.surfaces) do
		local ramps = surface.find_entities_filtered
		{
			name = RampName
		}
		for _, ramp in pairs(ramps) do
			local NewRamp = surface.create_entity({
				name = ramp.name,
				position = math2d.position.add(ramp.position, {-0.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ramp.direction][1], -0.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[ramp.direction][2]}),
				direction = ramp.direction,
				force = ramp.force,
				raise_built = true,
				--player = ramp.player,
				rail_layer = ramp.rail_layer
			})
			RampSetup(NewRamp, RampType)
			ramp.destroy()
		end
	end
end
for _, irection in pairs({{"Up", defines.direction.south}, {"Down", defines.direction.north}, {"Left", defines.direction.east}, {"Right", defines.direction.west}}) do
	for _, varient in pairs({"", "NoSkip"}) do
		for _, surface in pairs(game.surfaces) do
			local ramps = surface.find_entities_filtered
			{
				name = "RTTrainRamp-Elevated"..irection[1]..varient
			}
			for _, ramp in pairs(ramps) do
				ramp.teleport(math2d.position.add(ramp.position, {-0.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[irection[2]][1], -0.5*TrainConstants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[irection[2]][2]}))
				local NewRamp = surface.create_entity
				{
					name = "RTTrainRamp"..varient,
					position = ramp.position,
					direction = irection[2],
					rail_layer = defines.rail_layer.elevated,
					force = ramp.force,
				}
				RampSetup(NewRamp, "TrainRamp")
				ramp.destroy()
			end
		end
	end
end

local ShowRange = settings.global["RTShowRange"].value
-- normal bounce pads
for _, surface in pairs(game.surfaces) do
	local bofa = surface.find_entities_filtered
	{
		name = "RTBouncePlate"
	}
	for _, deez in pairs(bofa) do
		storage.BouncePadList[script.register_on_object_destroyed(deez)] = {entity=deez}
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(deez)]
		PouncePadProperties.arrow = rendering.draw_sprite
		{
			sprite = "RTRangeOverlay",
			surface = surface,
			target = deez,
			only_in_alt_mode = true,
			tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
			visible = ShowRange
		}
		PouncePadProperties.ShowArrow = ShowRange
		deez.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=10})
	end
end
for _, variant in pairs({5, 15}) do
	for _, surface in pairs(game.surfaces) do
		local sugondese = surface.find_entities_filtered
		{
			name = "BouncePlate"..variant
		}
		for _, BouncePad in pairs(sugondese) do
			local TheSpot = BouncePad.position
			local UseThe = BouncePad.force
			BouncePad.destroy()
			local NewKid = surface.create_entity
			{
				name = "RTBouncePlate",
				position = TheSpot,
				force = UseThe
			}
			if (NewKid) then
				storage.BouncePadList[script.register_on_object_destroyed(NewKid)] = {entity=NewKid}
				local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(NewKid)]
				PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = surface,
					target = NewKid,
					x_scale = variant/10,
					y_scale = variant/10,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
				PouncePadProperties.ShowArrow = ShowRange
				NewKid.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=variant})
			end
		end
	end
end
-- directed
for _, surface in pairs(game.surfaces) do
	local bofa = surface.find_entities_filtered
	{
		name = "DirectedBouncePlate"
	}
	for _, deez in pairs(bofa) do
		storage.BouncePadList[script.register_on_object_destroyed(deez)] = {entity=deez}
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(deez)]
		if (deez.orientation == 0) then
			direction = "UD"
			xflip = 1
			yflip = 1
		elseif (deez.orientation == 0.25) then
			direction = "RL"
			xflip = 1
			yflip = 1
		elseif (deez.orientation == 0.5) then
			direction = "UD"
			xflip = 1
			yflip = -1
		elseif (deez.orientation == 0.75) then
			direction = "RL"
			xflip = -1
			yflip = 1
		end
		PouncePadProperties.arrow = rendering.draw_sprite
			{
				sprite = "RTDirectedRangeOverlay"..direction,
				surface = deez.surface,
				target = deez,
				only_in_alt_mode = true,
				x_scale = xflip,
				y_scale = yflip,
				tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
				visible = ShowRange
			}
		PouncePadProperties.ShowArrow = ShowRange
		deez.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=10})
	end
end
for _, variant in pairs({5, 15}) do
	for _, surface in pairs(game.surfaces) do
		local sugondese = surface.find_entities_filtered
		{
			name = "DirectedBouncePlate"..variant
		}
		for _, BouncePad in pairs(sugondese) do
			local TheSpot = BouncePad.position
			local UseThe = BouncePad.force
			local direct = BouncePad.direction
			BouncePad.destroy()
			local NewKid = surface.create_entity
			{
				name = "DirectedBouncePlate",
				position = TheSpot,
				force = UseThe,
				direction = direct
			}
			if (NewKid) then
				storage.BouncePadList[script.register_on_object_destroyed(NewKid)] = {entity=NewKid}
				local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(NewKid)]
				if (NewKid.orientation == 0) then
					direction = "UD"
					xflip = 1
					yflip = 1
				elseif (NewKid.orientation == 0.25) then
					direction = "RL"
					xflip = 1
					yflip = 1
				elseif (NewKid.orientation == 0.5) then
					direction = "UD"
					xflip = 1
					yflip = -1
				elseif (NewKid.orientation == 0.75) then
					direction = "RL"
					xflip = -1
					yflip = 1
				end
				PouncePadProperties.arrow = rendering.draw_sprite
					{
						sprite = "RTDirectedRangeOverlay"..direction,
						surface = surface,
						target = NewKid,
						only_in_alt_mode = true,
						x_scale = xflip*variant/10,
						y_scale = yflip*variant/10,
						tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
						visible = ShowRange
					}
				PouncePadProperties.ShowArrow = ShowRange
				NewKid.get_or_create_control_behavior().get_section(1).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=variant})
			end
		end
	end
end
-- other ones with arrows
for _, surface in pairs(game.surfaces) do
	local bofa = surface.find_entities_filtered
	{
		name = {"DirectorBouncePlate", "PrimerBouncePlate", "PrimerSpreadBouncePlate"}
	}
	for _, deez in pairs(bofa) do
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(deez)]
		PouncePadProperties.ShowArrow = PouncePadProperties.arrow.visible
		if (deez.name == "DirectorBouncePlate") then
			deez.get_or_create_control_behavior().add_section()
			deez.get_or_create_control_behavior().get_section(5).set_slot(1, {value={type="virtual", name="signal-R", quality="normal"}, min=10})
		end
	end
end
