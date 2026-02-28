local easing = require("easing")

local assets =
{
    Asset("ATLAS", "images/inventoryimages/dragonfly_bell.xml"),
    Asset("ANIM", "anim/dragonfly_bell.zip"),
}

-----------------------------------------------------------------------------------------------------------------------------------------

local function OnPlayerDesmounted(inst, data)
    local mount = data ~= nil and data.target or nil

    if mount ~= nil and mount:IsValid() then
        mount:PushEvent("despawn")
    end
end

local function OnPlayerDespawned(inst)
    local dragonfly = inst:GetDragonfly()

    if dragonfly == nil then
        return
    end

    if not dragonfly.components.health:IsDead() then
        dragonfly._marked_for_despawn = true -- Used inside dragonfly prefab.

        local dismounting = false

        if dragonfly.components.rideable ~= nil then
            dragonfly.components.rideable.canride = false

            local rider = dragonfly.components.rideable.rider

            if rider ~= nil and rider.components.rider ~= nil then
                dismounting = true

                -- print("OnPlayerDespawned dismounting rider")
                rider.components.rider:Dismount()
                rider:ListenForEvent("dismounted", inst._OnPlayerDesmounted)
            end
        end

        if dragonfly.components.health ~= nil then
            dragonfly.components.health:SetInvincible(true)
        end

        if not dismounting then
            dragonfly:PushEvent("despawn")
        end

    elseif inst:HasTag("shadowbell") then
        inst.components.useabletargeteditem:StopUsingItem()
    end
end

local function IsLinkedBell(item, inst)
    return item ~= inst and item:HasTag("bell") and item.HasDragonfly ~= nil and item:HasDragonfly()
end

local function GetOtherPlayerLinkedBell(inst, other)
    local container = other.components.inventory or other.components.container

    if container ~= nil then
        return container:FindItem(inst._IsLinkedBell)
    end
end

local function DisplayDirty(inst, has_dragonfly)
    if has_dragonfly then
        inst.components.inventoryitem:ChangeImageName("dragonfly_bell_linked")
        inst.AnimState:PlayAnimation("idle2", true)
    else
        inst.components.inventoryitem:ChangeImageName("dragonfly_bell")
        inst.AnimState:PlayAnimation("idle1", false)
    end
end

local function CleanUpBell(inst)
    inst:RemoveTag("nobundling")
    inst.components.inventoryitem.nobounce = false
    inst.components.floater.splash = true

    if inst.saved_dragonfly == nil then
        DisplayDirty(inst, false)
    end
end

local function OnRemoveFollower(inst, dragonfly)
    inst.components.useabletargeteditem:StopUsingItem()

    -- For when the bell is removed.
    if dragonfly ~= nil then
        inst:OnStopUsing(dragonfly)
    end
end

local function HasDragonfly(inst)
    return inst.components.leader ~= nil and inst.components.leader:CountFollowers() > 0
end

local function GetDragonfly(inst)
    for dragonfly, bool in pairs(inst.components.leader.followers) do
        if bool then
            return dragonfly
        end
    end
end

local function GetAliveDragonfly(inst)
    local dragonfly = inst:GetDragonfly()

    return dragonfly ~= nil and not dragonfly.components.health:IsDead() and dragonfly or nil
end

-----------------------------------------------------------------------------------------------------------------------------------------

local function OnPutInInventory(inst, owner)
    if owner == nil or not inst:HasDragonfly() then
        return
    end

    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner

    -- If the bell being picked up has a dragonfly look for another bell in the picking up player's inventory and drop it.
    local other_bell = GetOtherPlayerLinkedBell(inst, owner)

    if other_bell ~= nil then
        if owner.components.inventory ~= nil then
            if owner:HasTag("player") then
                owner.components.inventory:DropItem(other_bell, true, true)
            end

        elseif owner.components.container ~= nil and owner.components.inventoryitem ~= nil then
            -- Backpacks can be picked up, so don't allow multiple bells.
            owner.components.container:DropItem(other_bell)
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------

local function OnUsedOnDragonfly(inst, target, user)
    if target.SetDragonflyBellOwner == nil then
        return false, "BEEF_BELL_INVALID_TARGET"
    end

    if user ~= nil and target.components.health:IsDead() then
        return false -- Not loading.
    end

    if inst.saved_dragonfly then
        return false, "BEEF_BELL_HAS_BEEF_ALREADY"
    end

    -- This may run with a nil user on load.
    if user ~= nil and GetOtherPlayerLinkedBell(inst, user) ~= nil then
        return false, "BEEF_BELL_HAS_BEEF_ALREADY"
    end

    local successful, failreason = target:SetDragonflyBellOwner(inst, user)

    if successful then
        inst:AddTag("nobundling")
        DisplayDirty(inst, true)
    end

    return successful, (failreason ~= nil and "BEEF_BELL_"..failreason or nil)
end

local function OnStopUsing(inst, dragonfly)
    inst.components.leader:RemoveAllFollowers()
    inst:CleanUpBell()
