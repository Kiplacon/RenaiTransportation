function AdjustThrowerArrow(thrower) -- applies any trajectory adjustments from remote interface
    if (thrower.valid) then
        local DestroyNumber = script.register_on_object_destroyed(thrower)
        local ThrowerProperties = storage.CatapultList[DestroyNumber]
        if (ThrowerProperties.entity.valid and ThrowerProperties.TrajectoryAdjust) then
            if (ThrowerProperties.TrajectoryAdjust.type == "target" and ThrowerProperties.TrajectoryAdjust.position) then
                thrower.drop_position = {ThrowerProperties.TrajectoryAdjust.position.x, ThrowerProperties.TrajectoryAdjust.position.y}
            elseif (ThrowerProperties.TrajectoryAdjust.type == "force" and ThrowerProperties.TrajectoryAdjust.vector) then
                local distance = DistanceBetween(thrower.position, thrower.drop_position)
                local speed = 0.18
                if (string.find(thrower.name, "Ejector")) then
                    speed = 0.25
                end
                thrower.drop_position =
                {
                    thrower.drop_position.x + (ThrowerProperties.TrajectoryAdjust.vector.x*((distance/speed)^2)/3600),
                    thrower.drop_position.y + (ThrowerProperties.TrajectoryAdjust.vector.y*((distance/speed)^2)/3600)
                }
            elseif (ThrowerProperties.TrajectoryAdjust.type == "path" and ThrowerProperties.TrajectoryAdjust.path) then
                thrower.drop_position = {ThrowerProperties.TrajectoryAdjust.path[#ThrowerProperties.TrajectoryAdjust.path].x, ThrowerProperties.TrajectoryAdjust.path[#ThrowerProperties.TrajectoryAdjust.path].y}
            elseif (ThrowerProperties.TrajectoryAdjust.type == "PathSet" and ThrowerProperties.TrajectoryAdjust.set) then
                local CurrentRange = storage.CatapultList[DestroyNumber].range
                if (ThrowerProperties.TrajectoryAdjust.set[CurrentRange]) then
                    thrower.drop_position = {ThrowerProperties.TrajectoryAdjust.set[CurrentRange][#ThrowerProperties.TrajectoryAdjust.set[CurrentRange]].x, ThrowerProperties.TrajectoryAdjust.set[CurrentRange][#ThrowerProperties.TrajectoryAdjust.set[CurrentRange]].y}
                else
                    -- no path defined for this range, so just do a normal arc
                    local range = ThrowerProperties.range
                    thrower.drop_position =
                    {
                        thrower.position.x - (range or RealMaxRange(thrower).x)*storage.OrientationUnitComponents[thrower.orientation].x,
                        thrower.position.y - (range or RealMaxRange(thrower).y)*storage.OrientationUnitComponents[thrower.orientation].y
                    }
                end
            elseif (ThrowerProperties.TrajectoryAdjust.type == "interface" and ThrowerProperties.TrajectoryAdjust.interface and ThrowerProperties.TrajectoryAdjust.name and ThrowerProperties.TrajectoryAdjust.parameters) then
                local distance = DistanceBetween(thrower.position, thrower.drop_position)
                local speed = 0.18
                if (string.find(thrower.name, "Ejector")) then
                    speed = 0.25
                end
                local AirTime = math.ceil(distance/speed)
                local call = remote.call(ThrowerProperties.TrajectoryAdjust.interface, ThrowerProperties.TrajectoryAdjust.name, ThrowerProperties.TrajectoryAdjust.parameters, AirTime, thrower)
                if (type(call) ~= "table") then
                    error("Remote interface call did not return a table. Check the notes in the script/remote.lua file for the formating.")
                end
                ThrowerProperties.TrajectoryAdjust.path = call

                --ThrowerProperties.TrajectoryAdjust.path = remote.call(ThrowerProperties.TrajectoryAdjust.interface, ThrowerProperties.TrajectoryAdjust.name, ThrowerProperties.TrajectoryAdjust.parameters, AirTime, thrower)
                --game.print(serpent.block(ThrowerProperties.TrajectoryAdjust.path[1]))
            end
        end
    end
end
function ClearTrajectoryAdjust(ThrowerInserter)
    if (ThrowerInserter.valid) then
        local DestroyNumber = script.register_on_object_destroyed(ThrowerInserter)
        if not storage.CatapultList[DestroyNumber] then
            return
        end --Not valid or doesnt exist
        local thrower = storage.CatapultList[DestroyNumber].entity
        local range = storage.CatapultList[DestroyNumber].range
        thrower.drop_position =
        {
            thrower.position.x - (range or RealMaxRange(ThrowerInserter).x)*storage.OrientationUnitComponents[thrower.orientation].x,
            thrower.position.y - (range or RealMaxRange(ThrowerInserter).y)*storage.OrientationUnitComponents[thrower.orientation].y
        }
        storage.CatapultList[DestroyNumber].TrajectoryAdjust = nil
    else
        return
    end
end
function SetTrajectoryAdjust(ThrowerInserter, adjustment)
    local DestroyNumber = script.register_on_object_destroyed(ThrowerInserter)
    if not storage.CatapultList[DestroyNumber] then
        return
    else
        -- Note: for all these adjustments if you have the thrower target a position behind itself then the arm will just stretch out to that position and drop the item there instead of throwing it.
        if (adjustment.type == "target" and adjustment.position and (adjustment.position.x and adjustment.position.y and type(adjustment.position.x) == "number" and type(adjustment.position.y) == "number"))
            -- the thrower will always throw at the given x,y map position. 
            -- example: adjustment={type="target", position={x=420, y=69}}
        or (adjustment.type == "force" and adjustment.vector and (adjustment.vector.x and adjustment.vector.y and type(adjustment.vector.x) == "number" and type(adjustment.vector.y) == "number"))
            -- acceleration vector in tiles per second^2. 
            -- example: adjustment={type="force", vector={x=2, y=5}}
        or (adjustment.type == "path" and adjustment.path and type(adjustment.path) == "table")
            -- a list of path points which are x and y map positions and a height. This path will be used no matter what the thrower's range setting is.
            -- example: adjustment={type="path", path={{x=0, y=0, height=0}, {x=0.11, y=0.1, height=0.05}, ...}}. Thrown item moves at one path point per tick. Height is in tiles. For refrence, teh Factorio API says elevated rails are height 3
        or (ThrowerInserter and adjustment.type == "PathSet" and adjustment.set and type(adjustment.set) == "table") -- only for thrower inserters cause they have range adjust
            -- a list of paths indexed by range setting, the paths can be different lengths. 
            -- If a path is not provided for a certain range setting, it will just be a normal throw at the typical target.
            -- example: 
            --[[ 
            adjustment=
            {
                type = "PathSet", 
                set = 
                {
                    [1]={{x=0, y=0, height=0}, {x=0.11, y=0.1, height=0.05}, ...}}, -- used for a range 1 throw
                    [2]={{x=0, y=0, height=0}, {x=0.15, y=0.1, height=0.05}, ...}}, -- used for a range 2 throw
                    ...,
                    [15]={{x=0, y=0, height=0}, {x=0.2, y=0.1, height=0.05}, ...}} -- used for a range 15 throw
                }
            } 
            ]]
        or (adjustment.type == "interface" and adjustment.interface and adjustment.name and adjustment.parameters)
            -- Ask the requesting mod's remote interface to send its own calculated path whenever a new one is needed. 
            -- example: adjustment={type="interface", interface="modname", name="functionname", parameters={param1, param2, ...}}. 
            -- The function must return a table of path points which are x and y map positions and a height, like in the "path" adjustment type.
            -- The call includes:
                -- the parameters table provided in the adjustment as the first parameter.
                -- the "unadjusted" air time of the throw in ticks as the second parameter for refrence. The path it doesn't necessarily have to be that long.
                -- the thrower entity as a third parameter in case the function needs to know something about the thrower at time of request.
        then
            storage.CatapultList[DestroyNumber].TrajectoryAdjust = adjustment
            AdjustThrowerArrow(ThrowerInserter)
            return true
        else
            error("Invalid adjustment settings. Check the notes in the script/remote.lua file for the formating.")
        end
    end
end

remote.add_interface("RenaiTransportation", {
    ---Read a custom trajectory
    ReadTrajectoryAdjust = function(ThrowerInserter)
        local DestroyNumber = script.register_on_object_destroyed(ThrowerInserter)
        if not storage.CatapultList[DestroyNumber] then
            return
        else
            if (storage.CatapultList[DestroyNumber].TrajectoryAdjust == nil) then
                return {}
            end
            return copy(storage.CatapultList[DestroyNumber].TrajectoryAdjust)
        end
    end,

    ---Tell Renai to no longer consider this inserter's unique trajectory, if it has one defined.
    ClearTrajectoryAdjust = function(ThrowerInserter)
        ClearTrajectoryAdjust(ThrowerInserter)
    end,

    -- Set a custom trajectory adjustment for the given thrower
    SetTrajectoryAdjust = function(ThrowerInserter, adjustment)
        SetTrajectoryAdjust(ThrowerInserter, adjustment)
    end,
})