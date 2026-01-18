GLOBAL.setfenv(1, GLOBAL)

-- 禁止在水面和虚空中下龙蝇
local DISMOUNT_fn = ACTIONS.DISMOUNT.fn
ACTIONS.DISMOUNT.fn = function(act)
    local rider = act.doer.components.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") then
        local drownable = act.doer.components.drownable
        if drownable and (drownable:IsOverWater() or drownable:IsOverVoid()) then
            return false, "OVERWATER"
        end
    end
    return DISMOUNT_fn(act)
end

local DRAGONFLY_SADDLES = {
    saddle_war = true,
    saddle_wathgrithr = true,
    saddle_dragonfly = true,
}

local SADDLE_fn = ACTIONS.SADDLE.fn
ACTIONS.SADDLE.fn = function(act)
    if act.target and act.target:HasTag("dragonfly_mount") then
        if act.invobject and not DRAGONFLY_SADDLES[act.invobject.prefab] then
            local talker = act.doer.components.talker
            if talker then
                talker:Say(GetString(act.doer, "ANNOUNCE_NOT_DRAGONFLY_SADDLE"))
            end
            return true
        end
    end
    return SADDLE_fn(act)
end