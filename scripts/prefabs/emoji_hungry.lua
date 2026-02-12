local assets =
{
    Asset("ANIM", "anim/emoji_hungry.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("emoji_hungry")
    inst.AnimState:SetBuild("emoji_hungry")
    inst.AnimState:PlayAnimation("idle")

    -- inst.AnimState:SetScale(DRAGONFLY_SCALE * mult, DRAGONFLY_SCALE * mult)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    inst.persists = false

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("emoji_hungry", fn, assets)
