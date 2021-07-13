local mod = get_mod("TourneyBalance")

-- Buff and Talent Functions
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.modify_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    if original_buff ~= nil then
        TalentBuffTemplates[hero_name][buff_name] = merge(original_buff, new_talent_buff)
        BuffTemplates[buff_name] = merge(original_buff, new_talent_buff)
    else
        mod:echo("Error modifying talent buff: " .. tostring(buff_name))
    end
end
function mod.add_buff_template(self, buff_name, buff_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end


-- Shade Talents
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_buff", {
--    multiplier = 0, -- -0.45
--})
--mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_quick_cooldown_crit", {
--    duration = 6, --4
--})
--mod:modify_talent("we_shade", 6, 1, {
--    description = "rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2",
--    description_values = {},
--})

local function updateValues()
	local we = TalentBuffTemplates.wood_elf
	we.kerillian_shade_activated_ability_quick_cooldown_buff.buffs[1].multiplier = 0
	we.kerillian_shade_activated_ability_quick_cooldown_crit.buffs[1].duration = 6
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return

end

mod.on_enabled = function (self)
	mod:echo("enable")
	updateValues()

	return 
end

mod:add_text("rebaltourn_kerillian_shade_activated_ability_quick_cooldown_desc_2", "After leaving stealth, Kerillian gains 100%% melee critical strike chance for 6 seconds, but no longer gains a damage bonus on attacking.")

-- SotT Talents
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
    amount_to_add = 2 -- 3
})
mod:modify_talent("we_thornsister", 5, 2, {
    description_values = {
        {
            value = 2
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_avatar", {
    max_stack_data = {
        buffs_to_add = {
            "kerillian_thorn_sister_avatar_buff_1",
            "kerillian_thorn_sister_avatar_buff_2",
            --"kerillian_thorn_sister_avatar_buff_3",
            --"kerillian_thorn_sister_avatar_buff_4"
        }
    }
})
mod:modify_talent("we_thornsister", 4, 3, {
    description = "rebaltourn_kerillian_thorn_sister_avatar_desc",
})
mod:add_text("rebaltourn_kerillian_thorn_sister_avatar_desc", "Consuming Radiance grants Kerillian 20%% extra attack speed and move speed for 10 seconds.")


-- Battle Wizard Talents
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05 -- -0.1
})
mod:modify_talent("bw_adept", 5, 2, {
    description_values = {
        {
            value_type = "percent",
            value = -0.05 --TalentBuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.multiplier
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.duration
        },
        {
            value = BuffTemplates.sienna_adept_damage_reduction_on_ignited_enemy_buff.max_stacks
        }
    },
})