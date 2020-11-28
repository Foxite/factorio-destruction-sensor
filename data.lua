local sensor = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
sensor.name = "destruction-sensor"
--sensor.icon = "__destructionsensor__/graphics/icons/destruction-sensor.png"
sensor.localised_name = {"entity-name.destruction-sensor"}
sensor.minable.result = sensor.name

local item = table.deepcopy(data.raw.item["constant-combinator"])
item.name = "destruction-sensor"
--item.icon = "__destructionsensor__/graphics/icons/destruction-sensor.png"
item.place_result = sensor.name
item.localised_name = sensor.localised_name

local recipe = table.deepcopy(data.raw.recipe["constant-combinator"])
recipe.name = sensor.name
recipe.result = sensor.name
recipe.localised_name = sensor.localised_name
table.insert(recipe.ingredients, {"advanced-circuit", 1})


data:extend({sensor, item, recipe})
table.insert(data.raw.technology["circuit-network"].effects, {type = "unlock-recipe", recipe = recipe.name})