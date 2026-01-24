modimport("main/prefab_files")
Assets = {
    -- Asset("IMAGE", "images/inventoryimages.xml"),
    -- Asset("ATLAS", "images/minimap.xml" ),
    Asset("ANIM", "anim/wilsondragonfly.zip"),
    Asset("ANIM", "anim/dragonfly_mount.zip"),
    Asset("ANIM", "anim/dragonfly_mount_build.zip"),
    Asset("ANIM", "anim/dragonfly_mount_fire_build.zip"),
    Asset("ANIM", "anim/dragonfly_bell.zip"),
    Asset("ANIM", "anim/spell_icons_dragonfly.zip"),
    Asset("ATLAS", "images/inventoryimages/dragonfly_bell.xml"),
}

PreloadAssets = {
}

modimport("main/anim-assets")

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
-- GlassicAPI.RegisterItemAtlas("inventoryimages", Assets)
