modimport("main/prefab_files")

Assets = {
    Asset("ANIM", "anim/wilsondragonfly.zip"),
    Asset("ANIM", "anim/spell_icons_dragonfly.zip"),
    Asset("ANIM", "anim/status_dragonfly_anger.zip"),
    Asset("SOUNDPACKAGE", "sound/dragonfly_mount.fev"),
    Asset("SOUND", "sound/dragonfly_mount.fsb"),
}

PreloadAssets = {
}

modimport("main/anim-assets")

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
-- GlassicAPI.RegisterItemAtlas("inventoryimages", Assets)
