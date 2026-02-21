--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

local function OnAngerDirty(inst)
    if inst._parent then
        local rider = inst._parent._rider:value()
        if rider then
            local max = inst.maxanger:value()
            local current = inst.currentanger:value()
            rider:PushEvent("dragonfly_angerdirty", {max = max, current = current})
        end
    end
end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

local function SetTarget(inst, target)
    inst.Network:SetClassifiedTarget(target)
    local istarget = target == nil or target == ThePlayer
    if istarget ~= inst.istarget then
        inst.istarget = istarget
        if istarget then
            inst:ListenForEvent("angerdirty", OnAngerDirty)
        else
            inst:RemoveEventCallback("angerdirty", OnAngerDirty)
        end
    end
end

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for lucy")
    else
        inst._parent:AttachClassified(inst)
    end
end

--------------------------------------------------------------------------

local function RegisterNetListeners(inst)
    inst:ListenForEvent("angerdirty", OnAngerDirty)
    OnAngerDirty(inst)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() --So we can follow parent's sleep state
    end
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.maxanger = net_ushortint(inst.GUID, "anger.max", "angerdirty")
    inst.currentanger = net_ushortint(inst.GUID, "anger.current", "angerdirty")
    inst.maxanger:set(TUNING.DRAGONFLY_ANGER_MAX)
    inst.currentanger:set(0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated

        --Delay net listeners until after initial values are deserialized
        inst:DoStaticTaskInTime(0, RegisterNetListeners)

        return inst
    end

    --Server interface
    inst.SetTarget = SetTarget

    inst.persists = false

    return inst
end

return Prefab("dragonfly_classified", fn)
