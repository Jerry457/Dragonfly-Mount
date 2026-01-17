local AddPlayerPostInit = AddPlayerPostInit

GLOBAL.setfenv(1, GLOBAL)

AddPlayerPostInit(function(inst)
    inst:ListenForEvent("newstate", function(inst, data)
        local statename = data.statename
        if statename and statename == "attack" then
            local mount = inst.replica.rider:GetMount()
            if (mount and mount:HasTag("dragonfly_mount")) then
                inst.sg:SetTimeout(25 * FRAMES)
            end
        end
    end)
end)

