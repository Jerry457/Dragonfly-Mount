local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("dragonfly", function(inst)
    if not TheWorld.ismastersim then return end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot('dragonfly_bell_blueprint', 1.00)
        inst.components.lootdropper:AddChanceLoot('saddle_dragonfly_blueprint', 1.00)
        inst.components.lootdropper:AddChanceLoot('dragonfly_egg', 1.00)
    end
end)
