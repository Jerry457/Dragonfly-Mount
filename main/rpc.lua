local AddModRPCHandler = AddModRPCHandler
local SendModRPCToServer = SendModRPCToServer
local modname = modname
GLOBAL.setfenv(1, GLOBAL)

-- AddModRPCHandler("", "", function(player)
-- end)

-- TheInput:AddKeyDownHandler(KEY_R, function()
-- end)

-- 骑乘或上鞍时呼叫龙蝇前往玩家位置
AddModRPCHandler(modname, "TryDragonflyGotoPlayer", function(player, inst)
    if not checkentity(inst) then return end

    local leader = inst.components.follower and inst.components.follower:GetLeader()
    if leader and leader.components.inventoryitem then
        leader = leader.components.inventoryitem:GetGrandOwner()
    end
    if leader == player and not inst.goto_leader then
        local talker = player.components.talker
        if talker then
            talker:Say(GetString(player, "ANNOUNCE_DRAGONFLY_GOTO_PLAYER"))
        end
        inst.goto_leader = true
    end
end)