local function MakeFx(data)
    local assets =
    {
        Asset("ANIM", "anim/" .. data.build .. ".zip"),
    }

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBuild(data.build)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:PlayAnimation(data.anim)

        if data.bloom then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end

        inst.hub_symbols = data.hub_symbols

        inst:AddTag("FX")

        inst.entity:SetCanSleep(false)
        inst.entity:SetPristine()

        if data.fn then
            data.fn(inst)
        end

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(data.name, fn, assets)
end

return MakeFx({
    name = "dragonfly_mount_attackfire_fx",
    bank = "dragonfly_mount_fx",
    build = "dragonfly_mount_fx",
    anim = "atk",
    bloom = true,
    hub_symbols = { "dragon_fx" }
}),

MakeFx({
    name = "dragonfly_mount_firesplash_fx",
    bank = "dragonfly_ground_fx",
    build = "dragonfly_ground_fx",
    anim = "idle",
    bloom = true,
    hub_symbols = { "dragon_fx", "flame" }
}),

MakeFx({
    name = "dragonfly_mount_firering_fx",
    bank = "dragonfly_ring_fx",
    build = "dragonfly_ring_fx",
    anim = "idle",
    bloom = true,
    hub_symbols = { "circle" },
    fn = function(inst)
        inst.AnimState:SetFinalOffset(3)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
    end,
})
