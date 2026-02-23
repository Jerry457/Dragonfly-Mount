local AddPlayerPostInit = AddPlayerPostInit

GLOBAL.setfenv(1, GLOBAL)

local function EnableFlyingMode(inst, enable)
    --V2C: drownable HACKS, using "false" to override "nil" load behaviour
    --     Please refactor drownable to use POST LOAD timing.
    if inst.components.drownable == nil then
        return
    end

    if enable then
        if inst.components.drownable.enabled ~= false then
            inst.components.drownable.enabled = false
            inst.Physics:SetCollisionMask(
                COLLISION.GROUND,
                COLLISION.OBSTACLES,
                COLLISION.SMALLOBSTACLES,
                COLLISION.CHARACTERS,
                COLLISION.GIANTS
            )
            inst.Physics:Teleport(inst.Transform:GetWorldPosition())
        end
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    elseif inst.components.drownable.enabled == false then
        inst.components.drownable.enabled = true
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        if not inst:HasTag("playerghost") then
            inst.Physics:SetCollisionMask(
                COLLISION.WORLD,
                COLLISION.OBSTACLES,
                COLLISION.SMALLOBSTACLES,
                COLLISION.CHARACTERS,
                COLLISION.GIANTS
            )
            inst.Physics:Teleport(inst.Transform:GetWorldPosition())
        end
    end

end

local function EnableLight(inst, enable)
    if inst.Light == nil then
        return
    end
    if enable then
        inst.Light:Enable(true)
        inst.Light:SetRadius(2)
        inst.Light:SetFalloff(0.5)
        inst.Light:SetIntensity(0.75)
        inst.Light:SetColour(235/255, 121/255, 12/255)
    else
        inst.Light:Enable(false)
    end
end

AddPlayerPostInit(function(inst)
    -- 延长骑龙蝇攻击的CD
    inst:ListenForEvent("newstate", function(inst, data)
        local statename = data.statename
        if statename and statename == "attack" then
            local mount = inst.replica.rider:GetMount()
            if (mount and mount:HasTag("dragonfly_mount")) then
                inst.sg:SetTimeout(25 * FRAMES)
            end
        end
    end)

    if not TheWorld.ismastersim then
        return
    end

    inst.EnableDragonflyLight = EnableLight

    -- 骑龙蝇
    inst:ListenForEvent("mounted", function(inst, data)
        local target = data.target
        if target and target:HasTag("dragonfly_mount") then
            EnableFlyingMode(inst, true)
            if target.enraged then
                EnableLight(inst, true)
            end
            inst:AddTag("fireimmune")
        end
    end)

    -- 下龙蝇
    inst:ListenForEvent("dismounted", function(inst, data)
        local target = data.target
        if target and target:HasTag("dragonfly_mount") then
            EnableFlyingMode(inst, false)
            EnableLight(inst, false)
            inst:RemoveTag("fireimmune")
            -- 转而由龙蝇本身播放音效
            inst.SoundEmitter:KillSound("dragonfly_flying")
            if not target.SoundEmitter:PlayingSound("flying") then
                target.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
            end
            if not target.enraged then
                target.Light:Enable(false)
            end
        end
    end)

    -- 加载时检查位置自动骑乘
    local function HookTeleport(inst, fn)
        local new_fn = function(...)
            local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
            if not TheWorld.Map:IsPassableAtPoint(my_x, my_y, my_z) then
                local dragonfly_bell = inst.components.inventory and inst.components.inventory:FindItem(function(item)
                    return (item:HasTag("dragonfly_bell") and item:GetDragonfly() ~= nil)
                end)
                local dragonfly = dragonfly_bell and dragonfly_bell:GetDragonfly()
                if dragonfly and inst.components.rider then
                    -- 避免因饥饿无法骑乘
                    dragonfly.components.hunger:DoDelta(1)
                    inst.components.rider:Mount(dragonfly, true)
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "dragonfly_flying")
                    return
                end
            end
            return fn(...)
        end
        return new_fn
    end

    local _OnLoad = inst.OnLoad or function() end
    inst.OnLoad = function(inst, data, ...)
        local _DoTaskInTime = inst.DoTaskInTime
        inst.DoTaskInTime = function(inst, time, fn, ...)
            local info = debug.getinfo(fn, "S")
            local source = info and info.source or ""
            if string.find(source, "player_common.lua", 1, true) then
                fn = HookTeleport(inst, fn)
            end
            return _DoTaskInTime(inst, time, fn, ...)
        end

        _OnLoad(inst, data, ...)

        inst.DoTaskInTime = _DoTaskInTime
    end
end)
