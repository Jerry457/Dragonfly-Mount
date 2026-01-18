local easing = require("easing")

local assets =
{
    -- Asset("ANIM", "anim/cowbell.zip"),
    -- Asset("INV_IMAGE", "dragonfly_bell_linked"),
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

local function CleanUpBell(inst)
    inst:RemoveTag("nobundling")

    -- inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())

    inst.AnimState:PlayAnimation("idle1", false)
    inst.components.inventoryitem.nobounce = false
    inst.components.floater.splash = true

    -- if inst.isbonded ~= nil then
    --     inst.isbonded:set(false)

    --     if not TheNet:IsDedicated() then
    --         inst:OnIsBondedDirty()
    --     end
    -- end
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

    -- This may run with a nil user on load.
    if user ~= nil and GetOtherPlayerLinkedBell(inst, user) ~= nil then
        return false, "BEEF_BELL_HAS_BEEF_ALREADY"
    end

    local successful, failreason = target:SetDragonflyBellOwner(inst, user)

    if successful then
        inst:AddTag("nobundling")

        -- local basename = inst:GetSkinName() or inst.prefab
        -- inst.components.inventoryitem:ChangeImageName(basename.."_linked")
        inst.AnimState:PlayAnimation("idle2", true)

        -- if inst.isbonded ~= nil then
        --     inst.isbonded:set(true)

        --     inst.components.inventoryitem.nobounce = true
        --     inst.components.floater.splash = false

        --     if not TheNet:IsDedicated() then
        --         inst:OnIsBondedDirty()
        --     end
        -- end
    end

    return successful, (failreason ~= nil and "BEEF_BELL_"..failreason or nil)
end

local function OnStopUsing(inst, dragonfly)
    dragonfly = dragonfly or inst:GetDragonfly()
    
    -- if dragonfly ~= nil then
    --     dragonfly:UnSkin() -- Drop skins.
    -- end

    inst.components.leader:RemoveAllFollowers()
    inst:CleanUpBell()

    -- if inst:HasTag("shadowbell") and dragonfly ~= nil and dragonfly.components.health:IsDead() then
    --     dragonfly.persists = false -- Dragonfly's ClearBellOwner fn makes it persistent.

    --     if dragonfly:HasTag("NOCLICK") then
    --         return
    --     end

    --     dragonfly:AddTag("NOCLICK")

    --     RemovePhysicsColliders(dragonfly)

    --     if dragonfly.DynamicShadow ~= nil then
    --         dragonfly.DynamicShadow:Enable(false)
    --     end

    --     local multcolor = dragonfly.AnimState:GetMultColour()
    --     local ticktime = TheSim:GetTickTime()

    --     local erodetime = 5

    --     dragonfly:StartThread(function()
    --         local ticks = 0
    
    --         while dragonfly:IsValid() and (ticks * ticktime < erodetime) do
    --             local n = ticks * ticktime / erodetime
    
    --             local alpha = easing.inQuad(1 - n, 0, 1, 1)
    --             local color = 1 - (n * 5)
    
    --             local color = math.min(multcolor, color)

    --             dragonfly.AnimState:SetErosionParams(n, .05, 1.0)
    --             dragonfly.AnimState:SetMultColour(color, color, color, math.max(.3, alpha))
    
    --             ticks = ticks + 1
    --             Yield()
    --         end

    --         dragonfly:Remove()
    --     end)
    -- end
end

