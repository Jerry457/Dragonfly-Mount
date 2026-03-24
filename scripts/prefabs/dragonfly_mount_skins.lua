local function MackInit(fire_engulf_hue)
    return function (inst, skin_name)
        GlassicAPI.BasicInitFn(inst)

        if inst.components.skinner then
            local skin_name = inst:GetSkinName() or "dragonfly_mount_none"
            inst.components.skinner:SetSkinName(skin_name)
        end

        inst.fire_engulf_hue = fire_engulf_hue
        inst.AnimState:SetSymbolHue("fire_engulf", fire_engulf_hue)
    end
end

local prefabs = {
    CreatePrefabSkin("dragonfly_mount_none", {
        base_prefab = "dragonfly_mount",
        type = "base",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/dragonfly_mount_baby_build.zip"),
            Asset("ANIM", "anim/dragonfly_mount_teen_build.zip"),
            Asset("ANIM", "anim/dragonfly_mount_build.zip"),
            Asset("ANIM", "anim/dragonfly_mount_fire_build.zip"),
        },
        init_fn = MackInit(0),
        skin_tags = { "DRAGONFLY_MOUNT", "BASE" },
        build_name_override = "dragonfly_mount_build",
        skins = {
            baby_skin = "dragonfly_mount_baby_build",
            teen_skin = "dragonfly_mount_teen_build",
            normal_skin = "dragonfly_mount_build",
            fire_skin = "dragonfly_mount_fire_build",
        },
    }),
    CreatePrefabSkin("dragonfly_mount_yule", {
        base_prefab = "dragonfly_mount",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/dragonfly_yule_build.zip"),
            Asset("ANIM", "anim/dragonfly_fire_yule_build.zip"),
        },
        init_fn = MackInit(0),
        skin_tags = { "DRAGONFLY_MOUNT_YULE" },
        build_name_override = "dragonfly_yule_build",
        skins = {
            baby_skin = "dragonfly_mount_baby_build",
            teen_skin = "dragonfly_mount_teen_build",
            normal_skin = "dragonfly_yule_build",
            fire_skin = "dragonfly_fire_yule_build",
        },
    }),
    CreatePrefabSkin("dragonfly_mount_antlion", {
        base_prefab = "dragonfly_mount",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/dragonfly_mount_antlion_build.zip"),
            Asset("ANIM", "anim/dragonfly_mount_fire_antlion_build.zip"),
        },
        init_fn = MackInit(0),
        skin_tags = { "DRAGONFLY_MOUNT_ANTLION" },
        build_name_override = "dragonfly_mount_antlion_build",
        skins = {
            baby_skin = "dragonfly_mount_baby_build",
            teen_skin = "dragonfly_mount_teen_build",
            normal_skin = "dragonfly_mount_antlion_build",
            fire_skin = "dragonfly_mount_fire_antlion_build",
        },
    }),
}

return unpack(prefabs)
