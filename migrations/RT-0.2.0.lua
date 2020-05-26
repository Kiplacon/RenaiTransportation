for _, force in pairs(game.forces) do
  force.reset_recipes()
  force.reset_technologies()

  -- create tech/recipe table once
  local techs = force.technologies
  local recipes = force.recipes
  if techs["fast-inserter"].researched then
    recipes["FastThrowerInserterRecipie"].enabled = true
	recipes["FilterThrowerInserterRecipie"].enabled = true
  end
  
  if techs["automation"].researched then
    recipes["LongHandedThrowerInserterRecipie"].enabled = true
  end
  
  if techs["stack-inserter"].researched then
    recipes["StackThrowerInserterRecipie"].enabled = true
	recipes["StackFilterThrowerInserterRecipie"].enabled = true
  end  
 
end