local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)
local fx = require("fx")

local fxs = {}

for _, v in ipairs(fxs) do
    table.insert(fx, v)
    if Settings.last_asset_set ~= nil then
        table.insert(Assets, Asset("ANIM", "anim/" .. v.build .. ".zip"))
    end
end
