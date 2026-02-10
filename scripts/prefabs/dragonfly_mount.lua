local assets =
{
    Asset("ANIM", "anim/dragonfly_mount_baby.zip"),
    Asset("ANIM", "anim/dragonfly_mount_teen.zip"),
    Asset("ANIM", "anim/dragonfly_mount.zip"),
    Asset("ANIM", "anim/dragonfly_mount_build.zip"),
    Asset("ANIM", "anim/dragonfly_mount_fire_build.zip"),
}

local AnimSet = {
    baby = {
        build = "dragonfly_mount_baby_build",
        bank = "dragonfly_mount_baby"
    },
    teen = {
        build = "dragonfly_mount_teen_build",
        bank = "dragonfly_mount_teen"
    },
    adult = {
        build = "dragonfly_mount_build",
        bank = "dragonfly_mount"
    }
}

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

local override_build = AnimSet["adult"].build


local function ApplyBuildOverrides(inst, animstate)
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:SetBank("wilsondragonfly")
        animstate:AddOverrideBuild(override_build)
    else
        animstate:SetBuild(override_build)
    end

end

local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild(override_build)
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

    inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition())
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

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local entities_near_me = TheSim:FindEntities(
        ix, iy, iz, TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE,
        COMBAT_MUSHAVE_TAGS, COMBAT_CANTHAVE_TAGS, nil
    )

    for _, entity_near_me in ipairs(entities_near_me) do
        if CommonRetarget(inst, entity_near_me) then
            local combat = entity_near_me.components.combat
            if combat and ((leader and combat.target == leader) or combat.target == inst) then
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

-- only used for mount
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

local SetupDragonflyMountSpell = require("prefabs/dragonfly_mount_skills").SetupDragonflyMountSpell

local function OnSave(inst, data)

end

local function OnLoad(inst, data)

end

local function GrowTime()
    return 5 * TUNING.TOTAL_DAY_TIME
end

local DRAGONFLY_SCALE = 1
local DRAGONFLY_RADIUS = 1
local SHADOW_SIZE_X = 6
local SHADOW_SIZE_Y = 3.5
local DRAGONFLY_DAMAGE = 150
local DRAGONFLY_ATTACK_RANGE = 5
local DRAGONFLY_HIT_RANGE = 6
local DRAGONFLY_HEALTH = 5500
local DRAGONFLY_WALK_SPEED = 6
local DRAGONFLY_RUN_SPEED = 8

local function BabyStage(inst)
    local mult = 0.35

    -- inst.AnimState:SetScale(DRAGONFLY_SCALE * mult, DRAGONFLY_SCALE * mult)
    inst.AnimState:SetBuild(AnimSet["baby"].build)
    inst.AnimState:SetBank(AnimSet["baby"].bank)

    inst.DynamicShadow:SetSize(SHADOW_SIZE_X * mult, SHADOW_SIZE_Y * mult)
    inst.Physics:SetCapsule(DRAGONFLY_RADIUS * mult, 1)

    inst.components.rideable.canride = false
    inst.components.rideable:SetSaddleable(false)

    inst.components.combat:SetDefaultDamage(DRAGONFLY_DAMAGE * mult)
    inst.components.combat:SetRange(DRAGONFLY_ATTACK_RANGE * mult, DRAGONFLY_HIT_RANGE * mult)

    local speed_mult = 0.8
    inst.components.locomotor.walkspeed = DRAGONFLY_WALK_SPEED * speed_mult
    inst.components.locomotor.runspeed = DRAGONFLY_RUN_SPEED * speed_mult

    local named = inst.components.named
    if named and named.name == nil then
        named:SetName(STRINGS.NAMES.DRAGONFLY_MOUNT_BABY, nil)
    end

    inst:AddTag("baby")
    inst:RemoveTag("teen")
    inst:RemoveTag("adult")
end

local function TeenStage(inst)
    local mult = 0.65

    -- inst.AnimState:SetScale(DRAGONFLY_SCALE * mult, DRAGONFLY_SCALE * mult)
    inst.AnimState:SetBuild(AnimSet["teen"].build)
    inst.AnimState:SetBank(AnimSet["teen"].bank)

    inst.DynamicShadow:SetSize(SHADOW_SIZE_X * mult, SHADOW_SIZE_Y * mult)
    inst.Physics:SetCapsule(DRAGONFLY_RADIUS * mult, 1)

    inst.components.rideable.canride = false
    inst.components.rideable:SetSaddleable(false)

    inst.components.combat:SetDefaultDamage(DRAGONFLY_DAMAGE * mult)
    inst.components.combat:SetRange(DRAGONFLY_ATTACK_RANGE * mult, DRAGONFLY_HIT_RANGE * mult)

    local speed_mult = 0.9
    inst.components.locomotor.walkspeed = DRAGONFLY_WALK_SPEED * speed_mult
    inst.components.locomotor.runspeed = DRAGONFLY_RUN_SPEED * speed_mult

    local named = inst.components.named
    if named and named.name == STRINGS.NAMES.DRAGONFLY_MOUNT_BABY then
        named:SetName(STRINGS.NAMES.DRAGONFLY_MOUNT_TEEN, nil)
    end

    inst:AddTag("teen")
    inst:RemoveTag("baby")
    inst:RemoveTag("adult")
end

