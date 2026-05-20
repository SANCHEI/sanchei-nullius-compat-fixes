local stats = {
    entangled_recipes = 0,
    missing_unlocks_removed = 0,
    entangled_unlocks_added = 0,
    research_unlocks_added = 0,
    techs_prepared = 0,
    loader_upgrades_removed = 0,
    stack_sizes_adjusted = 0
}

local adjusted_stack_items = {}

local function effects_of(tech)
    if not tech.effects then
        tech.effects = {}
    end
    return tech.effects
end

local function has_unlock(tech, recipe_name)
    for _, effect in pairs(effects_of(tech)) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            return true
        end
    end
    return false
end

local function recipe_result_names(recipe)
    local names = {}

    if recipe.result then
        names[#names + 1] = recipe.result
    end

    for _, result in pairs(recipe.results or {}) do
        if type(result) == "table" then
            names[#names + 1] = result.name or result[1]
        elseif type(result) == "string" then
            names[#names + 1] = result
        end
    end

    return names
end

local function unhide_item(item_name)
    local item = item_name and data.raw.item[item_name]
    if item then
        item.hidden = false
        item.hidden_in_factoriopedia = false
    end

    if item and item.place_result then
        for _, entity_type in pairs({
            "container",
            "linked-container",
            "logistic-container",
            "storage-tank",
            "loader",
            "loader-1x1",
            "loader-1x2",
            "furnace",
            "underground-belt"
        }) do
            local entity = data.raw[entity_type] and data.raw[entity_type][item.place_result]
            if entity then
                entity.hidden = false
                entity.hidden_in_factoriopedia = false
            end
        end
    end
end

local function show_recipe(recipe_name)
    local recipe = data.raw.recipe[recipe_name]
    if not recipe then
        return nil
    end

    recipe.hidden = false
    recipe.hidden_in_factoriopedia = false
    recipe.allow_as_intermediate = true
    recipe.allow_decomposition = true

    for _, item_name in pairs(recipe_result_names(recipe)) do
        unhide_item(item_name)
    end

    return recipe
end

local function add_unlock(tech_name, recipe_name)
    local tech = data.raw.technology[tech_name]
    local recipe = show_recipe(recipe_name)

    if not tech or not recipe then
        return false
    end

    tech.hidden = false
    tech.enabled = true

    if not has_unlock(tech, recipe_name) then
        table.insert(effects_of(tech), { type = "unlock-recipe", recipe = recipe_name })
        stats.research_unlocks_added = stats.research_unlocks_added + 1
    end

    return true
end

local function copy_unit_from(tech, source_name, multiplier)
    local source = data.raw.technology[source_name]
    if source and source.unit then
        tech.unit = table.deepcopy(source.unit)
        if multiplier and tech.unit.count then
            tech.unit.count = math.max(1, math.ceil(tech.unit.count * multiplier))
        end
    end
end

local function prepare_tech(tech_name, source_name, prerequisites, order_suffix, unit_multiplier)
    local tech = data.raw.technology[tech_name]
    if not tech then
        return nil
    end

    tech.hidden = false
    tech.enabled = true
    tech.prerequisites = prerequisites

    copy_unit_from(tech, source_name, unit_multiplier)

    local source = data.raw.technology[source_name]
    if source and source.order then
        tech.order = source.order .. (order_suffix or "")
    end

    stats.techs_prepared = stats.techs_prepared + 1
    return tech
end

local function create_entangled_recipe(item_name)
    local recipe_name = "eb-" .. item_name
    local eb_item = data.raw.item[recipe_name]
    local source_item = data.raw.item[item_name]

    if not eb_item or not source_item or data.raw.recipe[recipe_name] then
        return data.raw.recipe[recipe_name]
    end

    data:extend({
        {
            type = "recipe",
            name = recipe_name,
            localised_name = eb_item.localised_name,
            localised_description = eb_item.localised_description,
            enabled = false,
            hidden = false,
            allow_as_intermediate = true,
            allow_decomposition = true,
            energy_required = 0.5,
            ingredients = {
                { type = "item", name = item_name, amount = 2 }
            },
            results = {
                { type = "item", name = recipe_name, amount = 2 }
            },
            icons = table.deepcopy(eb_item.icons),
            icon = eb_item.icon,
            icon_size = eb_item.icon_size,
            subgroup = eb_item.subgroup or source_item.subgroup,
            order = (eb_item.order or source_item.order or "") .. "z"
        }
    })

    stats.entangled_recipes = stats.entangled_recipes + 1
    return data.raw.recipe[recipe_name]
end

local function fix_entangled_nullius_research()
    if not mods["EntangledBelts"] or not mods["nullius"] then
        return
    end

    local tiers = {
        { item = "underground-belt", tech = "nullius-logistics-1" },
        { item = "fast-underground-belt", tech = "nullius-logistics-2" },
        { item = "express-underground-belt", tech = "nullius-logistics-3" },
        { item = "bob-ultimate-underground-belt", tech = "nullius-logistics-4" },
        { item = "turbo-underground-belt", tech = "nullius-logistics-4" }
    }

    for _, tier in pairs(tiers) do
        if data.raw.item[tier.item] and data.raw.item["eb-" .. tier.item] then
            create_entangled_recipe(tier.item)
            add_unlock(tier.tech, "eb-" .. tier.item)
        end
    end
end

local function clean_entangled_unlocks()
    if not mods["EntangledBelts"] then
        return
    end

    for _, technology in pairs(data.raw.technology or {}) do
        if technology.effects then
            local unlocked = {}

            for index = #technology.effects, 1, -1 do
                local effect = technology.effects[index]
                if effect.type == "unlock-recipe" and effect.recipe then
                    if data.raw.recipe[effect.recipe] then
                        unlocked[effect.recipe] = true
                    else
                        table.remove(technology.effects, index)
                        stats.missing_unlocks_removed = stats.missing_unlocks_removed + 1
                    end
                end
            end

            local valid_effects = {}
            for _, effect in ipairs(technology.effects) do
                if effect.type == "unlock-recipe" and effect.recipe then
                    valid_effects[#valid_effects + 1] = effect
                end
            end

            for _, effect in ipairs(valid_effects) do
                local entangled_recipe = "eb-" .. effect.recipe
                if data.raw.recipe[entangled_recipe] and not unlocked[entangled_recipe] then
                    table.insert(technology.effects, {
                        type = "unlock-recipe",
                        recipe = entangled_recipe
                    })
                    unlocked[entangled_recipe] = true
                    stats.entangled_unlocks_added = stats.entangled_unlocks_added + 1
                end
            end
        end
    end
end

local function has_visible_builder_item(entity_name)
    for _, item in pairs(data.raw.item or {}) do
        if item.place_result == entity_name and not item.hidden then
            return true
        end
    end

    return false
end

local function fix_loader_next_upgrade(entity_type)
    for _, entity in pairs(data.raw[entity_type] or {}) do
        local target_name = entity.next_upgrade
        if target_name then
            local target = data.raw[entity_type] and data.raw[entity_type][target_name]
            if not target or not has_visible_builder_item(target_name) then
                entity.next_upgrade = nil
                stats.loader_upgrades_removed = stats.loader_upgrades_removed + 1
            end
        end
    end
end

local function fix_deadlock_loader_upgrades()
    fix_loader_next_upgrade("loader")
    fix_loader_next_upgrade("loader-1x1")
    fix_loader_next_upgrade("loader-1x2")
end

local function fix_deadlock_nullius_research()
    if not mods["deadlock-beltboxes-loaders"] or not mods["nullius"] then
        return
    end

    local tiers = {
        {
            nullius_tech = "nullius-logistics-1",
            deadlock_tech = "deadlock-stacking-1",
            recipes = { "transport-belt-loader", "transport-belt-beltbox" }
        },
        {
            nullius_tech = "nullius-logistics-2",
            deadlock_tech = "deadlock-stacking-2",
            recipes = { "fast-transport-belt-loader", "fast-transport-belt-beltbox" }
        },
        {
            nullius_tech = "nullius-logistics-3",
            deadlock_tech = "deadlock-stacking-3",
            recipes = { "express-transport-belt-loader", "express-transport-belt-beltbox" }
        },
        {
            nullius_tech = "nullius-logistics-4",
            deadlock_tech = "deadlock-stacking-4",
            recipes = {
                "turbo-transport-belt-loader",
                "turbo-transport-belt-beltbox",
                "bob-ultimate-transport-belt-loader",
                "bob-ultimate-transport-belt-beltbox"
            }
        }
    }

    for _, tier in pairs(tiers) do
        local stacking_tech = prepare_tech(
            tier.deadlock_tech,
            tier.nullius_tech,
            { tier.nullius_tech },
            "-deadlock",
            1.5
        )

        for _, recipe_name in pairs(tier.recipes) do
            if data.raw.recipe[recipe_name] then
                add_unlock(tier.nullius_tech, recipe_name)
                if stacking_tech and recipe_name:find("beltbox", 1, true) then
                    add_unlock(tier.deadlock_tech, recipe_name)
                end
            end
        end
    end
end

local function fix_linked_chest_and_pipe()
    if not mods["LinkedChestAndPipe"] or not mods["nullius"] then
        return
    end

    local tech = data.raw.technology["Oem-linked-chest"]

    if tech then
        tech.hidden = false
        tech.enabled = true
        tech.prerequisites = { "nullius-geology-1" }
        tech.unit = {
            count = 10,
            ingredients = {
                { "nullius-geology-pack", 1 }
            },
            time = 10
        }
        stats.techs_prepared = stats.techs_prepared + 1
    end

    for _, recipe_name in pairs({
        "Oem-linked-chest",
        "Huge-linked-chest",
        "share-network-output",
        "linked-pipe-input",
        "linked-pipe-output"
    }) do
        add_unlock("Oem-linked-chest", recipe_name)
    end
end

local function adjust_stack_size(item_name, count, entity_type, entity_name, source)
    if not item_name then
        return
    end

    count = count or 1
    local item = data.raw.item[item_name]

    if item and count > (item.stack_size or 1) then
        item.stack_size = count
        adjusted_stack_items[item_name] = true
        log("sanchei-nullius-compat-fixes: raised stack_size of '" .. item_name ..
            "' to " .. count .. " for " .. entity_type .. " '" ..
            entity_name .. "' via " .. source)
    end
end

local function scan_stack(stack, entity_type, entity_name, source)
    if type(stack) ~= "table" then
        return
    end

    adjust_stack_size(stack.item or stack.name, stack.count or 1, entity_type, entity_name, source)
end

local function scan_placeable_by(placeable_by, entity_type, entity_name)
    if type(placeable_by) ~= "table" then
        return
    end

    if placeable_by.item or placeable_by.name then
        scan_stack(placeable_by, entity_type, entity_name, "placeable_by")
        return
    end

    for _, stack in pairs(placeable_by) do
        scan_stack(stack, entity_type, entity_name, "placeable_by")
    end
end

local function scan_entity_stack_sizes(entity_type)
    for _, entity in pairs(data.raw[entity_type] or {}) do
        scan_placeable_by(entity.placeable_by, entity_type, entity.name)

        for _, stack in pairs(entity.items_to_place_this or {}) do
            scan_stack(stack, entity_type, entity.name, "items_to_place_this")
        end
    end
end

local function fix_widechests_stack_sizes()
    scan_entity_stack_sizes("container")
    scan_entity_stack_sizes("logistic-container")

    for _ in pairs(adjusted_stack_items) do
        stats.stack_sizes_adjusted = stats.stack_sizes_adjusted + 1
    end
end

fix_entangled_nullius_research()
clean_entangled_unlocks()
fix_deadlock_loader_upgrades()
fix_deadlock_nullius_research()
fix_linked_chest_and_pipe()
fix_widechests_stack_sizes()

log("sanchei-nullius-compat-fixes: created " .. stats.entangled_recipes ..
    " Entangled recipe(s), removed " .. stats.missing_unlocks_removed ..
    " missing unlock(s), added " .. stats.entangled_unlocks_added ..
    " generic Entangled unlock(s), added " .. stats.research_unlocks_added ..
    " research unlock(s), prepared " .. stats.techs_prepared ..
    " tech link(s), removed " .. stats.loader_upgrades_removed ..
    " invalid loader upgrade(s), adjusted " .. stats.stack_sizes_adjusted ..
    " stack size(s)")
