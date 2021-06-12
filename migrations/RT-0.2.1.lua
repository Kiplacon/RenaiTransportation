for _, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()

  -- create tech/recipe table once
  local techs = force.technologies
  local recipes = force.recipes

  if (techs["military-2"].researched and recipes["PrimerBouncePlateRecipie"]) then
    recipes["PrimerBouncePlateRecipie"].enabled = true
  end  
  
  if (techs["circuit-network"].researched and recipes["SignalBouncePlateRecipie"]) then
    recipes["SignalBouncePlateRecipie"].enabled = true
  end   
end