-- utility
function copy(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    -- don't copy factorio rich objects
    elseif object.__self then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end

function DistanceBetween(p1, p2)
   return math.sqrt((p1.x-p2.x)^2+(p1.y-p2.y)^2)
end

function GetPlanningID(thing)
   local ID = thing
   if (thing.object_name == "LuaEntity") then
      thing = thing.unit_number or thing.position.x..thing.surface.name..thing.position.y
   end
   return thing
end

function GetOrRegisterPlayerProperties(player)
   if (global.AllPlayers[player.index] == nil) then
      global.AllPlayers[player.index] = {player=player, action="none", variables={}}
   end
   return global.AllPlayers[player.index]
end

function CloseGUIs(player)
   global.AllPlayers[player.index].CloseGUIs = "yesplz"
end

function SwapToGUI(player, thing)
   global.AllPlayers[player.index].SwapToGUI = thing
end

function GetOrRegisterClearOnDestroyList(entity)
   script.register_on_entity_destroyed(entity)
   if (global.TrackingLists.ClearOnDestroy[entity.unit_number] == nil) then
      global.TrackingLists.ClearOnDestroy[entity.unit_number] = {}
   end
   return global.TrackingLists.ClearOnDestroy[entity.unit_number]
end

function GetOrRegisterItemReservationTracker(entity)
   if (global.reservations.items[entity.unit_number] == nil) then
      global.reservations.items[entity.unit_number] = {taking={}, bringing={}}
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="GlobalItemReservation", number=entity.unit_number})
   end
   return global.reservations.items[entity.unit_number]
end
function GetOrRegisterEntityReservationTracker(entity)
   if (global.reservations.entities[entity.unit_number] == nil) then
      global.reservations.entities[entity.unit_number] = {}
      table.insert(GetOrRegisterClearOnDestroyList(entity), {type="GlobalEntityReservation", number=entity.unit_number})
   end
   return global.reservations.entities[entity.unit_number]
end

function CanInsertConsideringReservations(entity, item)
   if (global.reservations[entity.unit_number]) then
      
   end
return true
end
