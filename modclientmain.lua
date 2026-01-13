if not GLOBAL.IsInFrontEnd() then return end

Assets = {
    -- Asset("IMAGE", "images/inventoryimages.xml"),
}

PrefabFiles = {
    "skins",
}

modimport("main/glassic_api_loader")
modimport("main/characters") -- For API functions & mod env

modimport("main/tuning")
modimport("main/strings")
modimport("main/prefab_skins")

-- GlassicAPI.RegisterItemAtlas("inventoryimages", Assets)