-----------------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    local dragonfly = inst:GetDragonfly()

    if dragonfly ~= nil then
        -- local skinner_dragonfly = dragonfly.components.skinner_dragonfly
    
        -- data.clothing = skinner_dragonfly ~= nil and skinner_dragonfly.clothing or nil
        -- local is_riding = dragonfly.components.rideable and dragonfly.components.rideable:IsBeingRidden()
        -- data.is_riding = is_riding
        -- print("is_riding", is_riding)
        data.dragonfly_record = dragonfly:GetSaveRecord()
        -- print("save dragonfly_record")
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.dragonfly_record ~= nil then
        local dragonfly = SpawnSaveRecord(data.dragonfly_record)

        if dragonfly ~= nil then
            inst.components.useabletargeteditem:StartUsingItem(dragonfly)
            -- print("load dragonfly_record")

            -- if data.is_riding then
            --     local rider = inst.components.inventoryitem:GetGrandOwner()
            --     print("rider", rider)
            --     if rider and rider.components.rider then
            --         rider.components.rider:Mount(dragonfly, true)
            --         print("load Mount")
            --     end
            -- end
            -- if data.clothing ~= nil then
            --     dragonfly.components.skinner_dragonfly:reloadclothing(data.clothing)
            -- end
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------

-- local function ShadowBell_CanReviveTarget(inst, target, doer)
--     return target.GetBeefBellOwner ~= nil and target:GetBeefBellOwner() == doer
-- end

-- local function ShadowBell_ReviveTarget(inst, target, doer)
--     target:OnRevived(inst)

--     doer:AddDebuff("shadow_dragonfly_bell_curse", "shadow_dragonfly_bell_curse")

--     inst.components.rechargeable:Discharge(TUNING.SHADOW_BEEF_BELL_REVIVE_COOLDOWN)
-- end

-- local SHADOW_FLOAT_SCALE_BONDED = { 0, 0, 0 }
local FLOAT_SCALE = { 1.2, 1, 1.2 }

-- local function ShadowBell_OnIsBondedDirty(inst)
--     inst.components.floater:SetScale(inst.isbonded:value() and SHADOW_FLOAT_SCALE_BONDED or FLOAT_SCALE)

--     if inst.components.floater:IsFloating() then
--         inst.components.floater:OnNoLongerLandedClient()
--         inst.components.floater:OnLandedClient()
--     end
-- end

-- local function ShadowBell_OnDischarged(inst)
--     inst:AddTag("oncooldown")
-- end

-- local function ShadowBell_OnCharged(inst)
--     inst:RemoveTag("oncooldown")
-- end

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
    inst.components.inventoryitem.imagename = "beef_bell"
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
        bank  = "cowbell",
        build = "cowbell",
        sound = "yotb_2021/common/cow_bell",
    })
end

-- local function ShadowCommonPostInit(inst, data)
--     inst.entity:AddDynamicShadow()
--     inst.DynamicShadow:SetSize(1.2, .8)

--     inst.AnimState:Hide("shadow")

--     inst.AnimState:SetLightOverride(0.1)
--     inst.AnimState:SetSymbolLightOverride("red", 0.5)

--     -- rechargeable (from rechargeable component) added to pristine state for optimization.
--     inst:AddTag("rechargeable")

--     inst:AddTag("shadowbell")

--     inst.OnIsBondedDirty = ShadowBell_OnIsBondedDirty

--     inst.isbonded = net_bool(inst.GUID, "shadow_dragonfly_bell.isbonded", "isbondeddirty")
-- end

-- local function ShadowFn()
--     local inst = CommonFn({
--         bank  = "cowbell_shadow",
--         build = "cowbell_shadow",
--         sound = "rifts4/dragonfly_revive/bell_ring",
--         common_postinit = ShadowCommonPostInit,
--     })

--     if not TheWorld.ismastersim then
--         inst:ListenForEvent("isbondeddirty", inst.OnIsBondedDirty)

--         return inst
--     end

--     inst:AddComponent("tradable")

--     inst:AddComponent("rechargeable")
--     inst.components.rechargeable:SetOnDischargedFn(ShadowBell_OnDischarged)
--     inst.components.rechargeable:SetOnChargedFn(ShadowBell_OnCharged)

--     inst.CanReviveTarget = ShadowBell_CanReviveTarget
--     inst.ReviveTarget = ShadowBell_ReviveTarget

--     return inst
-- end

-----------------------------------------------------------------------------------------------------------------------------------------

return Prefab("dragonfly_bell", RegularFn, assets)
