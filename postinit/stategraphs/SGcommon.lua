env.SG_COMMON = env.SG_COMMON or {}

local SG_COMMON = SG_COMMON
local AddStategraphActionHandler = AddStategraphActionHandler
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {}

local states = {}

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
    AddStategraphActionHandler("wilson_client", actionhandler)
end

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
    AddStategraphState("wilson_client", state)
end

local function SGwilson(sg)
    local attack = sg.states.attack
    local attack_timeline = attack.timeline

    -- 添加骑乘龙蝇攻击音效
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
        local volume = 0.6
        inst.SoundEmitter:PlaySound(
            "dontstarve_DLC001/creatures/dragonfly/punchimpact", nil, volume)
    end))

end

AddStategraphPostInit("wilson", SGwilson)
AddStategraphPostInit("wilson_client", SGwilson)
