local Animation = {}

function Animation.updateRendering(properties)
	local SpinMagnitude = 0.05
	local SpinSpeed = 23
	local gravity = 1/250 -- Approximately (9.8 m/s^2) from a 45 degree perspective, expressed in (m / tick^2). Affects arc "height", not air time or jump length

	if (properties.MagnetComp ~= nil) then
		--if (properties.MagnetComp >= 0) then
			gravity = ((0.08 * properties.AirTime ^ 2) - (0.5 * properties.AirTime) + 11) / 125000

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

	-- Adjust offset of rendered sprites
	rendering.set_target(properties.TrainImageID, properties.GuideCar, {0, height})
	rendering.set_target(properties.MaskID, properties.GuideCar, {0, height})
	rendering.set_target(properties.ShadowID, properties.GuideCar, {-height + 1, 0.5})

	-- Going left or right, spin the car
	local completedPercent = elapsed / properties.AirTime
	local spinPercent = (2 * completedPercent) - 1 -- double the rotation arc and center it on 0, aka upright
	local spinScale = (spinPercent ^ SpinSpeed) - spinPercent
	local spinAmount = SpinMagnitude * spinScale

	if (properties.RampOrientation == 0.75 or properties.RampOrientation == 0) then
		-- Going right or down, reverse spin
		spinAmount = -spinAmount
	end

	if (properties.RampOrientation == 0 or properties.RampOrientation == 0.50) then
		-- Going down or up, zoom the car
		local scaleDelta = math.abs(height) * 0.05
		local scale = scaleDelta + 0.5
		rendering.set_x_scale(properties.TrainImageID, scale)
		rendering.set_y_scale(properties.TrainImageID, scale)
		rendering.set_x_scale(properties.MaskID, scale)
		rendering.set_y_scale(properties.MaskID, scale)
		
		-- make the shadow smaller with height
		local shadowScaleDelta = math.abs(height) * 0.025
		rendering.set_x_scale(properties.ShadowID, 0.25 - shadowScaleDelta)
		rendering.set_y_scale(properties.ShadowID, 0.5 - scaleDelta)

		rendering.set_orientation(properties.ShadowID, spinAmount + 0.5)
	end
	if (properties.RampOrientation == 0.25 or properties.RampOrientation == 0.75) then
		rendering.set_orientation(properties.TrainImageID, spinAmount)
		rendering.set_orientation(properties.MaskID, spinAmount)
	end
end

return Animation
