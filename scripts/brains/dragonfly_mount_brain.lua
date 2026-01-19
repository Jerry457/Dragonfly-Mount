require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/runaway"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/chaseandattack"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 16
local TARGET_FOLLOW_DIST = 8

local SEE_MONSTER_DIST = 8
local AVOID_MONSTER_STOP = 14

local DROP_TARGET_DIST = 20

local DragonflyMountBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldGotoLeader(inst)
    if not inst.goto_leader then
        return false
    end
    local leader = inst.components.follower.leader
    if not (leader and leader:IsValid()) then
        inst.goto_leader = false
        return false
    end
    return true
end

local function GetLeaderPos(inst)
    local leader = inst.components.follower.leader
    if leader and leader:IsValid() then
        return leader:GetPosition()
    else
        return inst:GetPosition()
    end
end

local function ShouldDropTarget(inst)
    local leader = inst.components.follower.leader
    if leader and leader:IsValid() then
        if not inst:IsNear(leader, DROP_TARGET_DIST) then
            inst.components.combat:SetTarget(nil)
            return true
        end
    end
end

local function IsTargetAttacking(inst)
    local targetmem = inst.targetmem
    local sgname = targetmem.sgname
    local timeinstate = targetmem.timeinstate

    if not sgname or not timeinstate then
        return false
    end

    -- 根据标签判断
    local attacking = targetmem.attacking and not targetmem.already_attack

    -- 根据历史受击判断
    if not attacking and targetmem.inst_attacked[sgname] then
        local attacked_timeinstate = targetmem.inst_attacked[sgname].timeinstate
        attacking = timeinstate < (attacked_timeinstate)
    end

    -- 根据事件信息判断
    if not attacking and targetmem.attackother_sg[sgname] then
        local attackother_timeinstate = targetmem.attackother_sg[sgname].timeinstate
        attacking = timeinstate < (attackother_timeinstate)
    end

    return attacking
end

local function GetDangerRangeSq(inst)
    local targetmem = inst.targetmem

    -- 粗略估计用数据
    local hitrange = targetmem.hitrange or 1
    local physicsrange = inst.physicsrange or 0.5
    local guess_hit_range = hitrange + physicsrange
    local danger_range = guess_hit_range

    local danger_range_sq = danger_range * danger_range

    -- 根据历史受伤数据计算
    local sgname = targetmem.sgname
    if sgname and targetmem.inst_attacked[sgname] then
        local attacked_distsq = targetmem.inst_attacked[sgname].distsq
        danger_range_sq = math.max(danger_range_sq, attacked_distsq)
    end

    return danger_range_sq
end

local function IsInDangerRange(inst)
    local targetmem = inst.targetmem
    if not targetmem.target then
        return false
    end

    local distsq = targetmem.distsq or 1e6
    local danger_range_sq = targetmem.danger_range_sq or GetDangerRangeSq(inst)
    local in_danger_range = distsq < danger_range_sq * 1.05
    return in_danger_range
end

local function IsFarFromTarget(inst)
    local targetmem = inst.targetmem
    if not targetmem.target then
        return false
    end

    local distsq = targetmem.distsq or 1e6
    local danger_range_sq = targetmem.danger_range_sq or GetDangerRangeSq(inst)
    local far_from_target = distsq > danger_range_sq * 1.35
    return far_from_target
end

