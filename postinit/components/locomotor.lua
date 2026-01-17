
GLOBAL.setfenv(1, GLOBAL)

local Locomotor = require("components/locomotor")

-- 为什么不使用SetAllowPlatformHopping来禁止跳船
-- 因为下面这样写不用考虑主客机同步和玩家开关延迟补偿
local _ScanForPlatform = Locomotor.ScanForPlatform
function Locomotor:ScanForPlatform(...)
    local can_hop, hop_x, hop_z, target_platform, blocked = _ScanForPlatform(self, ...)

    local rider = self.inst.replica and self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") then
        can_hop = false
        blocked = true
    end

    return can_hop, hop_x, hop_z, target_platform, blocked
end