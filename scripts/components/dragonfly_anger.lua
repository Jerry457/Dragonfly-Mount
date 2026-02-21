local function onmax(self, max)
    if self.inst.dragonfly_classified then
        self.inst.dragonfly_classified.maxanger:set(max)
    end
end

local function oncurrent(self, current)
    if self.inst.dragonfly_classified then
        self.inst.dragonfly_classified.currentanger:set(current)
    end
end

local DragonflyAnger = Class(function(self, inst)
    self.inst = inst
    self.max = TUNING.DRAGONFLY_ANGER_MAX
    self.current = 0
    self:InitAngerSource()
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function DragonflyAnger:InitAngerSource()
    self.inst:ListenForEvent("attacked", function(inst, data)
        local attacker = data.attacker
        if attacker == nil or not attacker:HasTag("player") then
            self:Delta(TUNING.DRAGONFLY_ANGER_ONHIT_REGEN)
        end
    end)
    self.inst:ListenForEvent("onhitother", function(inst, data)
        self:Delta(TUNING.DRAGONFLY_ANGER_ONATTACK_REGEN)
    end)

    self.rider = nil
    self._OnRiderHitOther = function(rider, data)
        self:Delta(TUNING.DRAGONFLY_ANGER_ONRIDERATTACK_REGEN)
    end
    self.inst:ListenForEvent("riderchanged", function(inst, data)
        local newrider = data.newrider
        if self.rider and self.rider:IsValid() then
            self.inst:RemoveEventCallback("onhitother", self._OnRiderHitOther, self.rider)
        end
        if newrider then
            self.inst:ListenForEvent("onhitother", self._OnRiderHitOther, newrider)
        end
        self.rider = newrider
    end)
end

function DragonflyAnger:SetVal(current)
    self.current = math.clamp(current, 0, self.max)
end

function DragonflyAnger:Delta(delta)
    self.current = math.clamp(self.current + delta, 0, self.max)
end

function DragonflyAnger:OnSave()
    return {
        current = self.current,
    }
end

function DragonflyAnger:OnLoad(data, newents)
    if data ~= nil then
        self.current = data.current or 0
    end
end

return DragonflyAnger
