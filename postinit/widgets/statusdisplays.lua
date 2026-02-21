local AddClassPostConstruct = AddClassPostConstruct

GLOBAL.setfenv(1, GLOBAL)

local DragonflyAngerBadge = require("widgets/dragonfly_anger_badge")

AddClassPostConstruct("widgets/statusdisplays", function(self)
	self.dragonfly_anger_badge = self:AddChild(DragonflyAngerBadge(self.owner))
	self.dragonfly_anger_badge:Hide()

	self.inst:DoTaskInTime(0, function()
		local x1 ,y1 = self.stomach:GetPosition():Get()
		local x2 ,y2 = self.brain:GetPosition():Get()
		local x3 ,y3 = self.heart:GetPosition():Get()
		if y2 == y1 or y2 == y3 then --开了合并状态模组
			self.dragonfly_anger_badge:SetPosition(self.stomach:GetPosition() + Vector3((x1-x2)*2, 0, 0))
		else
			self.dragonfly_anger_badge:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, 0, 0))
		end
	end)

	self.dragonfly_anger_badge:SetPercent(0, TUNING.DRAGONFLY_ANGER_MAX)

	local function UpdateAnger(mount)
	    if mount.dragonfly_classified then
			local max = mount.dragonfly_classified.maxanger:value()
            local current = mount.dragonfly_classified.currentanger:value()
            self.owner:PushEvent("dragonfly_angerdirty", {max = max, current = current})
		end
	end

	local function OnIsRidingDirty()
        local mount = self.owner.replica.rider and self.owner.replica.rider:GetMount()
        if mount and mount:HasTag("dragonfly_mount") then
            UpdateAnger(mount)
            self.dragonfly_anger_badge:Show()
        else
            self.dragonfly_anger_badge:Hide()
        end
	end

	self.inst:ListenForEvent("isridingdirty", function(inst)
	    inst:DoTaskInTime(0, OnIsRidingDirty)
	end, self.owner)

	self.inst:ListenForEvent("dragonfly_angerdirty", function(inst, data)
	    local percent = data.current / data.max
		self.dragonfly_anger_badge:SetPercent(percent, data.max)
	end, self.owner)
end)
