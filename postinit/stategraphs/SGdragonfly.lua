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
        end,

        events =
        {
			EventHandler("animover", function(inst)
			    inst.sg:GoToState("idle")
            end),
        },
    }
end)
