local _AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local function AddAction(data, id, str, fn, wilsonAction, wilsonClientAction)
    local action = Action(data)
    action.id = id
    local oldActionStr
    if type(str) == "function" then
        -- action.stroverridefn = str --这个需要直接返回文本
        action.strfn = str
        oldActionStr = STRINGS.ACTIONS[string.upper(id)]
    else
        action.str = str
    end

    action.fn = fn
    _AddAction(action)
    --AddAction里面会直接覆盖STRINGS.ACTIONS
    STRINGS.ACTIONS[string.upper(id)] = oldActionStr or STRINGS.ACTIONS[string.upper(id)]

    if wilsonAction then
        AddStategraphActionHandler("wilson", ActionHandler(action, wilsonAction))
    end
    wilsonClientAction = wilsonClientAction or wilsonAction
    if wilsonClientAction then
        AddStategraphActionHandler("wilson_client", ActionHandler(action, wilsonClientAction))
    end
    return action
end

-- 召回龙蝇
AddAction(
    {invalid_hold_action = true, priority = 5},
    "RECALL_DRAGONFLY",
    STRINGS.ACTIONS.RECALL_DRAGONFLY,
    function(act)
        if act.doer and act.invobject and act.invobject.RecallDragonfly then
            return act.invobject:RecallDragonfly(act.doer)
        end
    end,
    "use_beef_bell"
)

-- 召出龙蝇
AddAction(
    {invalid_hold_action = true, priority = 5},
    "SUMMON_DRAGONFLY",
    STRINGS.ACTIONS.SUMMON_DRAGONFLY,
    function(act)
        if act.doer and act.invobject and act.invobject.SummonDragonfly then
            return act.invobject:SummonDragonfly(act.doer)
        end
    end,
    "use_beef_bell"
)

local HIGH_ACTION_PRIORITY = 10
local COMPONENT_ACTIONS = GlassicAPI.UpvalueUtil.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY

local DrownCheckClientSafe = function(inst)
    if inst:GetCurrentPlatform() then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsOceanTileAtPoint(x, y, z) or TheWorld.Map:IsInvalidTileAtPoint(x, y, z) then
        return true
    end
end

-- 禁止在水面和虚空中下龙蝇
AddComponentAction("SCENE", "rider", function(inst, doer, actions, right)
    if inst == doer then
        local mount = doer.replica.rider:GetMount()
        if mount and mount:HasTag("dragonfly_mount") then
            if DrownCheckClientSafe(inst) then
                for i = #actions, 1, -1 do
                    if actions[i] == ACTIONS.DISMOUNT then
                        table.remove(actions, i)
                    end
                end
            end
        end
    end
end)

-- 召唤和收回龙蝇
AddComponentAction("INVENTORY", "useabletargeteditem", function(inst, doer, actions)
    if inst:HasTag("dragonfly_bell_opal") then
        if inst:HasTag("dragonfly_saved") then
            table.insert(actions, ACTIONS.SUMMON_DRAGONFLY)
        elseif inst:HasTag("inuse_targeted") then
            table.insert(actions, ACTIONS.RECALL_DRAGONFLY)
        end
    end
end)
