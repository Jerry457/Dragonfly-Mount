local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

AddStategraphPostInit("dragonfly", function(sg)
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
end)
