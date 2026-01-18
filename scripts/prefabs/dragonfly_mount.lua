local function PotentialRiderTest(inst, potential_rider)
    if not inst.components.rideable:IsSaddled() then
        local talker = potential_rider.components.talker
        if talker then
            talker:Say(GetString(potential_rider, "ANNOUNCE_DRAGONFLY_NEED_SADDLE"))
        end
        return false
    end

    local leader = inst.components.follower:GetLeader()
    if leader == nil or leader.components.inventoryitem == nil then
        return true
    end

    local leader_owner = leader.components.inventoryitem:GetGrandOwner()
    return (leader_owner == nil or leader_owner == potential_rider)
end

local function ApplyBuildOverrides(inst, animstate)
    local basebuild = "dragonfly_mount_fire_build"
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:SetBank("wilsondragonfly")
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end

end

local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild("dragonfly_mount_fire_build")
    end
end

local WRITE_TIMEOUT = 20

local function SetDragonflyBellOwner(inst, bell, bell_user)
    if inst.components.follower:GetLeader() == nil and bell ~= nil and bell.components.leader ~= nil then
        bell.components.leader:AddFollower(inst)
        inst.components.rideable:SetShouldSave(false)

        -- if bell:HasTag("shadowbell") then
        --     -- NOTES(DiogoW): Removing event callback set by leader:AddFollower
        --     bell:RemoveEventCallback("death", bell.components.leader._onfollowerdied, inst)

        --     if inst.components.burnable ~= nil then
        --         inst.components.burnable.nocharring = true
        --     end
        -- end

        inst:ListenForEvent("onremove", inst._BellRemoveCallback, bell)

        inst.persists = false
        inst:UpdateDomestication()
        -- inst.components.knownlocations:ForgetLocation("herd")

        if bell_user ~= nil then
            inst.is_writing = true
            inst.components.writeable:BeginWriting(bell_user)
            inst:DoTaskInTime(WRITE_TIMEOUT, function(inst)
                inst.is_writing = false
            end)

        end

        return true
    else
        return false, "ALREADY_USED"
    end
end

local function UpdateDomestication(inst)
    -- inst.components.dragonfly_domesticatable
end

local function OnNamedByWriteable(inst, new_name, writer)
    inst.is_writing = false
    if inst.components.named ~= nil then
        inst.components.named:SetName(new_name, writer ~= nil and writer.userid or nil)
    end
end

local function OnWritingEnded(inst)
    inst.is_writing = false
    if not inst.components.writeable:IsWritten() then
        local leader = inst.components.follower:GetLeader()
        if leader ~= nil and leader.components.inventoryitem ~= nil then
            inst.components.follower:SetLeader(nil)
        end
    end
end

local function RemoveName(inst)
    inst.components.writeable:SetText(nil)
    inst.components.named:SetName(nil)
end

local function ClearBellOwner(inst)
    if inst._marked_for_despawn then
        -- We're marked for despawning, so don't disconnect anything,
        -- in case we get saved for real i.e. when despawning in caves.
        return
    end

    RemoveName(inst)

    local bell_leader = inst.components.follower:GetLeader()
    inst:RemoveEventCallback("onremove", inst._BellRemoveCallback, bell_leader)

    inst.components.follower:SetLeader(nil)
    inst.components.rideable:SetShouldSave(true)

    inst.persists = true

    inst:UpdateDomestication()
end

local function GetDragonflyBellOwner(inst)
    local leader = inst.components.follower:GetLeader()
    return (leader ~= nil
        and leader.components.inventoryitem ~= nil
        and leader.components.inventoryitem:GetGrandOwner())
        or nil
end

local TWEEN_TARGET = {0, 0, 0, 1}
local TWEEN_TIME = 13 * FRAMES
local function OnDespawnRequest(inst)
    local fx = SpawnPrefab("spawn_fx_medium")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst._marked_for_despawn = true
    inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
end

local COMBAT_MUSHAVE_TAGS = { "_combat", "_health" }
local COMBAT_CANTHAVE_TAGS = { "INLIMBO", "noauradamage", "companion" }

-- local COMBAT_MUSTONEOF_TAGS_DEFENSIVE = { "monster", "prey", "hostile" }

local function CommonRetarget(inst, v)
    return v ~= inst and not v:HasTag("player") and v.entity:IsVisible()
            and inst.components.combat:CanTarget(v)
            and v.components.minigame_participator == nil
end

