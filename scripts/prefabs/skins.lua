local prefabs = {
    -- CreatePrefabSkin("goblinkiller_none", {
    --     base_prefab = "goblinkiller",
    --     type = "base",
    --     assets = {
    --         Asset( "ANIM", "anim/goblinkiller.zip" ),
    --         Asset( "ANIM", "anim/ghost_goblinkiller_build.zip"),
    --     },
    --     skins = { normal_skin = "goblinkiller", ghost_skin = "ghost_goblinkiller_build" },
    --     bigportrait = { build = "bigportrait/goblinkiller_none.xml", symbol = "goblinkiller_none_oval.tex"},
    --     skin_tags = { "goblinkiller", "BASE" },
    --     build_name_override = "goblinkiller",
    --     rarity = "Character",
    -- }),
    -- CreatePrefabSkin("goblinkiller_toothpick_giant", {
    --     base_prefab = "goblinkiller_toothpick",
    --     type = "item",
    --     rarity = "Reward",
    --     assets = {
    --         Asset("ANIM", "anim/goblinkiller_toothpick_giant.zip"),
    --     },
    --     init_fn = GlassicAPI.BasicInitFn,
    --     skin_tags = { "goblinkiller_toothpick_giant" },
    --     build_name_override = "goblinkiller_toothpick_giant",
    --     release_group = 87,
    -- }),
}

return unpack(prefabs)
