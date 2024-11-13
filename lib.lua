
local mod_recipes_lib = {}


local items    = data.raw.item
local recipes  = data.raw.recipe
local armors   = data.raw.armor
local deepcopy = util.table.deepcopy
local speed_multiplier  = settings.startup["mod_recipes_speed_multiplier"].value
local recipe_multiplier = settings.startup["mod_recipes_multiplier"].value


---@return boolean # is multiplied?
local function _multiply_ingredients(ingredients)
	for _, ingredient in pairs(ingredients) do
		ingredient["amount"] = ingredient["amount"] * recipe_multiplier
		if ingredient["amount"] >= 65535 then return false end
		if ingredient["catalyst_amount"] then
			ingredient["catalyst_amount"] = ingredient["catalyst_amount"] * recipe_multiplier
		end
	end

	return true
end


---@return boolean # is multiplied?
mod_recipes_lib.multiply_ingredients = function(recipe)
	if recipe.ingredients then
		return _multiply_ingredients(recipe.ingredients)
	end

	return true
end
local multiply_ingredients = mod_recipes_lib.multiply_ingredients


mod_recipes_lib.multiply_results = function(recipe)
	if recipe.results then
		for _, result in ipairs(recipe.results) do
			result.amount = (result.amount * recipe_multiplier) or recipe_multiplier
		end
	end
end
multiply_results = mod_recipes_lib.multiply_results


---@return table? # new recipe
mod_recipes_lib.make_recipe = function(recipe_name)
	local original_recipe = recipes[recipe_name]
	if original_recipe == nil then return end
	local armor = armors[recipe_name]
	if armor then return end
	local item = items[recipe_name]
	if item and item.stack_size == 1 then return end

	local new_recipe = deepcopy(original_recipe)
	--new_recipe.category = "" -- maybe?

	if multiply_ingredients(new_recipe) == false then
		return
	end
	multiply_results(new_recipe)

	if new_recipe.energy_required then
		new_recipe.energy_required = recipe_multiplier * (original_recipe.energy_required or 0.5) / speed_multiplier
	end

	new_recipe.name = "x" .. recipe_multiplier .. "_" .. original_recipe.name
	new_recipe.localised_name = original_recipe.localised_name or "recipe-name." .. original_recipe.name
	data:extend({new_recipe})

	return new_recipe
end


return mod_recipes_lib
