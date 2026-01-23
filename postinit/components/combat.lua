
GLOBAL.setfenv(1, GLOBAL)

local Combat = require("components/combat")

local _GetAttackRange = Combat.GetAttackRange
function Combat:GetAttackRange(...)
    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.components.combat then
        return mount.components.combat:GetAttackRange()
    end
    return _GetAttackRange(self, ...)
end

local _GetHitRange = Combat.GetHitRange
function Combat:GetHitRange(...)
    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.components.combat then
        return mount.components.combat:GetHitRange()
    end
    return _GetHitRange(self, ...)
end