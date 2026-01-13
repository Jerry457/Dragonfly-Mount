local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    -- ActionHandler(ACTIONS.GK_EQUIPSLOT_LEARN, "dolongaction"),
    -- ActionHandler(ACTIONS.GLUTTONY_EAT, function(inst, action)
    --     if not inst.sg:HasStateTag("busy") then
    --         return "quickeat"
    --     end
    -- end),
}

local states = {
}

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

AddStategraphPostInit("wilson", function(sg)
end)
