
local mod_recipes_lib = {}

local data_raw = data.raw
local items = data_raw.item
local recipes = data_raw.recipe
local armors = data_raw.armor
local deepcopy = util.table.deepcopy
local speed_multiplier = settings.startup["mod_recipes_speed_multiplier"].value
local recipe_multiplier = settings.startup["mod_recipes_multiplier"].value

---@return boolean # is multiplied?
local function _multiply_ingredients(ingredients)
	for i=1, #ingredients do
		local ingredient = ingredients[i]
		if ingredient[2] then
			ingredient[2] = ingredient[2] * recipe_multiplier
			if ingredient[2] >= 65535 then return false end
		else
			ingredient["amount"] = ingredient["amount"] * recipe_multiplier
			if ingredient["amount"] >= 65535 then return false end
			if ingredient["catalyst_amount"] then
				ingredient["catalyst_amount"] = ingredient["catalyst_amount"] * recipe_multiplier
			end
		end
	end

	return true
end

---@return boolean # is multiplied?
mod_recipes_lib.multiply_ingredients = function(recipe)
	if recipe.ingredients then
		return _multiply_ingredients(recipe.ingredients)
	end

	local normal = recipe.normal
	local expensive = recipe.expensive
	if normal then
		if _multiply_ingredients(normal.ingredients) == false then
			return false
		end
	end
	if expensive then
		if _multiply_ingredients(expensive.ingredients) == false then
			return false
		end
	end

	return true
end
local multiply_ingredients = mod_recipes_lib.multiply_ingredients

mod_recipes_lib.multiply_results = function(recipe)
	local is_changed = false
	local normal = recipe.normal
	local expensive = recipe.expensive
	if normal and normal.result then
		is_changed = true
		local count = normal.result_count
		normal.result_count = (count and count * recipe_multiplier) or recipe_multiplier
	end
	if expensive and expensive.result then
		is_changed = true
		local count = expensive.result_count
		expensive.result_count = (count and count * recipe_multiplier) or recipe_multiplier
	end

	if is_changed == false then
		local count = recipe.result_count
		recipe.result_count = (count and count * recipe_multiplier) or recipe_multiplier
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

	local is_changed_energy_required = false
	local normal = new_recipe.normal
	local expensive = new_recipe.expensive
	if normal and normal.energy_required then
		is_changed_energy_required= true
		normal.energy_required = recipe_multiplier * normal.energy_required / speed_multiplier
	end
	if expensive and expensive.energy_required then
		is_changed_energy_required = true
		expensive.energy_required = recipe_multiplier * expensive.energy_required / speed_multiplier
	end
	if new_recipe.energy_required or is_changed_energy_required == false then
		new_recipe.energy_required = recipe_multiplier * (original_recipe.energy_required or 0.5) / speed_multiplier
	end

	new_recipe.name = "x" .. recipe_multiplier .. "_" .. original_recipe.name
	data:extend({new_recipe})

	return new_recipe
end

return mod_recipes_lib
