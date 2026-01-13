local modimport = modimport
local AddRoomPreInit = AddRoomPreInit
GLOBAL.setfenv(1, GLOBAL)

local IsTheFrontEnd = rawget(_G, "TheFrontEnd") and rawget(_G, "IsInFrontEnd") and IsInFrontEnd()
if IsTheFrontEnd then
    -- modimport("main/strings")
    return
end

local AllLayouts = require("map/layouts").Layouts
