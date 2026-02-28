local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

AddStategraphPostInit("dragonfly", function(sg)
    -- grow
    sg.states.grow_pre = State{
        name = "grow_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("grow_pre")
        end,

        events =
        {
			EventHandler("animover", function(inst)
                inst.sg:GoToState("grow_pst")
            end),
        },

        onexit = function(inst)
            inst.components.growable:SetStage(inst.components.growable:GetNextStage())
        end,
    }

    sg.states.grow_pst = State{
        name = "grow_pst",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("grow_pst")
        end,

        events =
        {
			EventHandler("animover", function(inst)
			    inst.sg:GoToState("idle")
            end),
        },
    }

    -- eat
    sg.events.eat = EventHandler("eat", function(inst, data)
        if not inst.components.health:IsDead()
            and not inst.sg:HasStateTag("attack")
            and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("eat", data)
        end
    end)

    sg.states.eat = State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomit")
        end,

        events =
        {
			EventHandler("animover", function(inst)
			    inst.sg:GoToState("idle")
            end),
        },
    }

    -- refuse
    sg.events.refuse = EventHandler("refuse", function(inst)
        if not inst.components.health:IsDead()
            and not inst.sg:HasStateTag("attack")
            and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("refuse")
        end
    end)

    sg.states.refuse = State{
        name = "refuse",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("refuse")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
        end,

        events =
        {
			EventHandler("animover", function(inst)
			    inst.sg:GoToState("idle")
            end),
        },
    }

    -- hungry
    sg.events.hungry = EventHandler("hungry", function(inst)
        if not inst.components.health:IsDead()
            and not inst.sg:HasStateTag("attack")
            and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("hungry")
        end
    end)

    sg.states.hungry = State{
        name = "hungry",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hungry")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")

            inst.components.timer:StopTimer("play_hungry_cd")
            inst.components.timer:StartTimer("play_hungry_cd", 30)

            if inst.ShowHungryIcon then
                inst:ShowHungryIcon()
            end
        end,

        events =
        {
			EventHandler("animover", function(inst)
			    inst.sg:GoToState("idle")
            end),
        },
    }

    -- 饥饿时在idle中播放hungry
    local idle_onenter = sg.states.idle.onenter
    sg.states.idle.onenter = function(inst, ...)
        if inst:HasTag("dragonfly_mount") then
            local hungry = inst.components.hunger and inst.components.hunger:GetPercent() <= 0
            if hungry and not inst.components.timer:TimerExists("play_hungry_cd") then
                inst.sg:GoToState("hungry")
                return
            end
        end
        return idle_onenter(inst, ...)
    end

    -- 死亡时如果被骑乘，稍后处理
    local death_fn = sg.events.death.fn
    sg.events.death.fn = function(inst, ...)
        if not inst:HasTag("dragonfly_mount") or inst.components.rideable == nil or not inst.components.rideable:IsBeingRidden() then
            return death_fn(inst, ...)
        end
    end

    -- 被铃铛收回
    sg.states.bell_recall = State{
        name = "bell_recall",
		tags = { "flight", "busy", "nosleep", "nofreeze", "noelectrocute" },

        onenter = function(inst)
            inst:StopBrain()
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("walk_angry_pre")
            inst.AnimState:PushAnimation("walk_angry", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")

            local x, y, z = 0.5019684438612,12.5216834009827,2.7178563798944
            inst.Physics:SetMotorVel(x, y, z)
        end,

        timeline =
        {
            TimeEvent(2.5, function(inst)
                inst:DoRecallDespawn()
            end)
        },

        onexit = function(inst)
            --You somehow left this state?! (not supposed to happen).
            --Cancel the action to avoid getting stuck.
            print("Dragonfly left the bell_recall state! How could this happen?!")
            inst:DoRecallDespawn()
        end,
    }

    -- 被铃铛召唤
    sg.states.bell_summon = State{
        name = "bell_summon",
		tags = { "flight", "busy", "noelectrocute" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_angry", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
            inst.Physics:SetMotorVelOverride(0, -11, 0)
            inst.DynamicShadow:Enable(false)
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVelOverride(0, -15, 0)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 0.5 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.sg:GoToState("idle", { softstop = true })
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 0 then
                inst.Transform:SetPosition(x, 0, z)
            end
            inst.Physics:ClearMotorVelOverride()
            inst.DynamicShadow:Enable(true)

            inst.components.timer:StopTimer("play_hungry_cd")
            inst.components.timer:StartTimer("play_hungry_cd", 5)
        end,
    }
end)
