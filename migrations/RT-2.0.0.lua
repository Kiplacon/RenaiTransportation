if (settings.startup["RTThrowersSetting"].value == true and storage.CatapultList) then
	-- record all throwers then clear the list
	local throwers = {}
	for ID, stuff in pairs(storage.CatapultList) do
		if (stuff.entity and stuff.entity.valid) then
			table.insert(throwers, stuff.entity)
		end
		if (stuff.sprite) then
			if (type(stuff.sprite) == "number" and rendering.get_object_by_id(stuff.sprite) ~= nil) then
				rendering.get_object_by_id(stuff.sprite).destroy()
			else
				stuff.sprite.destroy()
			end
		end
		if (stuff.entangled) then
			for each, entity in pairs(stuff.entangled) do
				entity.destructible = true
				entity.destroy{}
			end
		end
	end
	storage.CatapultList = {}
	storage.PrimerThrowerLinks = {}
	-- rebuild the list
	for each, entity in pairs(throwers) do
		local OnDestroyNumber = script.register_on_object_destroyed(entity)
		storage.CatapultList[OnDestroyNumber] = {entity=entity, targets={}, BurnerSelfRefuelCompensation=0.2, IsElectric=false, InSpace=false, RangeAdjustable=false}
		local properties = storage.CatapultList[OnDestroyNumber]

		if (string.find(entity.name, "RTThrower-") and entity.name ~= "RTThrower-PrimerThrower" and entity.force.technologies["RTFocusedFlinging"].researched == true) then
			properties.RangeAdjustable = true
		end

		if (entity.surface.platform or string.find(entity.surface.name, " Orbit") or string.find(entity.surface.name, " Field") or string.find(entity.surface.name, " Belt")) then
			properties.InSpace = true
		end

		if (entity.burner == nil and #entity.fluidbox == 0 and entity.electric_buffer_size ~= nil and entity.electric_buffer_size > 0) then
			properties.BurnerSelfRefuelCompensation = 0
			properties.IsElectric = true
		elseif (entity.name == "RTThrower-PrimerThrower") then
			properties.BurnerSelfRefuelCompensation = -0.1
		end

		if (entity.name == "RTThrower-EjectorHatchRT") then
			storage.CatapultList[OnDestroyNumber].sprite = rendering.draw_animation
				{
					animation = "EjectorHatchFrames",
					surface = entity.surface,
					target = entity,
					animation_offset = storage.EjectorPointing[entity.direction],
					render_layer = 131,
					animation_speed = 0,
					only_in_alt_mode = false
				}
		elseif (entity.name == "RTThrower-FilterEjectorHatchRT") then
			storage.CatapultList[OnDestroyNumber].sprite = rendering.draw_animation
				{
					animation = "FilterEjectorHatchFrames",
					surface = entity.surface,
					target = entity,
					animation_offset = storage.EjectorPointing[entity.direction],
					render_layer = 131,
					animation_speed = 0,
					only_in_alt_mode = false
				}
		elseif (entity.name == "RTThrower-PrimerThrower") then
			entity.inserter_stack_size_override = 1
			local sherlock = entity.surface.create_entity
			{
				name = "RTPrimerThrowerDetector",
				position = entity.position,
				direction = storage.PrimerThrowerPointing[entity.direction],
				force = entity.force,
				create_build_effect_smoke = false
			}
			sherlock.destructible = false
			storage.CatapultList[OnDestroyNumber].entangled = {}
			storage.CatapultList[OnDestroyNumber].entangled.detector = sherlock
			local OnDestroyNumber2 = script.register_on_object_destroyed(sherlock)
			storage.PrimerThrowerLinks[OnDestroyNumber2] = {thrower = entity, ready = false}--, box = box}
		end
	end
end

if (storage.HoverGFX) then
	storage.HoverGFX = {}
end