local function ShouldRunaway(inst)
    local targetmem = inst.targetmem
    local target = targetmem.target
    if not target then
        return false
    end

    -- 强制停止逃跑
    if inst.stoprunaway and inst.stoprunaway > 0 then
        inst.stoprunaway = inst.stoprunaway - 1
        return false
    end

    -- 目标没有战斗组件
    local target_combat = targetmem.target_combat
    if target_combat == nil then
        return false
    end

    -- 目标的目标不是自己
    if target_combat.target ~= inst and not targetmem.epic then
        return false
    end

    -- 目标是远程
    if targetmem.projectile then
        return false
    end

    -- 不在危险范围
    local time = GetTime()
    local in_danger_range = IsInDangerRange(inst)
    if not in_danger_range then
        -- 刚逃出范围
        if inst.old_shouldrunaway then
            inst.standstill = 2
        end
        -- 目标长时间未成功展开攻击
        local resume = targetmem.resume_cooldown_time
        if resume and (time - resume > 2) then
            inst.stoprunaway = 3
        end
        return false
    end

    -- 在危险范围且目标无敌
    if targetmem.invincible then
        return true
    end

    -- 目标正在攻击
    local really_attacking = targetmem.really_attacking

    -- 如果没在攻击，是否将要攻击
    local abouttoattack = false
    local cooldown = targetmem.cooldown or 2
    if not really_attacking then
        if (targetmem.sgname == "taunt" and not targetmem.epic) or (target.sg and target.sg:HasStateTag("nointerrupt")) then
            local busytime = target.AnimState and (target.AnimState:GetCurrentAnimationLength() - target.AnimState:GetCurrentAnimationTime()) or 0
            cooldown = math.max(cooldown, busytime)
        end
        abouttoattack = cooldown < targetmem.run_ahead_time
    end

    local shouldrunaway = (really_attacking or abouttoattack)
    -- 不需要再站定了
    if not shouldrunaway then
        inst.standstill = 0
    end
    return shouldrunaway
end

local function ShouldStandStill(inst)
    local targetmem = inst.targetmem
    if not targetmem.target then
        return false
    end

    -- 强制站定
    if inst.standstill and inst.standstill > 0 then
        return true
    end

    -- 目标远程攻击
    if targetmem.projectile then
        return false
    end

    -- 站定等待目标攻击结束
    local really_attacking = targetmem.really_attacking
    local in_danger_range = IsInDangerRange(inst)
    local far_from_target = IsFarFromTarget(inst)

    if really_attacking and (not in_danger_range) and (not far_from_target) then
        return true
    end
end

local function WatchTargetCombat(inst)
    if inst.components.rideable and inst.components.rideable:IsBeingRidden() then
        return
    end

    local target = inst.targetmem.target
    if target == nil then return end

    local target_combat = target.components.combat
    if target_combat == nil then return end
    inst.targetmem.target_combat = target_combat

    local time = GetTime()
    local cooldown = target_combat:GetCooldown()
    local old_cooldown = inst.targetmem.cooldown

    -- 冷却转好的时间
    if old_cooldown and old_cooldown > 0 and cooldown <= 0 then
        inst.targetmem.resume_cooldown_time = time
    elseif cooldown > 0 then
        inst.targetmem.resume_cooldown_time = nil
    end
    inst.targetmem.cooldown = cooldown

    -- 攻击范围数据
    inst.targetmem.attackrange = target_combat.attackrange
    inst.targetmem.hitrange = target_combat.hitrange
    inst.targetmem.areahitrange = target_combat.areahitrange
    inst.targetmem.min_attack_period = target_combat.min_attack_period
    inst.targetmem.temprange = target_combat.temprange

    local sg = target.sg
    if sg then
        -- 正在攻击
        if sg:HasStateTag("attack") then
            inst.targetmem.attacking = true
        else
            inst.targetmem.attacking = false
        end

        local sgname = sg.currentstate.name
        local timeinstate = sg.timeinstate

        -- 上个sgname以及重置already_attack
        if sgname ~= inst.targetmem.sgname then
            inst.targetmem.already_attack = false
            inst.targetmem.last_sgname = inst.targetmem.sgname
        end

        -- sgname和timeinstate
        inst.targetmem.sgname = sgname
        inst.targetmem.timeinstate = timeinstate
    end

    -- 当前距离
    local distsq = inst:GetDistanceSqToInst(target)
    inst.targetmem.distsq = distsq

    -- 当前武器和飞行道具
    local weapon = target_combat:GetWeapon()
    inst.targetmem.weapon = weapon
    inst.targetmem.projectile = weapon and weapon.components.weapon.projectile

    -- 危险范围平方
    inst.targetmem.danger_range_sq = GetDangerRangeSq(inst)
    -- 确信正在攻击
    inst.targetmem.really_attacking = IsTargetAttacking(inst)
