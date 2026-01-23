local SPELLBOOK_RADIUS = 70
local ICON_SCALE = 0.5
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

-- local function CheckNotRiding(player)
--     --client safe
--     local rider = player and player.replica.rider
--     return not (rider and rider:IsRiding())
-- end

local SKILL_DEFS =
{
    -- BLINK = {
    --     label = STRING.BLINK,
    --     onselect = function(inst)
    --         local spellbook = inst.components.spellbook
    --         spellbook.closeonexecute = false
    --         if ThePlayer then
    --             if ThePlayer.mad_mita_blink_disabled then
    --                 ThePlayer.mad_mita_blink_disabled = false
    --             else
    --                 ThePlayer.mad_mita_blink_disabled = true
    --             end
    --         end
    --         -- 这里写双端内容
    --         if TheWorld.ismastersim then

    --         end
    --     end,
    --     execute = function(inst) end,
	-- 	bank = "spell_icons_mad_mita",
	-- 	build = "spell_icons_mad_mita",
	-- 	anims =
	-- 	{
	-- 		idle = { anim = "blink" },
	-- 		focus = { anim = "blink_focus" },
	-- 		down = { anim = "blink_pressed" },
	-- 		disabled = { anim = "blink_disabled" },
	-- 		cooldown = { anim = "blink_cooldown" },
	-- 	},
    --     checkenabled = function(player)
    --         return true
    --     end,
    --     widget_scale = ICON_SCALE,
    --     unlock_stage = 1,
    --     sort_order = 0,
    --     postinit = function(w)
    --         if ThePlayer and ThePlayer.mad_mita_blink_disabled then
    --             w.animstate:Show("lock")
    --         else
    --             w.animstate:Hide("lock")
    --         end

    --         local onclick = w.onclick
    --         w.onclick = function(...)
    --             onclick(...)
    --             if ThePlayer and ThePlayer.mad_mita_blink_disabled then
    --                 w.animstate:Show("lock")
    --             else
    --                 w.animstate:Hide("lock")
    --             end
    --         end
    --     end,
    -- },
    -- DRINK_BLOOD = {
    --     label = STRING.DRINK_BLOOD,
    --     onselect = function(inst)
    --         inst.miside_deststate = function() -- action对应的sg
    --             return "quickeat"
    --         end
    --         local spellbook = inst.components.spellbook
    --         spellbook.closeonexecute = true
    --         -- 这里写双端内容
    --         if TheWorld.ismastersim then
    --             -- 这里写主机内容
    --             spellbook:SetSpellFn(function(inst, player)
    --                 local current = player.components.bloodthirsty:GetCurrent()
    --                 if current > 0 then
    --                     local health = player.components.health
    --                     local health_lost = health.maxhealth - health.currenthealth

    --                     local need = health_lost / TUNING.MAD_MITA_GET_HEALTH_FROM_BLOODTHIRSTY_PROPORTION
    --                     local consume = math.min(need, current)

    --                     player.components.bloodthirsty:DoDelta(-consume)
    --                     player.components.health:DoDelta(consume * TUNING.MAD_MITA_GET_HEALTH_FROM_BLOODTHIRSTY_PROPORTION, nil, nil, true)
    --                     return true
    --                 end
    --                 return false, "NOT_ENOUGH_BLOOD_THIRSTY"
    --             end)
    --         end
    --     end,
    --     execute = ExecuteSpell, -- 按下按钮[主机]和[客机]都立刻执行onselect
	-- 	bank = "spell_icons_mad_mita",
	-- 	build = "spell_icons_mad_mita",
	-- 	anims =
	-- 	{
	-- 		idle = { anim = "drink_blood" },
	-- 		focus = { anim = "drink_blood_focus" },
	-- 		down = { anim = "drink_blood_pressed" },
	-- 		disabled = { anim = "drink_blood_disabled" },
	-- 		cooldown = { anim = "drink_blood_cooldown" },
	-- 	},
    --     checkenabled = function(player)
    --         local health = player.replica.health
    --         return health and health:GetPercent() < 1
    --     end,
    --     checkcooldown = CheckCooldown("mad_mita_drink_blood"),
	-- 	cooldowncolor = COOLDOWN_COLOR,
    --     widget_scale = ICON_SCALE,
    --     hotkey = TUNING.MAD_MITA_SKILL_DRINK_BLOOD,
    --     unlock_stage = 1,
    --     sort_order = 1,
    -- },
    -- GLITCH_EFFECT = {
    --     label = STRING.GLITCH_EFFECT.."("..TUNING.MAD_MITA_GLITCH_EFFECT_BLOOD_THIRSTY_COSTS..STRING.BLOOD_THIRSTY..")",
    --     onselect = function(inst)
    --         -- 这里写双端内容
    --         inst.miside_deststate = function() -- action对应的sg
    --             return "mad_mita_glitch_effect"
    --         end
    --         local spellbook = inst.components.spellbook
    --         spellbook.closeonexecute = true
    --         local aoetargeting = inst.components.aoetargeting

    --         spellbook:SetSpellName("错误化")

    --         aoetargeting:SetRange(12)
    --         aoetargeting:SetDeployRadius(0)

    --         aoetargeting:SetShouldRepeatCastFn(nil)
    --         aoetargeting:SetAlwaysValid(true)
    --         aoetargeting:SetAllowWater(true)
    --         aoetargeting:SetAllowRiding(true)

    --         aoetargeting.reticule.validcolour = {1, 0.2, 0, 1}
    --         aoetargeting.reticule.invalidcolour = {0.75, 0.15, 0, 1}
    --         aoetargeting.reticule.reticuleprefab = "reticuleaoe_mad_mita_glitch_effect"
    --         aoetargeting.reticule.pingprefab = "reticuleaoe_mad_mita_glitch_effect_ping"

    --         aoetargeting.reticule.mousetargetfn = nil
    --         aoetargeting.reticule.targetfn = nil 
    --         aoetargeting.reticule.updatepositionfn = nil

    --         if TheWorld.ismastersim then
    --             -- 这里写主机内容
    --             inst.components.aoespell:SetSpellFn(function(inst, player, pos)
    --                 local current = player.components.bloodthirsty:GetCurrent()
    --                 if current >= TUNING.MAD_MITA_GLITCH_EFFECT_BLOOD_THIRSTY_COSTS then
    --                     player.components.bloodthirsty:DoDelta(-TUNING.MAD_MITA_GLITCH_EFFECT_BLOOD_THIRSTY_COSTS)
    --                     -- success
    --                     local ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.MAD_MITA_GLITCH_EFFECT_RADIUS, {"_combat","_health"}, {"INLIMBO", "companion", "wall"})
    --                     for i, ent in ipairs(ents) do
    --                         if TargetTestFn(ent, player) then
    --                             if ent.components.glitcheffect == nil then
    --                                 ent:AddComponent("glitcheffect")
    --                             end
    --                             ent.components.glitcheffect:Start(TUNING.MAD_MITA_GLITCH_EFFECT_DURATION)
    --                             ent:PushEvent("epicscare", {scarer = player, duration = 5})
    --                         end
    --                     end
    --                     return true
    --                 end
    --                 -- fail
    --                 return false, "NOT_ENOUGH_BLOOD_THIRSTY"
    --             end)
    --         end
    --     end,
    --     execute = StartAOETargeting, --按下按钮[客机]立刻执行onselect，并显示范围指示器，确定使用技能后[主机]执行onselect
	-- 	bank = "spell_icons_mad_mita",
	-- 	build = "spell_icons_mad_mita",
	-- 	anims =
	-- 	{
	-- 		idle = { anim = "glitch_effect" },
	-- 		focus = { anim = "glitch_effect_focus" },
	-- 		down = { anim = "glitch_effect_pressed" },
	-- 		disabled = { anim = "glitch_effect_disabled" },
	-- 		cooldown = { anim = "glitch_effect_cooldown" },
	-- 	},
    --     checkenabled = nil,
    --     widget_scale = ICON_SCALE,
    --     hotkey = TUNING.MAD_MITA_SKILL_GLITCH_EFFECT,
    --     unlock_stage = 2,
    --     sort_order = 2,
    -- },
    TAUNT = {
        label = STRINGS.DRAGONFLY_SKILLS.TAUNT,
        onselect = function(inst)
            -- 这里写双端内容
            inst.spell_deststate = function(player, act) -- action对应的sg
                return "dragonfly_taunt"
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
                inst.components.aoespell:SetSpellFn(function(inst, player, pos)
                    if player.components.spellbookcooldowns then
                        player.components.spellbookcooldowns:RestartSpellCooldown("dragonfly_taunt", TUNING.DRAGONFLY_TAUNT_SKILL_COOLDOWN)
                    end
                    return true
                end)
            end
        end,
        execute = StartAOETargeting, --按下按钮[客机]立刻执行onselect，并显示范围指示器，确定使用技能后[主机]执行onselect
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "lunar_fire" },
			focus = { anim = "lunar_fire_focus", loop = true },
			down = { anim = "lunar_fire_pressed" },
			disabled = { anim = "lunar_fire_disabled" },
			cooldown = { anim = "lunar_fire_cooldown" },
		},
		checkenabled = function(player) return true end,
        checkcooldown = CheckCooldown("dragonfly_taunt"),
        cooldowncolor = COOLDOWN_COLOR,
        widget_scale = ICON_SCALE,
        sort_order = 3,
    },
    -- DARK_WORLD = {
    --     label = STRING.DARK_WORLD.."("..TUNING.MAD_MITA_DARK_WORLD_BLOOD_THIRSTY_COSTS..STRING.BLOOD_THIRSTY..")",
    --     onselect = function(inst)
    --         inst.miside_deststate = function() -- action对应的sg
    --             return "mad_mita_dark_world"
    --         end
    --         local spellbook = inst.components.spellbook
    --         spellbook.closeonexecute = true
    --         -- 这里写双端内容
    --         if TheWorld.ismastersim then
    --             -- 这里写主机内容
    --             spellbook:SetSpellFn(function(inst, player)
    --                 if player.sg.currentstate.name == "mad_mita_dark_world" then
    --                     local current = player.components.bloodthirsty:GetCurrent()
    --                     if current >= TUNING.MAD_MITA_DARK_WORLD_BLOOD_THIRSTY_COSTS then
    --                         player.components.bloodthirsty:DoDelta(-TUNING.MAD_MITA_DARK_WORLD_BLOOD_THIRSTY_COSTS)
    --                         player.components.spellbookcooldowns:RestartSpellCooldown("mad_mita_dark_world", TUNING.MAD_MITA_DARK_WORLD_COOLDOWN)
    --                         -- success
    --                         player.sg:GoToState("mad_mita_dark_world_internal")
    --                         return true
    --                     end
    --                 end
    --                 -- fail
    --                 player.sg:GoToState("idle")
    --                 return false, "NOT_ENOUGH_BLOOD_THIRSTY"
    --             end)
    --         end
    --     end,
    --     execute = ExecuteSpell, -- 按下按钮[主机]和[客机]都立刻执行onselect
	-- 	bank = "spell_icons_mad_mita",
	-- 	build = "spell_icons_mad_mita",
	-- 	anims =
	-- 	{
	-- 		idle = { anim = "dark_world" },
	-- 		focus = { anim = "dark_world_focus" },
	-- 		down = { anim = "dark_world_pressed" },
	-- 		disabled = { anim = "dark_world_disabled" },
	-- 		cooldown = { anim = "dark_world_cooldown" },
	-- 	},
    --     checkenabled = function(player) return CheckNotRiding(player) and CheckNotInRoom(player) end,
    --     checkcooldown = CheckCooldown("mad_mita_dark_world"),
	-- 	cooldowncolor = COOLDOWN_COLOR,
    --     widget_scale = ICON_SCALE,
    --     hotkey = TUNING.MAD_MITA_SKILL_DARK_WORLD,
    --     unlock_stage = 4,
    --     sort_order = 4,
    -- },
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