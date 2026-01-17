local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
}

local states = {
}

for _, state in ipairs(states) do
    AddStategraphState("wilson_client", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

AddStategraphPostInit("wilson_client", function(sg)
    local attack = sg.states.attack
    local attack_timeline = attack.timeline

    table.insert(attack_timeline, TimeEvent(7 * FRAMES, function(inst)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return
        end
        inst.SoundEmitter:PlaySound(
            "dontstarve_DLC001/creatures/dragonfly/swipe")
    end))

    table.insert(attack_timeline, TimeEvent(15 * FRAMES, function(inst)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return
        end
        inst.SoundEmitter:PlaySound(
            "dontstarve_DLC001/creatures/dragonfly/punchimpact")
    end))
end)
