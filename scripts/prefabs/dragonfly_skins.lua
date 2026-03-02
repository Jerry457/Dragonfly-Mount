local skins = require("utils/dragonfly_mount_skins")

local prefabs = {
    CreatePrefabSkin("dragonfly_mount_yule", {
        base_prefab = "dragonfly_mount",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/dragonfly_yule_build.zip"),
            Asset("ANIM", "anim/dragonfly_fire_yule_build.zip"),
        },
        init_fn = GlassicAPI.BasicInitFn,
        skin_tags = { "DRAGONFLY_MOUNT_YULE" },
        build_name_override = "dragonfly_yule_build",
        skins = { normal_skin = "dragonfly_yule_build", fire_skin = "dragonfly_fire_yule_build" },
        release_group = 87,
    })
}

for _, skin_type in pairs(skins) do
    local build = "dragonfly_mount_" .. skin_type .. "_build"
    local fire_build = "dragonfly_mount_fire" .. skin_type .. "_build"

    table.insert(prefabs, CreatePrefabSkin("dragonfly_mount_" .. skin_type, {
        base_prefab = "dragonfly_mount",
        type = "item",
        rarity = "Reward",
        assets = {
            Asset("ANIM", "anim/" .. build .. ".zip"),
            Asset("ANIM", "anim/" .. fire_build .. ".zip"),
        },
        init_fn = GlassicAPI.BasicInitFn,
        skin_tags = { string.upper(build) },
        build_name_override = build,
        skins = { normal_skin = build, fire_skin = fire_build },
        release_group = 87,
    }))
end

return unpack(prefabs)
