local Constants = {}

Constants.ground = 420
Constants.elevated = 69

-- How much we shift the placer position (in tiles) to get
-- the position of the ramp entity based on the placer's direction
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north] = {  1.5, 0 } -- actually down
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]  = {  0, 1.5 } -- actually left
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south] = { -1.5,  0 } -- actually up
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]  = { 0, -1.5 } -- actually right

-- Same as above but keyed by orientation
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.25] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.50] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.75] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]

return Constants