local function AdultStage(inst)
    -- inst.AnimState:SetScale(DRAGONFLY_SCALE, DRAGONFLY_SCALE)
    inst.AnimState:SetBuild(AnimSet["adult"].build)
    inst.AnimState:SetBank(AnimSet["adult"].bank)

    inst.DynamicShadow:SetSize(SHADOW_SIZE_X, SHADOW_SIZE_Y)
    inst.Physics:SetCapsule(DRAGONFLY_RADIUS, 1)

    inst.components.rideable.canride = true
    inst.components.rideable:SetSaddleable(true)

    inst.components.combat:SetDefaultDamage(DRAGONFLY_DAMAGE)
    inst.components.combat:SetRange(DRAGONFLY_ATTACK_RANGE, DRAGONFLY_HIT_RANGE)

    inst.components.locomotor.walkspeed = DRAGONFLY_WALK_SPEED
    inst.components.locomotor.runspeed = DRAGONFLY_RUN_SPEED

    local named = inst.components.named
    if named and named.name == STRINGS.NAMES.DRAGONFLY_MOUNT_TEEN then
        named:SetName(STRINGS.NAMES.DRAGONFLY_MOUNT, nil)
    end

    inst:AddTag("adult")
    inst:RemoveTag("baby")
    inst:RemoveTag("teen")
end

local dragonfly_stages =
{
    { name = "baby", time = GrowTime, fn = BabyStage },
    { name = "teen", time = GrowTime, fn = TeenStage },
    { name = "adult", fn = AdultStage },
}

-- client safe
local function GetStage(inst)
    if inst:HasTag("baby") then
        return "BABY"
    elseif inst:HasTag("teen") then
        return "TEEN"
    else
        return "ADULT"
    end
end

local SoundLookup = {
    BABY = {
        ["dontstarve_DLC001/creatures/dragonfly/angry"] = "dragonfly_mount/baby/angry",
        ["dontstarve_DLC001/creatures/dragonfly/blink"] = "dragonfly_mount/baby/blink",
        ["dontstarve_DLC001/creatures/dragonfly/death"] = "dragonfly_mount/baby/death",
        ["dontstarve_DLC001/creatures/dragonfly/swipe"] = "dragonfly_mount/baby/swipe",
    },
    TEEN = {},
    ADULT = {},
}

local function HookSoundEmitter(inst)
    inst._SoundEmitter = inst.SoundEmitter
    inst.SoundEmitter = {}
    local meta = {
        __index = function(t, k)
            local fn = SoundEmitter[k]
            if fn then
                return function(tab, ...)
                    return fn(inst._SoundEmitter, ...)
                end
            end
        end
    }
    setmetatable(inst.SoundEmitter, meta)

    local _PlaySound = inst.SoundEmitter.PlaySound
    inst.SoundEmitter.PlaySound = function(self, path, ...)
        local stage = GetStage(inst)
        local sound = SoundLookup[stage][path]
        if sound then
            -- print("Replace", path, "  To  ", sound)
            path = sound
        end
        return _PlaySound(self, path, ...)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    HookSoundEmitter(inst)

    inst.DynamicShadow:SetSize(SHADOW_SIZE_X, SHADOW_SIZE_Y)
    inst.Transform:SetSixFaced()

    MakeFlyingGiantCharacterPhysics(inst, 500, DRAGONFLY_RADIUS)

    inst:AddTag("dragonfly_mount")
    inst:AddTag("adult")
    inst:AddTag("flying")

    --saddleable (from rideable component) added to pristine state for optimization
    inst:AddTag("saddleable")

    inst.AnimState:SetBuild(AnimSet["adult"].build)
    inst.AnimState:SetBank(AnimSet["adult"].bank)
    inst.AnimState:PlayAnimation("idle", true)

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(235/255, 121/255, 12/255)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")

    inst.sounds = sounds

    SetupDragonflyMountSpell(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStage

    local combat = inst:AddComponent("combat")
    local groundpounder = inst:AddComponent("groundpounder")
    local health = inst:AddComponent("health")

    combat:SetDefaultDamage(DRAGONFLY_DAMAGE)
    combat:SetAttackPeriod(2)
    combat.playerdamagepercent = 0.5
    combat:SetRange(DRAGONFLY_ATTACK_RANGE, DRAGONFLY_HIT_RANGE)
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
    table.insert(groundpounder.noTags, "player")

    health:SetMaxHealth(DRAGONFLY_HEALTH)
    health.nofadeout = true --Handled in death state instead
    health.fire_damage_scale = 0 -- Take no damage from fire

    inst:AddComponent("lootdropper")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    inst.components.locomotor.walkspeed = DRAGONFLY_WALK_SPEED
    inst.components.locomotor.runspeed = DRAGONFLY_RUN_SPEED

    inst:AddComponent("timer")

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = false

    inst:AddComponent("rideable")
    inst.components.rideable.canride = true
    inst.components.rideable:SetSaddleable(true)
    inst.components.rideable:SetCustomRiderTest(PotentialRiderTest)

    inst:AddComponent("knownlocations")

    inst:AddComponent("dragonfly_domesticatable")

    inst:AddComponent("named")

    inst:AddComponent("writeable")
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    inst.components.writeable:SetWriteableDistance(TUNING.BEEFALO_NAMING_DIST)
    inst.components.writeable:SetOnWrittenFn(OnNamedByWriteable)
    inst.components.writeable:SetOnWritingEndedFn(OnWritingEnded)

    inst:AddComponent("colourtweener")

    inst:AddComponent("growable")
    inst.components.growable.stages = dragonfly_stages
    inst.components.growable:SetStage(3)

    local propagator = MakeLargePropagator(inst)
    propagator.decayrate = 0

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides
    inst.SetDragonflyBellOwner = SetDragonflyBellOwner
    inst.UpdateDomestication = UpdateDomestication

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

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

return Prefab("dragonfly_mount", fn, assets)
