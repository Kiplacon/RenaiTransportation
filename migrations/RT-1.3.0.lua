for each, force in pairs(game.forces) do
    if (force.technologies["EjectorHatchRTTech"].researched == true) then
        force.recipes["RTThrower-FilterEjectorHatchRTRecipe"].enabled = true
    end
end