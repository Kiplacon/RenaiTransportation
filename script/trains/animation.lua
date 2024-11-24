local Animation = {}

function Animation.updateRendering(properties)
	local gravity = 1/250 -- Approximately (9.8 m/s^2) from a 45 degree perspective, expressed in (m / tick^2). Affects arc "height", not air time or jump length

	if (properties.MagnetComp ~= nil) then
		--if (properties.MagnetComp >= 0) then
			gravity = 2 / ((0.08 * properties.AirTime ^ 2) - (0.5 * properties.AirTime) + 11)

			--SpinMagnitude = 0.05*properties.MagnetComp
		if (properties.MagnetComp < 0) then
			--gravity = -30*properties.MagnetComp
			--SpinSpeed = 19
			--SpinMagnitude = 0.025
		end
	end

	------------- animating -----------

	local elapsed = game.tick - properties.LaunchTick;
	local initialVerticalVelocity = -0.5 * (gravity * properties.AirTime) -- v_0 = -(1/2) * (a * t)
	local height = (initialVerticalVelocity * elapsed) + (0.5 * gravity * (elapsed ^ 2)) -- x = (v_0 * t) + (1/2) * a * t^2
	local VertialSpeed = initialVerticalVelocity + gravity*elapsed

	Animation.updateOffsets(properties, height - (properties.elevated or 0), elapsed)
	Animation.updateScale(properties, height - (properties.elevated or 0))
	Animation.updateRotation(properties, elapsed, height)
	return -height +(properties.elevated or 0) , -VertialSpeed
end

function Animation.updateOffsets(properties, height, elapsed)
	-- Adjust offset of rendered sprites
	if (properties.shift) then
		local completedPercent = (game.tick-properties.ElevatedLandingStart) / (properties.LandTick-properties.ElevatedLandingStart)
		height = -properties.shift + ((properties.shift-3)*completedPercent)
	end
	properties.TrainImageID.target = {entity=properties.GuideCar, offset={0, height}}
	properties.MaskID.target = {entity=properties.GuideCar, offset={0, height}}
	properties.ShadowID.target = {entity=properties.GuideCar, offset={1-height, 0.5}}
end

function Animation.updateRotation(properties, elapsed, height)
	--y=0.05\cdot\left(\left(2x-1\right)^{23}-\left(2x-1\right)\right)
	local SpinMagnitude = properties.SpinMagnitude or 0.05
	local SpinSpeed = properties.SpinSpeed or 23
	local test = properties.test or 2

	local completedPercent = elapsed / properties.AirTime
	--game.print(completedPercent)
	local spinPercent = (test * completedPercent) - 1 -- double the rotation arc and center it on 0, aka upright
	local spinScale = (spinPercent ^ SpinSpeed) - spinPercent
	local spinAmount = SpinMagnitude * spinScale

	if (properties.RampOrientation == 0.75 or properties.RampOrientation == 0) then
		-- Going right or down, reverse spin
		spinAmount = -spinAmount
	end

	if (properties.RampOrientation == 0 or properties.RampOrientation == 0.50) then
		-- going down or up, spin the shadows
		-- Spin amount plus 0.5 so the shadows orient north/south
		--properties.TrainImageID.orientation = -0.25
		--properties.MaskID.orientation = -0.25
		if (properties.elevated and completedPercent > 0.93) then
			spinAmount = properties.ShadowID.orientation
		end
		properties.ShadowID.orientation = spinAmount
	else
		-- going left or right, spin the cars
		if (properties.elevated and completedPercent > 0.93) then
			spinAmount = properties.TrainImageID.orientation
		end
		properties.TrainImageID.orientation = spinAmount
		properties.MaskID.orientation = spinAmount
	end
	--game.print(completedPercent.."   "..spinAmount)
end

function Animation.updateScale(properties, height)

	if (properties.RampOrientation == 0 or properties.RampOrientation == 0.50) then
		-- Going down or up, scale train to make it pop out
		local scaleDelta = math.abs(height) * 0.05
		local scale = scaleDelta + 1
		properties.TrainImageID.x_scale = scale
		properties.TrainImageID.y_scale = scale
		properties.MaskID.x_scale = scale
		properties.MaskID.y_scale = scale
	else
		properties.TrainImageID.x_scale = 1
		properties.TrainImageID.y_scale = 1
		properties.MaskID.x_scale = 1
		properties.MaskID.y_scale = 1
	end

	-- Scale shadow height differently to maintain perspective
	local shadowScaleDelta = math.abs(height) * 0.025

	properties.ShadowID.x_scale = 0.25 + shadowScaleDelta
	properties.ShadowID.y_scale = 0.5 + shadowScaleDelta
	properties.ShadowID.color = {1, 1, 1, 2.5/(5-height)}
	--rendering.set_color(properties.ShadowID, {1, 1, 1, math.abs(90 - 4*math.abs(math.ceil(height)))}) -- old
end

return Animation