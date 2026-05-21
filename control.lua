local linked_chest_tech_name = "sanchei-linked-chest-and-pipe"
local old_linked_chest_tech_name = "Oem-linked-chest"

local linked_chest_recipes = {
    "Oem-linked-chest",
    "Huge-linked-chest",
    "share-network-output",
    "linked-pipe-input",
    "linked-pipe-output"
}

local function enable_linked_chest_recipes(force)
    for _, recipe_name in pairs(linked_chest_recipes) do
        local recipe = force.recipes[recipe_name]
        if recipe then
            recipe.enabled = true
        end
    end
end

local function enable_linked_chest_tech()
    for _, force in pairs(game.forces) do
        local tech = force.technologies[linked_chest_tech_name]
        local old_tech = force.technologies[old_linked_chest_tech_name]

        if tech then
            tech.enabled = true

            if old_tech and old_tech.researched and not tech.researched then
                tech.researched = true
            end

            if force.reset_technology_effects then
                force.reset_technology_effects()
            end

            if tech.researched or (old_tech and old_tech.researched) then
                enable_linked_chest_recipes(force)
            end
        end
    end
end

script.on_init(enable_linked_chest_tech)
script.on_configuration_changed(enable_linked_chest_tech)
