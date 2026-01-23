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

    -- 修改攻击出伤时间
    for i, time_event in ipairs(attack_timeline) do
        local time_event_fn = time_event.fn
        time_event.fn = function(inst, ...)
            local rider = inst.replica.rider
            local mount = rider and rider:GetMount()
            if mount and mount:HasTag("dragonfly_mount") then
                return
            end
            return time_event_fn(inst, ...)
        end
    end

    table.insert(attack_timeline, TimeEvent(12 * FRAMES, function(inst)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return
        end

        if TheWorld.ismastersim then
            inst:PerformBufferedAction()
        else
            inst:ClearBufferedAction()
        end
        inst.sg:RemoveStateTag("abouttoattack")
    end))

    -- 添加骑乘龙蝇攻击音效
    table.insert(attack_timeline, TimeEvent(7 * FRAMES, function(inst)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return
        end
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/swipe")
    end))

    table.insert(attack_timeline, TimeEvent(15 * FRAMES, function(inst)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return
        end
        local volume = 0.6
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/punchimpact", nil, volume)
    end))

    -- 修改ACTIONS.CASTAOE的目标状态
    local castaoe_deststate = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        if action.invobject and action.invobject:HasTag("dragonfly_mount") and action.invobject.spell_deststate then
            return action.invobject.spell_deststate(inst, action)
        end
        return castaoe_deststate(inst, action)
    end
end

AddStategraphPostInit("wilson", SGwilson)
AddStategraphPostInit("wilson_client", SGwilson)
