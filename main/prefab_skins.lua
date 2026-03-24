local modname = modname
GLOBAL.setfenv(1, GLOBAL)

dragonfly_mount_clear_fn = function(inst)
    basic_clear_fn(inst, "dragonfly_mount_build")
    inst.fire_hue = nil
end

local dragonfly_mount_skin_prefabs = LoadPrefabFile("prefabs/dragonfly_mount_skins", nil, MODS_ROOT..modname.."/")

local dragonfly_mount_skins = {}
for k, prefab in pairs(dragonfly_mount_skin_prefabs) do
    table.insert(dragonfly_mount_skins, prefab.name)
end

GlassicAPI.SkinHandler.AddModSkins({
    dragonfly_mount = dragonfly_mount_skins
})
