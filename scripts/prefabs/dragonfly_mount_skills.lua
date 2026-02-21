local SPELLBOOK_RADIUS = 70
local ICON_SCALE = 0.6
local COOLDOWN_COLOR = {0.5, 0.5, 0.5, 0.75}

local function StartAOETargeting(inst)
    local playercontroller = ThePlayer.components.playercontroller
    if playercontroller then
        playercontroller:StartAOETargetingUsing(inst)
    end
end

local function ExecuteSpell(inst)
    local inventory = ThePlayer.replica.inventory
    if inventory then
        inventory:CastSpellBookFromInv(inst)
    end
end

local function TargetTestFn(target, inst)
    return target.components.combat and target.components.combat:CanBeAttacked(inst) and
    (not inst.components.combat:IsAlly(target)) and
    target.components.health and (not target.components.health:IsDead())
end

local function CenterReticuleUpdatePosition(inst, pos, reticule, ease, smoothing, dt)
    reticule.Transform:SetPosition(inst.Transform:GetWorldPosition())
    reticule.Transform:SetRotation(0)
end

local function CheckCooldown(spell_name)
    return function(player)
        --client safe
        return player
            and player.components.spellbookcooldowns
            and player.components.spellbookcooldowns:GetSpellCooldownPercent(spell_name)
            or nil
    end
end

local function TauntSpell(inst, player, pos)
    local spellbookcooldowns = player.components.spellbookcooldowns
    if spellbookcooldowns then
        if spellbookcooldowns:IsInCooldown("dragonfly_taunt") then
            player.sg:GoToState("idle")
            return false
        end
        spellbookcooldowns:RestartSpellCooldown("dragonfly_taunt", TUNING.DRAGONFLY_TAUNT_SKILL_COOLDOWN)
    end
    player.sg:GoToState("dragonfly_taunt")
    return true
end

local SKILL_DEFS =
{
    TAUNT = {
        label = STRINGS.DRAGONFLY_SKILLS.TAUNT,
        onselect = function(inst)
            -- 这里写双端内容
            inst.spell_deststate = function(player, act) -- action对应的sg
                if TheWorld.ismastersim then
                    return "dragonfly_taunt_pre"
                else
                    return "dragonfly_taunt"
                end
            end

            local spellbook = inst.components.spellbook
            spellbook.closeonexecute = true
            local aoetargeting = inst.components.aoetargeting

            spellbook:SetSpellName(STRINGS.DRAGONFLY_SKILLS.TAUNT)

            aoetargeting:SetRange(8)
            aoetargeting:SetDeployRadius(0)

            aoetargeting:SetShouldRepeatCastFn(nil)
            aoetargeting:SetAlwaysValid(true)
            aoetargeting:SetAllowWater(true)
            aoetargeting:SetAllowRiding(true)

            aoetargeting.reticule.validcolour = {1, 1, 0, 1}
            aoetargeting.reticule.invalidcolour = {0.75, 0.15, 0, 1}
            aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            aoetargeting.reticule.pingprefab = "reticulemultitargetping"

            aoetargeting.reticule.mousetargetfn = function(inst) return inst:GetPosition() end
            aoetargeting.reticule.targetfn = nil
            aoetargeting.reticule.updatepositionfn = CenterReticuleUpdatePosition

            if TheWorld.ismastersim then
                -- 这里写主机内容
                inst.components.aoespell:SetSpellFn(TauntSpell)
            end
        end,
        execute = StartAOETargeting, --按下按钮[客机]立刻执行onselect，并显示范围指示器，确定使用技能后[主机]执行onselect
		bank = "spell_icons_dragonfly",
		build = "spell_icons_dragonfly",
		anims =
		{
			idle = { anim = "taunt" },
			focus = { anim = "taunt_focus", loop = true },
			down = { anim = "taunt_pressed" },
			disabled = { anim = "taunt_disabled" },
			cooldown = { anim = "taunt_cooldown" },
		},
		checkenabled = function(player) return true end,
        checkcooldown = CheckCooldown("dragonfly_taunt"),
        cooldowncolor = COOLDOWN_COLOR,
        widget_scale = ICON_SCALE,
        sort_order = 1,
    },
    TRANSFORM = {
        label = STRINGS.DRAGONFLY_SKILLS.TRANSFORM,
        onselect = function(inst)
            -- 这里写双端内容
            inst.spell_deststate = function(player, act) -- action对应的sg
                if TheWorld.ismastersim then
                    return "dragonfly_taunt_pre"
                else
                    return "dragonfly_taunt"
                end
            end

            local spellbook = inst.components.spellbook
            spellbook.closeonexecute = true
            local aoetargeting = inst.components.aoetargeting

            spellbook:SetSpellName(STRINGS.DRAGONFLY_SKILLS.TRANSFORM)

            aoetargeting:SetRange(8)
            aoetargeting:SetDeployRadius(0)

            aoetargeting:SetShouldRepeatCastFn(nil)
            aoetargeting:SetAlwaysValid(true)
            aoetargeting:SetAllowWater(true)
            aoetargeting:SetAllowRiding(true)

            aoetargeting.reticule.validcolour = {1, 1, 0, 1}
            aoetargeting.reticule.invalidcolour = {0.75, 0.15, 0, 1}
            aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            aoetargeting.reticule.pingprefab = "reticulemultitargetping"

            aoetargeting.reticule.mousetargetfn = function(inst) return inst:GetPosition() end
            aoetargeting.reticule.targetfn = nil
            aoetargeting.reticule.updatepositionfn = CenterReticuleUpdatePosition

            if TheWorld.ismastersim then
                -- 这里写主机内容
                inst.components.aoespell:SetSpellFn(TauntSpell)
            end
        end,
        execute = StartAOETargeting, --按下按钮[客机]立刻执行onselect，并显示范围指示器，确定使用技能后[主机]执行onselect
		bank = "spell_icons_dragonfly",
		build = "spell_icons_dragonfly",
		anims =
		{
			idle = { anim = "taunt" },
			focus = { anim = "taunt_focus", loop = true },
			down = { anim = "taunt_pressed" },
			disabled = { anim = "taunt_disabled" },
			cooldown = { anim = "taunt_cooldown" },
		},
		checkenabled = function(player) return true end,
        checkcooldown = CheckCooldown("dragonfly_taunt"),
        cooldowncolor = COOLDOWN_COLOR,
        widget_scale = ICON_SCALE,
        sort_order = 1,
    },
}

