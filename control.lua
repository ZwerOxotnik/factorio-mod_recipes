local recipe_multiplier = settings.startup["mod_recipes_multiplier"].value


local function adapt_multiplied_recipes()
	for _, force in pairs(game.forces) do
		local recipes = force.recipes
		for name, recipe in pairs(recipes) do
			local multiplied_recipe = recipes["x" .. recipe_multiplier .. "_" .. name]
			if multiplied_recipe then
				multiplied_recipe.enabled = recipe.enabled
			end
		end
	end
end


script.on_init(adapt_multiplied_recipes)
script.on_configuration_changed(adapt_multiplied_recipes)


script.on_event(defines.events.on_research_reversed, function(event)
	local effects = event.research.effects
	local force = event.research.force
	local recipes = force.recipes
	for i=1, #effects do
		local effect = effects[i]
		if effect.type == "unlock-recipe" then
				local recipe = recipes["x" .. recipe_multiplier .. "_" .. effect.recipe]
				if recipe then
					recipe.enabled = false
				end
		end
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	local effects = event.research.effects
	local force = event.research.force
	local recipes = force.recipes
	for i=1, #effects do
		local effect = effects[i]
		if effect.type == "unlock-recipe" then
				local recipe = recipes["x" .. recipe_multiplier .. "_" .. effect.recipe]
				if recipe then
					recipe.enabled = true
				end
		end
	end
end)
