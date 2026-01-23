local assets =
{
    Asset("ANIM", "anim/staff_fx_dragonfly.zip"),
}

local function SetUp(inst, colour)
    inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
end

local function MakeStaffFX(anim, build, bank, ismount)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

		if ismount then
			inst.Transform:SetSixFaced()
		else
			inst.Transform:SetFourFaced()
		end

        inst.AnimState:SetBank(bank or "staff_fx")
        inst.AnimState:SetBuild(build or "staff")
        inst.AnimState:PlayAnimation(anim)
	    inst.AnimState:SetFinalOffset(1)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetUp = SetUp

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("staffcastfx_dragonfly", MakeStaffFX("staff_dragonfly", nil, "staff_fx_dragonfly", true), assets)