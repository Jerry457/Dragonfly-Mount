local function PotentialRiderTest(inst, potential_rider)
    return true
end

local function ApplyBuildOverrides(inst, animstate)
    local basebuild = "dragonfly_fire_build"
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:SetBank("wilsondragonfly")
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end

end

local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild("dragonfly_fire_build")
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

    inst.DynamicShadow:SetSize(6, 3.5)
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.3, 1.3, 1.3)

    MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)

    inst.AnimState:SetBank("dragonfly")
    inst.AnimState:SetBuild("dragonfly_fire_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(235/255, 121/255, 12/255)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_SPEED

    inst:AddComponent("rideable")
    inst.components.rideable.canride = true
    inst.components.rideable:SetSaddleable(true)
    inst.components.rideable:SetCustomRiderTest(PotentialRiderTest)

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides

    inst:SetStateGraph("SGdragonfly")

    return inst
end

return Prefab("dragonfly_mount", fn)
