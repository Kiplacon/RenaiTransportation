local Constants = {}

Constants.ground = 420
Constants.elevated = 69

-- How much we shift the placer position (in tiles) to get
-- the position of the ramp entity based on the placer's direction
Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION = {
    [defines.direction.north]           = {math.cos(0*math.pi/8), math.sin(0*math.pi/8)}, -- actually train-driving down
    [defines.direction.northnortheast]  = {math.cos(1*math.pi/8), math.sin(1*math.pi/8)},
    [defines.direction.northeast]       = {math.cos(2*math.pi/8), math.sin(2*math.pi/8)},
    [defines.direction.eastnortheast]   = {math.cos(3*math.pi/8), math.sin(3*math.pi/8)},
    [defines.direction.east]            = {math.cos(4*math.pi/8), math.sin(4*math.pi/8)}, -- actually left
    [defines.direction.eastsoutheast]   = {math.cos(5*math.pi/8), math.sin(5*math.pi/8)},
    [defines.direction.southeast]       = {math.cos(6*math.pi/8), math.sin(6*math.pi/8)},
    [defines.direction.southsoutheast]  = {math.cos(7*math.pi/8), math.sin(7*math.pi/8)},
    [defines.direction.south]           = {math.cos(8*math.pi/8), math.sin(8*math.pi/8)}, -- actually up
    [defines.direction.southsouthwest]  = {math.cos(9*math.pi/8), math.sin(9*math.pi/8)},
    [defines.direction.southwest]       = {math.cos(10*math.pi/8), math.sin(10*math.pi/8)},
    [defines.direction.westsouthwest]   = {math.cos(11*math.pi/8), math.sin(11*math.pi/8)},
    [defines.direction.west]            = {math.cos(12*math.pi/8), math.sin(12*math.pi/8)}, -- actually right
    [defines.direction.westnorthwest]   = {math.cos(13*math.pi/8), math.sin(13*math.pi/8)},
    [defines.direction.northwest]       = {math.cos(14*math.pi/8), math.sin(14*math.pi/8)},
    [defines.direction.northnorthwest]  = {math.cos(15*math.pi/8), math.sin(15*math.pi/8)},
}
-- Same as above but keyed by orientation
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION = {}
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.north]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.25] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.east]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.50] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.south]
Constants.PLACER_TO_RAMP_SHIFT_BY_ORIENTATION[0.75] = Constants.PLACER_TO_RAMP_SHIFT_BY_DIRECTION[defines.direction.west]

return Constants
