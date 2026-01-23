
GLOBAL.setfenv(1, GLOBAL)

local Playercontroller = require("components/playercontroller")

-- TryAOETargeting 开/关施法轮盘
local _TryAOETargeting = Playercontroller.TryAOETargeting
function Playercontroller:TryAOETargeting(...)
    local rider = self.inst.replica.rider
    local mount = rider and rider:GetMount()
    if mount and mount:HasTag("dragonfly_mount") and mount.components.spellbook and mount.components.spellbook:CanBeUsedBy(self.inst) then
        local buffaction = nil
        if self.inst.HUD:IsSpellWheelOpen() then
            buffaction = BufferedAction(self.inst, nil, ACTIONS.CLOSESPELLBOOK, mount)
        else
            buffaction = BufferedAction(self.inst, nil, ACTIONS.USESPELLBOOK, mount)
        end
        buffaction.action.pre_action_cb(buffaction)
        -- 这里只要打开轮盘界面即可
        return true
    end
    return _TryAOETargeting(self, ...)
end

-- local _CancelAOETargeting = Playercontroller.CancelAOETargeting
-- function Playercontroller:CancelAOETargeting(...)
--     print("playercontroller.lua CancelAOETargeting")
--     return _CancelAOETargeting(self, ...)
-- end