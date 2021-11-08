zk_SPD.create_container("important-no-cheat-recipes")
zk_SPD.assign_performer("mod_recipes")

mod_recipes_lib = require("lib")

zk_SPD.add_function("important-no-cheat-recipes", mod_recipes_lib.make_recipe, "mod_recipes_lib.make_recipe")