local function RetargetFn(inst)
    local leader = inst.components.follower:GetLeader()
    if leader and leader.components.inventoryitem then
        leader = leader.components.inventoryitem:GetGrandOwner()
    end

    if not leader then
        return nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local entities_near_me = TheSim:FindEntities(
        ix, iy, iz, TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE,
        COMBAT_MUSHAVE_TAGS, COMBAT_CANTHAVE_TAGS, nil
    )

    for _, entity_near_me in ipairs(entities_near_me) do
        if CommonRetarget(inst, entity_near_me) then
            local combat = entity_near_me.components.combat
            if combat and (combat.target == leader or combat.target == inst) then
                return entity_near_me
            end
        end
    end

    return nil
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnRiderChanged(inst, data)
    inst.components.combat:SetTarget(nil)
end

local sounds =
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve_DLC001/creatures/dragonfly/sleep_pre",
    yell = "dontstarve_DLC001/creatures/dragonfly/angry",
    swish = "dontstarve_DLC001/creatures/dragonfly/sleep_pre",
    curious = "dontstarve_DLC001/creatures/dragonfly/sleep_pre",
    angry = "dontstarve_DLC001/creatures/dragonfly/angry",
    sleep = "dontstarve/beefalo/sleep",
}

local brain = require("brains/dragonfly_mount_brain")

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(6, 3.5)
    inst.Transform:SetSixFaced()
    -- inst.Transform:SetScale(1.3, 1.3, 1.3)

    MakeFlyingGiantCharacterPhysics(inst, 500, 1)

    inst:AddTag("dragonfly_mount")
    inst:AddTag("flying")

    --saddleable (from rideable component) added to pristine state for optimization
    inst:AddTag("saddleable")

    inst.AnimState:SetBank("dragonfly_mount")
    inst.AnimState:SetBuild("dragonfly_mount_fire_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(235/255, 121/255, 12/255)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")

    inst.sounds = sounds

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    local combat = inst:AddComponent("combat")
    local groundpounder = inst:AddComponent("groundpounder")
    local health = inst:AddComponent("health")

    combat:SetDefaultDamage(TUNING.DRAGONFLY_DAMAGE)
    combat:SetAttackPeriod(2)
    combat.playerdamagepercent = 0.5
    combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE + 1, TUNING.DRAGONFLY_HIT_RANGE + 1)
    combat:SetRetargetFunction(3, RetargetFn)
    combat:SetKeepTargetFunction(KeepTargetFn)
    combat.battlecryenabled = false
    combat.hiteffectsymbol = "dragonfly_body"
    combat:SetHurtSound("dontstarve_DLC001/creatures/dragonfly/hurt")
    combat:AddNoAggroTag("player")

    groundpounder:UseRingMode()
    groundpounder.numRings = 3
    groundpounder.initialRadius = 1.5
    groundpounder.radiusStepDistance = 2
    groundpounder.ringWidth = 2
    groundpounder.damageRings = 2
    groundpounder.destructionRings = 3
    groundpounder.platformPushingRings = 3
    groundpounder.fxRings = 2
    groundpounder.fxRadiusOffset = 1.5
    groundpounder.burner = true
    groundpounder.groundpoundfx = "firesplash_fx"
    groundpounder.groundpounddamagemult = 0.5
    groundpounder.groundpoundringfx = "firering_fx"

    health:SetMaxHealth(TUNING.DRAGONFLY_HEALTH / 2)
    health.nofadeout = true --Handled in death state instead
    health.fire_damage_scale = 0 -- Take no damage from fire

    inst:AddComponent("lootdropper")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 8

    inst:AddComponent("timer")

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = false

    inst:AddComponent("rideable")
    inst.components.rideable.canride = true
    inst.components.rideable:SetSaddleable(true)
    inst.components.rideable:SetCustomRiderTest(PotentialRiderTest)

    inst:AddComponent("dragonfly_domesticatable")

    inst:AddComponent("named")

    inst:AddComponent("writeable")
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    inst.components.writeable:SetWriteableDistance(TUNING.BEEFALO_NAMING_DIST)
    inst.components.writeable:SetOnWrittenFn(OnNamedByWriteable)
    inst.components.writeable:SetOnWritingEndedFn(OnWritingEnded)

    inst:AddComponent("colourtweener")

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides
    inst.SetDragonflyBellOwner = SetDragonflyBellOwner
    inst.UpdateDomestication = UpdateDomestication

    inst:ListenForEvent("despawn", OnDespawnRequest)
    inst:ListenForEvent("stopfollowing", ClearBellOwner)
    inst:ListenForEvent("riderchanged", OnRiderChanged)

    inst._BellRemoveCallback = function(bell)
        ClearBellOwner(inst)
    end

    inst:SetStateGraph("SGdragonfly")

    inst:SetBrain(brain)

    return inst
end

return Prefab("dragonfly_mount", fn)
