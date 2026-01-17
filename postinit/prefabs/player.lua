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
    elseif inst.components.drownable.enabled == false then
        inst.components.drownable.enabled = true
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

local function EnableFlyingSound(inst, enable)
    if inst.SoundEmitter == nil then
        return
    end

    if enable then
        if not inst.SoundEmitter:PlayingSound("dragonfly_flying") then
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "dragonfly_flying")
        end
    else
        inst.SoundEmitter:KillSound("dragonfly_flying")
    end
end

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

    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("mounted", function(inst, data)
        local target = data.target
        if target and target:HasTag("dragonfly_mount") then
            EnableFlyingMode(inst, true)
            EnableLight(inst, true)
            EnableFlyingSound(inst, true)
        end
    end)

    inst:ListenForEvent("dismounted", function(inst, data)
        local target = data.target
        if target and target:HasTag("dragonfly_mount") then
            EnableFlyingMode(inst, false)
            EnableLight(inst, false)
            EnableFlyingSound(inst, false)
        end
    end)
end)

