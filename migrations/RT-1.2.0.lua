for each, FlyingItem in pairs(global.FlyingItems) do
    if (FlyingItem.sprite) then -- from impact unloader
        rendering.destroy(FlyingItem.sprite)
    end
    if (FlyingItem.shadow) then -- from impact unloader
        rendering.destroy(FlyingItem.shadow)
    end
    if (FlyingItem.tracing == nil and FlyingItem.destination ~= nil and global.OnTheWay[FlyingItem.destination]) then
        global.OnTheWay[FlyingItem.destination][FlyingItem.item] = global.OnTheWay[FlyingItem.destination][FlyingItem.item] - FlyingItem.amount
    end
end
global.FlyingItems = {}

for each, properties in pairs(global.CatapultList) do
    local entity = properties.entity

    properties.BurnerSelfRefuelCompensation=0.2
    properties.IsElectric=false
    properties.InSpace=false

    if (string.find(entity.surface.name, " Orbit") or string.find(entity.surface.name, " Field") or string.find(entity.surface.name, " Belt")) then
        properties.InSpace = true
    end

    if (entity.burner == nil and #entity.fluidbox == 0) then
        properties.BurnerSelfRefuelCompensation = 0
        properties.IsElectric = true
    elseif (entity.name == "RTThrower-PrimerThrower") then
        properties.BurnerSelfRefuelCompensation = -0.1
    end
end