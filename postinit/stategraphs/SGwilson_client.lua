local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
}

local function ClientCommonState(name, tags, server_states)
    return State({
        name = name,
        tags = tags,
        server_states = server_states,

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:Stop()
            end
            inst.sg:SetTimeout(2)
            inst:PerformPreviewBufferedAction()
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    })
end

local function ConfigureRunState(inst)
    inst.sg.statemem.riding = true
    if inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    else
        inst.sg.statemem.normalriding = true
    end
end

local states = {
    State{
        name = "dragonfly_mount_run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            ConfigureRunState(inst)
			inst.sg.mem.footsteps = 0

            inst.components.locomotor:RunForward()
			local anim = "run"
			inst.AnimState:PlayAnimation(anim.."_pre")
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dragonfly_mount_run")
                end
            end),
        },
    },
    State{
        name = "dragonfly_mount_run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            local anim = "run_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("dragonfly_mount_run")
        end,
    },
    State{
        name = "dragonfly_mount_run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()
			local anim = "run"
			inst.AnimState:PlayAnimation(anim.."_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "dragonfly_dodismountaction",
        tags = { "doing", "busy" },
		server_states = { "dragonfly_dodismountaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dismount")
            inst.AnimState:PushAnimation("dismount_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(2)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("heavy_mount")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("heavy_mount")
            inst.sg:GoToState("idle", true)
        end,
    },
    ClientCommonState(
        "dragonfly_taunt",
        {"doing", "busy"},
        {"dragonfly_taunt_pre", "dragonfly_taunt"}
    ),
    ClientCommonState(
        "dragonfly_transform_fire",
        {"doing", "busy"},
        {"dragonfly_transform_fire_pre", "dragonfly_transform_fire"}
    ),
}

for _, state in ipairs(states) do
    AddStategraphState("wilson_client", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

AddStategraphPostInit("wilson_client", function(sg)

end)
