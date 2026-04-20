local modname = modname
GLOBAL.setfenv(1, GLOBAL)

dragonfly_mount_clear_fn = function(inst)
    local build = inst.AnimState:GetBuild()
    if build ~= "dragonfly_mount_baby_build" and build ~= "dragonfly_mount_teen_build" then
        build = "dragonfly_mount_build"
    end
    basic_clear_fn(inst, build)
    inst.fire_hue = nil
end

saddle_dragonfly_clear_fn = function(inst)
    basic_clear_fn(inst, "saddle_dragonfly")
    local swap_build = inst.AnimState:GetBuild()
    inst.components.saddler:SetSwaps(swap_build, "swap_saddle")
end

local dragonfly_mount_skin_prefabs = LoadPrefabFile("prefabs/dragonfly_mount_skins", nil, MODS_ROOT..modname.."/")
local saddle_dragonfly_skin_prefabs = LoadPrefabFile("prefabs/saddle_dragonfly_skin", nil, MODS_ROOT..modname.."/")

local dragonfly_mount_skins = {}
for k, prefab in pairs(dragonfly_mount_skin_prefabs) do
    table.insert(dragonfly_mount_skins, prefab.name)
end

local saddle_dragonfly_skins = {}
for k, prefab in pairs(saddle_dragonfly_skin_prefabs) do
    table.insert(saddle_dragonfly_skins, prefab.name)
end

GlassicAPI.SkinHandler.AddModSkins({
    dragonfly_mount = dragonfly_mount_skins,
    saddle_dragonfly = saddle_dragonfly_skins,
})
