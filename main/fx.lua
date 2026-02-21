local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)
local fx = require("fx")

local assets = {
    Asset("ANIM", "anim/dragonfly_mount_fx.zip"),
}

local data = {
    {
        name = "dragonfly_mount_attackfire_fx",
        bank = "dragonfly_mount_fx",
        build = "dragonfly_mount_fx",
        anim = "atk",
        bloom = true,
        fourfaced = true,
        fn = function(inst)
        end,
    },
}

for _, v in ipairs(data) do
    table.insert(fx, v)
end

for _, v in ipairs(assets) do
    table.insert(Assets, v)
end
