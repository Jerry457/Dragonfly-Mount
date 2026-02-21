local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local DragonflyAngerBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, {200 / 255, 50 / 255, 0 / 255, 1}, "status_dragonfly_anger", nil, nil, true)
    self.circleframe:GetAnimState():OverrideSymbol("frame_circle", "status_dragonfly_anger", "frame_circle")
    -- self.backing:GetAnimState():OverrideSymbol("bg", "bloodthirsty", "bg")
end)

function DragonflyAngerBadge:SetPercent(percent, max)
    Badge.SetPercent(self, percent, max)
    if self.oldpercent then
        if percent > self.oldpercent then
            self:PulseGreen()
        elseif percent < self.oldpercent then
            self:PulseRed()
        end
    end
    self.oldpercent = percent
end

return DragonflyAngerBadge
