local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
}

local states = {
}

for _, state in ipairs(states) do
    AddStategraphState("wilson_client", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson_client", actionhandler)
end

local function ConfigureRunState(inst) 
    inst.sg.statemem.riding = true
    if inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    else
        inst.sg.statemem.normalriding = true
    end
end

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

AddStategraphPostInit("wilson_client", function(sg)
    -- 修改locomote事件目标state
    local locomote_fn = sg.events.locomote.fn
    sg.events.locomote.fn = function(inst, data)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if not mount or not mount:HasTag("dragonfly_mount") then
            return locomote_fn(inst, data)
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if not inst.entity:CanPredictMovement() then
            if not inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle")
            end
        elseif is_moving and not should_move then
            inst.sg:GoToState("dragonfly_mount_run_stop")
        elseif not is_moving and should_move then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				if inst.components.locomotor then
					inst.components.locomotor:SetMoveDir(data.dir)
				else
					inst.Transform:SetRotation(data.dir)
				end
			end
            inst.sg:GoToState("dragonfly_mount_run_start")
        end
    end

    -- dragonfly_mount_run
    sg.states.dragonfly_mount_run_start = State{
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

        timeline =
        {
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dragonfly_mount_run")
                end
            end),
        },
    }

    sg.states.dragonfly_mount_run = State{
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

        timeline =
        {
        },

        ontimeout = function(inst)
            inst.sg:GoToState("dragonfly_mount_run")
        end,
    }

    sg.states.dragonfly_mount_run_stop = State{
        name = "dragonfly_mount_run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()
			local anim = "run"
			inst.AnimState:PlayAnimation(anim.."_pst")
        end,

        timeline =
        {
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }

    -- taunt技能
    sg.states.dragonfly_taunt = ClientCommonState("dragonfly_taunt", {"doing", "busy"}, {"dragonfly_taunt"})
end)