local function GetUnlockedSkills(inst)
    local skills = {}
    for NAME, SKILL_DEF in pairs(SKILL_DEFS) do
        table.insert(skills, SKILL_DEF)
    end
    table.sort(skills, function(l, r) return l.sort_order < r.sort_order end)
    return skills
end

local function OnOpenSpellBook(inst)
    TheFocalPoint.SoundEmitter:PlaySound("meta3/willow/ember_container_open","willow_ember_open")
end

local function OnCloseSpellBook(inst)
    TheFocalPoint.SoundEmitter:KillSound("willow_ember_open")
end

local function CanUseSpellBook(inst, player)
    local rider = player and player.replica.rider
    local mount = rider and rider:GetMount()
    if mount == inst then
        return true
    end
end

local function StartTargeting(self, ...)
    if self.inst.components.reticule == nil then
        local owner = ThePlayer
        if owner and owner.components.playercontroller ~= nil then
            self.inst:AddComponent("reticule")
            for k, v in pairs(self.reticule) do
                self.inst.components.reticule[k] = v
            end
            owner.components.playercontroller:RefreshReticule(self.inst)
        end
    end
end

local function CanCast(self, doer, pos)
    if not self.spellfn then
        return false
    end

    if self.inst.components.spellbook then
        if not self.inst.components.spellbook:CanBeUsedBy(doer) then
            return false
        end
    end

    local alwayspassable, allowwater, deployradius --, allowriding
    local aoetargeting = self.inst.components.aoetargeting
    if aoetargeting then
        if not aoetargeting:IsEnabled() then
            return false
        end
        alwayspassable = aoetargeting.alwaysvalid
        allowwater = aoetargeting.allowwater
        deployradius = aoetargeting.deployradius
        -- allowriding = aoetargeting.allowriding
    end

    -- if not allowriding and doer.components.rider ~= nil and doer.components.rider:IsRiding() then
    --     return false
    -- end

    return TheWorld.Map:CanCastAtPoint(pos, alwayspassable, allowwater, deployradius)
end

local function SetupDragonflyMountSpell(inst)
    local skills = GetUnlockedSkills(inst)
    if next(skills) == nil then return end

    inst:AddTag("dragonfly_spellbook")

    local spellbook = inst:AddComponent("spellbook")
    -- spellbook:SetRequiredTag("")
    spellbook:SetRadius(SPELLBOOK_RADIUS)
    spellbook:SetFocusRadius(SPELLBOOK_RADIUS)
    spellbook:SetItems(skills)
    spellbook:SetOnOpenFn(OnOpenSpellBook)
    spellbook:SetOnCloseFn(OnCloseSpellBook)
    spellbook:SetCanUseFn(CanUseSpellBook)

    spellbook.closesound = "meta3/willow/ember_container_close"
    inst:UnregisterComponentActions("spellbook") -- 移除动作收集

    local aoetargeting = inst:AddComponent("aoetargeting")
    aoetargeting:SetAllowWater(true)
    aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    aoetargeting.reticule.ease = true
    aoetargeting.reticule.mouseenabled = true
    -- new StartTargeting
    aoetargeting.StartTargeting = StartTargeting


    if not TheWorld.ismastersim then
        return
    end

    local aoespell = inst:AddComponent("aoespell")
    -- new CanCast
    aoespell.CanCast = CanCast
end

return {
    SetupDragonflyMountSpell = SetupDragonflyMountSpell,
}
