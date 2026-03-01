local AddRecipe2 = AddRecipe2

GLOBAL.setfenv(1, GLOBAL)

-- GlassicAPI.AddTech("GK_SMITH")  -- 科技
-- GlassicAPI.AddTech("GREED_POWER", true)  -- 临时科技
-- GlassicAPI.AddPrototyperTrees("GOBLINKILLER_SMITH", {GK_SMITH = 1})  -- 科技站

-- GlassicAPI.AddRecipe("goblinkiller_backpack_2",
--     {
--         Ingredient("goblinkiller_backpack_1", 1),
--         Ingredient("pigskin", 4),
--         Ingredient("silk", 6),
--         Ingredient("rope", 2)
--     },
--     TECH.NONE,
--     { builder_tag = "goblinkiller" },
--     { "CHARACTER", "CONTAINERS" }
-- )


AddRecipe2("dragonfly_bell",
    {Ingredient("beef_bell", 1), Ingredient("dragon_scales", 1)},
    TECH.LOST,
    {atlas = "images/inventoryimages/dragonfly_bell.xml", image = "dragonfly_bell.tex"},
    {CRAFTING_FILTERS.RIDING.name})


AddRecipe2("dragonfly_bell_opal",
    {Ingredient("dragonfly_bell", 1), Ingredient("opalpreciousgem", 1)},
    TECH.SCIENCE_TWO,
    {atlas = "images/inventoryimages/dragonfly_bell_opal.xml", image = "dragonfly_bell_opal.tex"},
    {CRAFTING_FILTERS.RIDING.name})


AddRecipe2("saddle_dragonfly",
    {Ingredient("saddle_war", 1), Ingredient("dragon_scales", 3)},
    TECH.LOST,
    {atlas = "images/inventoryimages/saddle_dragonfly.xml", image = "saddle_dragonfly.tex"},
    {CRAFTING_FILTERS.RIDING.name})
