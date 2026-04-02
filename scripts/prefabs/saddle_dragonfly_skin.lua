local function init_fn(inst, skin_name)
    GlassicAPI.BasicInitFn(inst)
    if inst.components.saddler then
        local swap_build = inst.AnimState:GetBuild()
        inst.components.saddler:SetSwaps(swap_build, "swap_saddle")
    end
end

local prefabs = {
    CreatePrefabSkin("saddle_dragonfly_yule", {
        base_prefab = "saddle_dragonfly",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/saddle_dragonfly_yule.zip"),
            Asset("ANIM", "anim/saddle_dragonfly_yule_fire.zip"),
        },
        init_fn = init_fn,
        skin_tags = { "SADDLE_DRAGONFLY_YULE" },
        build_name_override = "saddle_dragonfly_yule",
    }),
    CreatePrefabSkin("saddle_dragonfly_moonmaw", {
        base_prefab = "saddle_dragonfly",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/saddle_dragonfly_moonmaw.zip"),
            Asset("ANIM", "anim/saddle_dragonfly_moonmaw_fire.zip"),
        },
        init_fn = init_fn,
        skin_tags = { "SADDLE_DRAGONFLY_MOONMAW" },
        build_name_override = "saddle_dragonfly_moonmaw",
    }),
    CreatePrefabSkin("saddle_dragonfly_antlion", {
        base_prefab = "saddle_dragonfly",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/saddle_dragonfly_antlion.zip"),
            Asset("ANIM", "anim/saddle_dragonfly_antlion_fire.zip"),
        },
        init_fn = init_fn,
        skin_tags = { "SADDLE_DRAGONFLY_ANTLION" },
        build_name_override = "saddle_dragonfly_antlion",
    }),
}

return unpack(prefabs)
