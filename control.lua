local linked_chest_tech_name = "sanchei-linked-chest-and-pipe"
local old_linked_chest_tech_name = "Oem-linked-chest"

local linked_chest_recipes = {
    "Oem-linked-chest",
    "Huge-linked-chest",
    "share-network-output",
    "linked-pipe-input",
    "linked-pipe-output"
}

local loaders_modernized_recipes_by_tech = {
    ["nullius-logistics-1"] = { "mdrn-loader" },
    ["nullius-logistics-2"] = { "mdrn-fast-loader" },
    ["nullius-logistics-3"] = { "mdrn-express-loader" },
    ["nullius-logistics-4"] = { "mdrn-turbo-loader", "mdrn-stack-loader" }
}

local function enable_recipes(force, recipes)
    for _, recipe_name in pairs(recipes) do
        local recipe = force.recipes[recipe_name]
        if recipe then
            recipe.enabled = true
        end
    end
end

local function sync_linked_chest_tech(force)
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
            enable_recipes(force, linked_chest_recipes)
        end
    end
end

local function sync_loaders_modernized_recipes(force)
    if not script.active_mods["loaders-modernized"] then
        return
    end

    for tech_name, recipe_names in pairs(loaders_modernized_recipes_by_tech) do
        local tech = force.technologies[tech_name]

        if tech and tech.researched then
            enable_recipes(force, recipe_names)
        end
    end
end

local function sync_compat_fixes()
    for _, force in pairs(game.forces) do
        sync_linked_chest_tech(force)
        sync_loaders_modernized_recipes(force)
    end
end

script.on_init(sync_compat_fixes)
script.on_configuration_changed(sync_compat_fixes)
