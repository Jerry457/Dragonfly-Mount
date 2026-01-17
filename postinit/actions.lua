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