if (settings.startup["RTThrowersSetting"].value == true and storage.BouncePadList) then
	-- record all bounce pads then clear the list
	local pads = {}
	for ID, stuff in pairs(storage.BouncePadList) do
		if (stuff.TheEntity and stuff.TheEntity.valid) then
			table.insert(pads, stuff.TheEntity)
		end
		if (stuff.entity and stuff.entity.valid) then
			table.insert(pads, stuff.entity)
		end
		if (stuff.arrow) then
			if (type(stuff.arrow) == "number") then
				if (rendering.get_object_by_id(stuff.arrow) ~= nil) then
					rendering.get_object_by_id(stuff.arrow).destroy()
				end
			else
				stuff.arrow.destroy()
			end
		end
	end
	storage.BouncePadList = {}

	for each, entity in pairs(pads) do
		entity.rotatable = true
		entity.operable = true
		storage.BouncePadList[script.register_on_object_destroyed(entity)] = {entity = entity}
		local PouncePadProperties = storage.BouncePadList[script.register_on_object_destroyed(entity)]
		local ShowRange = settings.global["RTShowRange"].value
		if (entity.name == "DirectedBouncePlate"
		or entity.name == "DirectedBouncePlate5"
		or entity.name == "DirectedBouncePlate15") then
			--entity.operable = false
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
			if (entity.name == "DirectedBouncePlate5") then
				xflip = xflip*0.5
				yflip = yflip*0.5
			elseif (entity.name == "DirectedBouncePlate15") then
				xflip = xflip*1.5
				yflip = yflip*1.5
			end
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTDirectedRangeOverlay"..direction,
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = xflip,
					y_scale = yflip,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}
		elseif (entity.name == "RTBouncePlate"
		or entity.name == "BouncePlate5"
		or entity.name == "BouncePlate15"
		or entity.name == "SignalBouncePlate"
		or entity.name == "DirectorBouncePlate") then
			local xs = 1
			local ys = 1
			if (entity.name == "BouncePlate5") then
				xs = 0.5
				ys = 0.5
			elseif (entity.name == "BouncePlate15") then
				xs = 1.5
				ys = 1.5
			end
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTRangeOverlay",
					surface = entity.surface,
					target = entity,
					x_scale = xs,
					y_scale = ys,
					only_in_alt_mode = true,
					tint = {r = 0.4, g = 0.4, b = 0.4, a = 0},
					visible = ShowRange
				}

		elseif (entity.name == "PrimerBouncePlate") then
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0},
					visible = ShowRange
				}
		elseif (entity.name == "PrimerSpreadBouncePlate") then
			PouncePadProperties.arrow = rendering.draw_sprite
				{
					sprite = "RTPrimerSpreadRangeOverlay",
					surface = entity.surface,
					target = entity,
					only_in_alt_mode = true,
					x_scale = 4,
					y_scale = 4,
					tint = {r = 0.2, g = 0.2, b = 0.2, a = 0},
					visible = ShowRange
				}
		end
	end
end

if (storage.ThrowerPaths) then
	storage.ThrowerPaths = {}
end

if (storage.OnTheWay) then
	storage.OnTheWay = {}
end

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

if (settings.startup["RTZiplineSetting"].value == true and storage.ZiplineTerminals) then
	-- record all bounce pads then clear the list
	local terminals = {}
	for ID, stuff in pairs(storage.ZiplineTerminals) do
		if (stuff.entity and stuff.entity.valid) then
			terminals[script.register_on_object_destroyed(stuff.entity)] = storage.ZiplineTerminals[ID]
		end
	end
	storage.ZiplineTerminals = {}
	storage.ZiplineTerminals = terminals
end

if (settings.startup["RTTrainRampSetting"].value == true and storage.MagnetRamps) then
	-- record all bounce pads then clear the list
	local ramps = {}
	for ID, stuff in pairs(storage.MagnetRamps) do
		if (stuff.entity and stuff.entity.valid) then
			ramps[script.register_on_object_destroyed(stuff.entity)] = storage.MagnetRamps[ID]
		end
	end
	storage.MagnetRamps = {}
	storage.MagnetRamps = ramps
end
