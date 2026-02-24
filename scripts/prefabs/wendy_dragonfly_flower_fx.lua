local assets =
{
	Asset("ANIM", "anim/wendy_dragonfly_flower_fx.zip"),
}

local function MakeSummonFX(bank, anim, build, is_mounted)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

		if is_mounted then
	        inst.Transform:SetSixFaced()
		else
	        inst.Transform:SetFourFaced()
		end

        inst.AnimState:SetBank(bank)
		if build ~= nil then
			inst.AnimState:SetBuild(build)
	        inst.AnimState:OverrideSymbol("flower", "abigail_flower_rework", "flower")
		else
	        inst.AnimState:SetBuild("abigail_flower_rework")
		end
        inst.AnimState:PlayAnimation(anim)
		inst.AnimState:SetFinalOffset(1)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return
Prefab("abigailsummonfx_mount_dragonfly", MakeSummonFX("wendy_dragonfly_flower_fx", "wendy_mount_dragonfly_channel_flower", "wendy_channel_flower", true), assets),
Prefab("abigailunsummonfx_mount_dragonfly", MakeSummonFX("wendy_dragonfly_flower_fx", "wendy_mount_dragonfly_recall_flower", nil, true), assets)
