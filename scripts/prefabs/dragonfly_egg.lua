local assets =
{
    -- Asset("ANIM", "anim/lavae_egg.zip"),
    -- Asset("SOUND", "sound/together.fsb"),
}

local loot_cold =
{
    "rocks",
}

local function PlaySound(inst, sound)
    inst.SoundEmitter:PlaySound(sound)
end

local function SpawnBell(inst)
    if inst.components.lootdropper == nil then
        inst:AddComponent("lootdropper")
    end
    local bell = inst.components.lootdropper:SpawnLootPrefab("dragonfly_bell")
    if bell ~= nil then
        bell:SpawnBabyDragonfly()
    end
    inst:Remove()
end

local function StartSpawn(inst)
    inst.components.inventoryitem.canbepickedup = false
    inst.AnimState:PlayAnimation("hatch")

    inst:DoTaskInTime(34 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_bounce")
    inst:DoTaskInTime(44 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_hatch")

    inst:ListenForEvent("animover", SpawnBell)
end

local function DropLoot(inst)
    if inst.components.lootdropper == nil then
        inst:AddComponent("lootdropper")
    end
    inst.components.lootdropper:SetLoot(loot_cold)
    inst.components.lootdropper:DropLoot()
end

local function CheckHatch(inst)
    if inst.components.playerprox ~= nil and
        inst.components.playerprox:IsPlayerClose() and
        inst.components.hatchable.state == "hatch" and
        not inst.components.inventoryitem:IsHeld() then
        StartSpawn(inst)
    end
end

local function OnDropped(inst)
    inst.components.hatchable:StartUpdating()
    CheckHatch(inst)
end

local function OnPutInInventory(inst)
    inst.components.hatchable:StopUpdating()
end

local function OnLoadPostPass(inst)
    --V2C: in case of load order of hatchable and inventoryitem components
    if inst.components.inventoryitem:IsHeld() then
        OnPutInInventory(inst)
    end
end

local function OnHatchState(inst, state)
    if state == "crack" then
        local cracked = SpawnPrefab("dragonfly_egg_cracked")
        cracked.Transform:SetPosition(inst.Transform:GetWorldPosition())
        cracked.AnimState:PlayAnimation("crack")
        inst:DoTaskInTime(14 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_crack")
        inst:DoTaskInTime(22 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_bounce")
        cracked.AnimState:PushAnimation("happy", true)
        inst:Remove()
    elseif state == "uncomfy" then
        --Lavae egg can never be too hot
        if inst.components.hatchable.toocold then
            inst.AnimState:PlayAnimation("idle_cold", true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/egg_shiver")
        end
    elseif state =="comfy" then
        inst.AnimState:PlayAnimation("happy", true)
    elseif state == "hatch" then
        CheckHatch(inst)
    elseif state == "dead" then
        --inst:DoTaskInTime(15 * FRAMES, PlaySound, "dontstarve/creatures/egg/egg_cold_freeze")
        inst:DoTaskInTime(16 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_deathpoof")
        inst:DoTaskInTime(43 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_deathcrack")
        inst:DoTaskInTime(42 * FRAMES, DropLoot)
        inst.components.inventoryitem.canbepickedup = false
        inst.persists = false
        inst.AnimState:PlayAnimation("toocold")
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function describe(inst)
    local state = inst.components.hatchable.state
    return (state == "uncomfy" and "COLD")
        or (state == "comfy" and "COMFY")
        or "GENERIC"
end

local function oversized_onequip(inst, owner)
	local swap = inst.components.symbolswapdata
    owner.AnimState:OverrideSymbol("swap_body", swap.build, swap.symbol)
end

local function oversized_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local OVERSIZED_PHYSICS_RADIUS = 0.1

local function common_fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("heavy")

    MakeHeavyObstaclePhysics(inst, OVERSIZED_PHYSICS_RADIUS)
    inst:SetPhysicsRadiusOverride(OVERSIZED_PHYSICS_RADIUS)

    inst.AnimState:SetBuild("lavae_egg")
    inst.AnimState:SetBank("lavae_egg")
    inst.AnimState:PlayAnimation(anim)

    local scale = 2
    inst.Transform:SetScale(scale, scale, scale)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("heavyobstaclephysics")
    inst.components.heavyobstaclephysics:SetRadius(OVERSIZED_PHYSICS_RADIUS)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lavae_egg"
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(oversized_onequip)
    inst.components.equippable:SetOnUnequip(oversized_onunequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst:AddComponent("symbolswapdata")
    inst.components.symbolswapdata:SetData("farm_plant_corn_build", "swap_body")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe
    inst:AddComponent("hatchable")

    inst.components.hatchable:SetOnState(OnHatchState)
    inst.components.hatchable:SetCrackTime(TUNING.LAVAE_HATCH_CRACK_TIME)
    inst.components.hatchable:SetHatchTime(TUNING.LAVAE_HATCH_TIME)
    inst.components.hatchable:SetHatchFailTime(TUNING.LAVAE_HATCH_FAIL_TIME)
    inst.components.hatchable:SetHeaterPrefs(true, true, true)
    inst.components.hatchable:StartUpdating()

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst.OnLoadPostPass = OnLoadPostPass
    inst.SpawnBell = SpawnBell

    return inst
end

local function default()
    local inst = common_fn("idle")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function cracked()
    local inst = common_fn("happy")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.hatchable.state = "comfy"

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 6)
    inst.components.playerprox:SetOnPlayerNear(CheckHatch)

    return inst
end

return Prefab("dragonfly_egg", default, assets),
    Prefab("dragonfly_egg_cracked", cracked, assets)
