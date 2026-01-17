local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphActionHandler = AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

local HIGH_ACTION_PRIORITY = 10

if not rawget(_G, "HotReloading") then
    local ACTIONS = {}

    for name, action in pairs(ACTIONS) do
        action.id = name
        action.str = STRINGS.ACTIONS[name] or name
        AddAction(action)
    end
end

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
