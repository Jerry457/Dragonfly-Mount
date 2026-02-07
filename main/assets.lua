modimport("main/prefab_files")

Assets = {
    Asset("ANIM", "anim/wilsondragonfly.zip"),
    Asset("ANIM", "anim/spell_icons_dragonfly.zip"),
}

PreloadAssets = {
}

modimport("main/anim-assets")

ReloadPreloadAssets()

modimport("main/glassic_api_loader")

-- AddMinimapAtlas("images/gk_minimap.xml")
-- GlassicAPI.RegisterItemAtlas("inventoryimages", Assets)
