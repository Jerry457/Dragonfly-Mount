
GLOBAL.setfenv(1, GLOBAL)

local Playercontroller = require("components/playercontroller")

-- TryAOECharging 开/关施法轮盘
local _TryAOECharging = Playercontroller.TryAOECharging
function Playercontroller:TryAOECharging(force_rotation, iscontroller, ...)
    local v = _TryAOECharging(self, force_rotation, iscontroller, ...)
    if v or iscontroller then
        return v
    end

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
        return true
    end

    return v
end

DragonflyMountHookOnRemoteLeftClick = function()
    local function MimicInventoryitem(spellbook, player)
        spellbook.components.inventoryitem = {
            GetGrandOwner = function()
                return player
            end
        }
    end

    local _OnRemoteLeftClick = Playercontroller.OnRemoteLeftClick
    function Playercontroller:OnRemoteLeftClick(actioncode, position, target, isreleased, controlmodscode, noforce, mod_name, spellbook, spell_id, ...)
        if not (spellbook and spellbook:HasTag("dragonfly_mount")) then
            return _OnRemoteLeftClick(self, actioncode, position, target, isreleased, controlmodscode, noforce, mod_name, spellbook, spell_id, ...)
        end
        -- 伪装inventoryitem
        MimicInventoryitem(spellbook, self.inst)
        _OnRemoteLeftClick(self, actioncode, position, target, isreleased, controlmodscode, noforce, mod_name, spellbook, spell_id, ...)
        spellbook.components.inventoryitem = nil
    end
end

DragonflyMountHookOnRemoteLeftClick()
