local linked_chest_tech_name = "sanchei-linked-chest-and-pipe"

local function enable_linked_chest_tech()
    for _, force in pairs(game.forces) do
        local tech = force.technologies[linked_chest_tech_name]
        if tech then
            tech.enabled = true
        end
    end
end

script.on_init(enable_linked_chest_tech)
script.on_configuration_changed(enable_linked_chest_tech)