end

local TRAINING_DATA = require("brains/training_data")

local function InitTargetMem(inst, target)

    local old_target = inst.targetmem and inst.targetmem.target
    -- backup
    if old_target and old_target.prefab then
        local prefab = old_target.prefab
        if TRAINING_DATA[prefab] == nil then
            TRAINING_DATA[prefab] = {}
        end
        -- backup attackother_sg
        if TRAINING_DATA[prefab].attackother_sg == nil then
            TRAINING_DATA[prefab].attackother_sg = {}
        end
        for sgname, data in pairs(inst.targetmem.attackother_sg) do
            TRAINING_DATA[prefab].attackother_sg[sgname] = data
        end
        -- backup inst_attacked
        if TRAINING_DATA[prefab].inst_attacked == nil then
            TRAINING_DATA[prefab].inst_attacked = {}
        end
        for sgname, data in pairs(inst.targetmem.inst_attacked) do
            TRAINING_DATA[prefab].inst_attacked[sgname] = data
        end
    end

    local attackother_sg = {}
    local inst_attacked = {}
    local run_ahead_time = 0.05

    if target and target.prefab and TRAINING_DATA[target.prefab] then
        attackother_sg = TRAINING_DATA[target.prefab].attackother_sg or attackother_sg
        inst_attacked = TRAINING_DATA[target.prefab].inst_attacked or inst_attacked
        run_ahead_time = TRAINING_DATA[target.prefab].run_ahead_time or run_ahead_time
    end

    inst.targetmem = {
        target = target,
        epic = target and target:HasTag("epic"),
        physicsrange = target and target:GetPhysicsRadius(0),
        attackother_sg = attackother_sg,
        inst_attacked = inst_attacked,
        run_ahead_time = run_ahead_time,
    }

    WatchTargetCombat(inst)
end

local function PostInitCombat(inst)
    InitTargetMem(inst)
    local combat = inst.components.combat

    -- attack or miss or areaattack
    inst._ontargetattackother = function(target, data)
        inst.targetmem.last_attackother_time = GetTime()
        inst.targetmem.last_attackother_target = data.target
        inst.targetmem.already_attack = true
        local sg = target.sg
        if sg then
            local sgname = sg.currentstate.name
            local timeinstate = sg.timeinstate

            inst.targetmem.attackother_sg[sgname] = {
                timeinstate = timeinstate,
            }

            inst.targetmem.last_attackother_sgname = sgname
            inst.targetmem.last_attackother_timeinstate = timeinstate
        end
    end

    -- on invincibletoggle
    inst._ontargetinvincibletoggle = function(target, data)
        inst.targetmem.invincible = data.invincible
    end

    -- on remove
    inst._ontargetremove = function(target)
        InitTargetMem(inst)
    end

    -- listen target event
    local _SetTarget = combat.SetTarget
    combat.SetTarget = function(combat, ...)
        _SetTarget(combat, ...)

        local target = combat.target
        local old_target = inst.targetmem.target
        if old_target == target then return end

        if old_target and old_target:IsValid() then
            inst:RemoveEventCallback("onattackother", inst._ontargetattackother, old_target)
            inst:RemoveEventCallback("onmissother", inst._ontargetattackother, old_target)
            inst:RemoveEventCallback("onareaattackother", inst._ontargetattackother, old_target)
            inst:RemoveEventCallback("invincibletoggle", inst._ontargetinvincibletoggle, old_target)
            inst:RemoveEventCallback("onremove", inst._ontargetremove, old_target)
        end

        if target then
            inst:ListenForEvent("onattackother", inst._ontargetattackother, target)
            inst:ListenForEvent("onmissother", inst._ontargetattackother, target)
            inst:ListenForEvent("onareaattackother", inst._ontargetattackother, target)
            inst:ListenForEvent("invincibletoggle", inst._ontargetinvincibletoggle, target)
            inst:ListenForEvent("onremove", inst._ontargetremove, target)
        end

        InitTargetMem(inst, target)
    end

    -- watch target task
    inst.watch_target_combat_task = inst:DoPeriodicTask(0, WatchTargetCombat)

    -- get attacked
    inst:ListenForEvent("attacked", function(inst, data)
        if inst.components.rideable and inst.components.rideable:IsBeingRidden() then
            return
        end

        local attacker = data.attacker
        if not attacker or attacker.sg == nil or attacker ~= inst.targetmem.target then
            return
        end

        local sgname = inst.targetmem.sgname
        if not sgname then
            return
        end

        local timeinstate = inst.targetmem.timeinstate
        local distsq = inst.targetmem.distsq

        local inst_attacked = inst.targetmem.inst_attacked
        if inst_attacked[sgname] == nil then
            inst_attacked[sgname] = {}
        end

        inst_attacked[sgname].timeinstate = timeinstate
        inst_attacked[sgname].distsq = math.max(distsq, inst_attacked[sgname].distsq or 0)
    end)

    -- inst mem
    inst.standstill = 0
    inst.stoprunaway = 0
    inst.physicsrange = inst:GetPhysicsRadius(0.5)