end

-----------------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    local dragonfly = inst:GetDragonfly()
    if dragonfly then
        data.dragonfly_record = dragonfly:GetSaveRecord()
    else
        data.saved_dragonfly = inst.saved_dragonfly
    end
end

local function OnLoad(inst, data)
    if data then
        if data.dragonfly_record then
            local dragonfly = SpawnSaveRecord(data.dragonfly_record)
            if dragonfly then
                inst.components.useabletargeteditem:StartUsingItem(dragonfly)
            end
        else
            if data.saved_dragonfly then
                inst.saved_dragonfly = data.saved_dragonfly
                inst:AddTag("dragonfly_saved")
                DisplayDirty(inst, true)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------

local FLOAT_SCALE = { 1.2, 1, 1.2 }

-----------------------------------------------------------------------------------------------------------------------------------------

local function CommonFn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("idle1", false)

    MakeInventoryFloatable(inst, nil, 0.05, FLOAT_SCALE)

    inst:AddTag("bell")
    inst:AddTag("dragonfly_bell")
    inst:AddTag("donotautopick")

    inst._sound = data.sound

    if data.common_postinit ~= nil then
        data.common_postinit(inst, data)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._IsLinkedBell = function(item) return IsLinkedBell(item, inst) end
    inst._OnPlayerDesmounted = OnPlayerDesmounted
    inst.OnPlayerDespawned = OnPlayerDespawned
    inst.CleanUpBell = CleanUpBell
    inst.HasDragonfly = HasDragonfly
    inst.GetDragonfly = GetDragonfly
    inst.OnStopUsing = OnStopUsing

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dragonfly_bell.xml"
    inst.components.inventoryitem.imagename = "dragonfly_bell"
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst:AddComponent("useabletargeteditem")
    inst.components.useabletargeteditem:SetTargetPrefab("dragonfly_mount")
    inst.components.useabletargeteditem:SetOnUseFn(OnUsedOnDragonfly)
    inst.components.useabletargeteditem:SetOnStopUseFn(OnStopUsing)
    inst.components.useabletargeteditem:SetInventoryDisable(true)

    inst:AddComponent("leader")
    inst.components.leader.onremovefollower = OnRemoveFollower

    inst:AddComponent("migrationpetowner")
    inst.components.migrationpetowner:SetPetFn(GetAliveDragonfly)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("player_despawn", inst.OnPlayerDespawned)

    return inst
end

-----------------------------------------------------------------------------------------------------------------------------------------

local function RegularFn()
    return CommonFn({
        bank  = "dragonfly_bell",
        build = "dragonfly_bell",
        sound = "yotb_2021/common/cow_bell",
    })
end

local function RecallDragonfly(inst, doer)
    local dragonfly = inst:GetDragonfly()
    if not dragonfly then
        return false
    end

    if dragonfly.components.health:IsDead() then
        return false
    end

    if dragonfly.components.rideable and dragonfly.components.rideable:IsBeingRidden() then
        return false
    end

    if dragonfly.sg.currentstate.name == "bell_summon" then
        return false
    end

    if dragonfly.sg.currentstate.name ~= "bell_recall" then
        dragonfly.sg:GoToState("bell_recall")
        return true
    end
end

local function OnRecallFinished(inst, dragonfly)
    inst.saved_dragonfly = dragonfly and dragonfly:GetSaveRecord()
    if inst.saved_dragonfly then
        inst:AddTag("dragonfly_saved")
    end
end

local function SummonDragonfly(inst, doer)
    if inst:GetDragonfly() then
        return false
    end

    if inst.saved_dragonfly == nil then
        return false
    end

    local dragonfly = SpawnSaveRecord(inst.saved_dragonfly)
    inst.saved_dragonfly = nil

    if dragonfly then
        local x, _, z = inst.Transform:GetWorldPosition()
        local dist = 8
        local theta = math.random() * 2 * math.pi
        dragonfly.Transform:SetPosition(x + dist * math.cos(theta), 20, z + dist * math.sin(theta))
        dragonfly.sg:GoToState("bell_summon")

        inst.components.useabletargeteditem:StartUsingItem(dragonfly)
    end
    inst:RemoveTag("dragonfly_saved")
    return true
end

local function OpalFn()
    local inst = CommonFn({
        bank  = "dragonfly_bell",
        build = "dragonfly_bell",
        sound = "yotb_2021/common/cow_bell",
        common_postinit = function(inst)
            inst:AddTag("dragonfly_bell_opal")
        end,
    })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.RecallDragonfly = RecallDragonfly
    inst.OnRecallFinished = OnRecallFinished

    inst.SummonDragonfly = SummonDragonfly

    return inst
end

RegisterInventoryItemAtlas("images/inventoryimages/dragonfly_bell.xml", "dragonfly_bell.tex")

return
Prefab("dragonfly_bell", RegularFn, assets),
Prefab("dragonfly_bell_opal", OpalFn, assets)
