
local function OnDiscarded(inst)
    inst.components.finiteuses:Use()
end

local function OnUsedUp(inst)
    SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local BANK, IDLE_ANIM = "saddlebasic", "idle"

local function SetupSaddler(inst)
    local build = inst.AnimState:GetBuild()

    inst:AddComponent("saddler")
    inst.components.saddler:SetBonusDamage(inst._data.bonusdamage)
    inst.components.saddler:SetBonusSpeedMult(inst._data.speedmult)
    inst.components.saddler:SetSwaps(build, "swap_saddle")
    inst.components.saddler:SetDiscardedCallback(OnDiscarded)

    if inst._data.absorption ~= nil then
        inst.components.saddler:SetAbsorption(inst._data.absorption)
    end
end

local function MakeSaddle(name, data)
    local assets = {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(BANK)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation(IDLE_ANIM, data.forgerepairable)

        inst.mounted_foleysound = "dontstarve/beefalo/saddle/"..data.foley

        MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])

        if data.extra_tags ~= nil then
            for _, tag in ipairs(data.extra_tags) do
                inst:AddTag(tag)
            end
        end

        if data.commoninit ~= nil then
            data.commoninit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._data = data

        inst.SetupSaddler = SetupSaddler

        inst:AddComponent("inspectable")
        
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"
        inst.components.inventoryitem.imagename = name

        inst:SetupSaddler()

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(data.uses)
        inst.components.finiteuses:SetUses(data.uses)

        if not data.forgerepairable then
            inst.components.finiteuses:SetOnFinished(OnUsedUp)
        end

        MakeHauntableLaunch(inst)

        if data.postinit ~= nil then
            data.postinit(inst)
        end

        return inst
    end

    RegisterInventoryItemAtlas("images/inventoryimages/"..name..".xml", name..".tex")

    return Prefab(name, fn, assets, data.prefabs)
end

local data = {
    war = {
        bonusdamage = 2 * TUNING.SADDLE_WAR_BONUS_DAMAGE,
        foley = "war_foley",
        uses = TUNING.SADDLE_WAR_USES,
        speedmult = (TUNING.SADDLE_WAR_SPEEDMULT + TUNING.SADDLE_RACE_SPEEDMULT) / 2,
        floater = {"small", 0.1, 0.7},
        extra_tags = {"combatmount"},
    },
}

return MakeSaddle("saddle_dragonfly", data.war)