end

function DragonflyMountBrain:OnStart()
    local inst = self.inst
    if not inst.targetmem then
        PostInitCombat(inst)
    end

    -- GotoLeader
    local GotoLeader = WhileNode(
        function()
            return ShouldGotoLeader(inst)
        end,
        "GotoLeader",
        SequenceNode{
            ActionNode(function() inst.components.combat:SetTarget(nil) end),
            ParallelNodeAny{
                WaitNode(4), -- TIMEOUT
                SequenceNode{
                    Leash(inst, GetLeaderPos, 0, 2, false),
                    ActionNode(function() inst.components.locomotor:Stop() end),
                    WaitNode(0.5),
                },
            },
            ActionNode(function() inst.goto_leader = false end),
        }
    )

    -- CombatBehavior
    local runaway = WhileNode(
        function()
            local shouldrunaway = ShouldRunaway(inst)
            if shouldrunaway and not inst.sg:HasStateTag("moving") then
                inst.sg:AddStateTag("idle")
            end
            inst.old_shouldrunaway = shouldrunaway
            return shouldrunaway
        end,
        "Runaway",
        RunAway(inst, function(ent, inst) return inst.components.combat:TargetIs(ent) end, SEE_MONSTER_DIST, AVOID_MONSTER_STOP)
    )

    local standstill = WhileNode(
        function()
            return ShouldStandStill(inst)
        end,
        "Stand",
        ActionNode(function()
            inst.components.locomotor:Stop()
            if inst.standstill then
                inst.standstill = inst.standstill - 1
            end
        end)
    )

    local attack = WhileNode(
        function()
            if inst.targetmem.invincible then
                return false
            end
            return not ShouldDropTarget(inst)
        end,
        "Attack",
        ChaseAndAttack(inst)
    )

    local CombatBehavior = WhileNode(
        function()
            return inst.targetmem.target ~= nil
        end,
        "CombatBehavior",
        PriorityNode({
            runaway,
            standstill,
            attack
        }, 0.1)
    )

    -- WaitBellLink
    local WaitBellLink = WhileNode(
        function()
            return inst.is_writing
        end,
        "WaitBellLink",
        ActionNode(function()
            inst.components.locomotor:Stop()
        end)
    )

    -- root
    local root =
    PriorityNode(
    {
        GotoLeader,
        CombatBehavior,
        WaitBellLink,
        Follow(inst, function() return inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        Wander(inst, function() return GetLeaderPos(inst) end, MAX_FOLLOW_DIST)
    }, 0.1)

    self.bt = BT(inst, root)
    self.bt.GetSleepTime = function() return 0 end

end

return DragonflyMountBrain
