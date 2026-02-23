
GLOBAL.setfenv(1, GLOBAL)

local Combat = require("components/combat")

local _GetAttackRange = Combat.GetAttackRange
function Combat:GetAttackRange(...)
    local range = _GetAttackRange(self, ...)
    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.components.combat then
        range = math.max(range, mount.components.combat:GetAttackRange())
    end
    return range
end

local _GetHitRange = Combat.GetHitRange
function Combat:GetHitRange(...)
    local range = _GetHitRange(self, ...)
    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.components.combat then
        range = math.max(range, mount.components.combat:GetHitRange())
    end
    return range
end

-- replica

local Combat = require("components/combat_replica")
local _GetAttackRangeWithWeapon = Combat.GetAttackRangeWithWeapon
function Combat:GetAttackRangeWithWeapon(...)
    local range = _GetAttackRangeWithWeapon(self, ...)
    if self.inst.components.combat ~= nil then
        return range
    end

    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.replica.combat then
        range = math.max(range, mount.replica.combat:GetAttackRangeWithWeapon())
    end
    return range
end
