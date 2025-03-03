--platform	:: LuaSpacePlatform	
--old_state	:: defines.space_platform_state	
local function NineAndThreeQuarters(event)
    local platform = event.platform
    local fwoosh = false
    local verticallity
    local speed
    if (platform.state == defines.space_platform_state.on_the_path) then
        fwoosh = true
        verticallity = 100
        speed = 0.1
    --[[ elseif (event.old_state == defines.space_platform_state.on_the_path) then
        fwoosh = true
        verticallity = -100
        speed = 0.05 ]]
    end
    if (fwoosh) then
        local spills = platform.surface.find_entities_filtered({type="item-entity"})
        for _, item in pairs(spills) do
            local TargetX = item.position.x
            local TargetY = item.position.y + verticallity
            local distance = math.sqrt((TargetX-item.position.x)^2 + (TargetY-item.position.y)^2)
            local AirTime = math.max(1, math.floor(distance/speed))
            local vector = {x=math.random(-2, 2), y=verticallity}
            local path = {}
            for i = 0, AirTime do
                local progress = i/AirTime
                path[i] =
                {
                    x = item.position.x+(progress*vector.x),
                    y = item.position.y+(progress*vector.y),
                    height = 0
                }
            end
            CreateThrownItem({
                type = "CustomPath",
                ItemName = item.stack.name,
                count = 1,
                quality = "normal",
                start = item.position,
                target={x=TargetX, y=TargetY}, -- doesnt matter since its just floating off
                surface=platform.surface,
                space = true,
                path = path,
                spin = math.random(-10,10)*0.001,
                AirTime = AirTime,
            })
            item.destroy()
        end
    end
end

return NineAndThreeQuarters