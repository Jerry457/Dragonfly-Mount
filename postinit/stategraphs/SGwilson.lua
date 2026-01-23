local SG_COMMON = SG_COMMON
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler = AddStategraphActionHandler

GLOBAL.setfenv(1, GLOBAL)

local actionhandlers = {
    -- ActionHandler(ACTIONS.GK_EQUIPSLOT_LEARN, "dolongaction"),
    -- ActionHandler(ACTIONS.GLUTTONY_EAT, function(inst, action)
    --     if not inst.sg:HasStateTag("busy") then
    --         return "quickeat"
    --     end
    -- end),
}

local states = {
}

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

local function ConfigureRunState(inst) 
    inst.sg.statemem.riding = true
    if inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    else
        inst.sg.statemem.normalriding = true
    end
    inst.sg:AddStateTag("nodangle")
    inst.sg:AddStateTag("noslip")
end

AddStategraphPostInit("wilson", function(sg)
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

        if is_moving and not should_move then
            inst.sg:GoToState("dragonfly_mount_run_stop")
        elseif not is_moving and should_move then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				inst.components.locomotor:SetMoveDir(data.dir)
			end
            inst.sg:GoToState("dragonfly_mount_run_start")
        end
    end

    -- dragonfly_mount_run
    sg.states.dragonfly_mount_run_start = State{
        name = "dragonfly_mount_run_start",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
			inst.sg.mem.footsteps = 0

            inst.components.locomotor:RunForward()
			local anim =  "run"
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
        tags = { "moving", "running", "canrotate", "autopredict" },

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
        tags = { "canrotate", "idle", "autopredict" },

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

    -- dragonfly_mount
    local mount_onenter = sg.states.mount.onenter
    sg.states.mount.onenter = function(inst, ...)
        local dragonfly = inst.components.rider.target_mount and inst.components.rider.target_mount:HasTag("dragonfly_mount")
        if dragonfly then
            inst.sg:GoToState("dragonfly_mount")
        else
            return mount_onenter(inst, ...)
        end
    end

    sg.states.dragonfly_mount = State{
        name = "dragonfly_mount",
        tags = { "doing", "busy", "nomorph", "nopredict" },

        onenter = function(inst)
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_mount" or "mount")

            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
        end,

        timeline =
        {
            --Heavy lifting
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
                end
            end),
            --Normal
            TimeEvent(14 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
                end

            end),
            --Heavy lifting
            TimeEvent(38 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
            --Normal
            TimeEvent(20 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },

        onexit = function(inst)
            -- 播放飞行音效
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "dragonfly_flying")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    }

    -- dragonfly_dismount
    local dismount_onenter = sg.states.dismount.onenter
    sg.states.dismount.onenter = function(inst, ...)
        local dragonfly = inst.components.rider.mount and inst.components.rider.mount:HasTag("dragonfly_mount")
        if dragonfly then
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
            -- 停止飞行音效
            inst.SoundEmitter:KillSound("dragonfly_flying")
        end
        return dismount_onenter(inst, ...)
    end

    -- castspell
    local castspell_onenter = sg.states.castspell.onenter
    sg.states.castspell.onenter = function(inst, ...)
        castspell_onenter(inst, ...)
        local rider = inst.replica.rider
        local mount = rider and rider:GetMount()
        if mount and mount:HasTag("dragonfly_mount") then
            if inst.sg.statemem.stafffx then
                inst.sg.statemem.stafffx:Remove()
            end
            -- 替换spell特效
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 1, 1, 1 }
            inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx_dragonfly")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)
        end
    end

    -- taunt技能
    sg.states.dragonfly_taunt = State({
        name = "dragonfly_taunt",
        tags = {"doing", "busy", "nopredict", "noattack", "nointerrupt"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.playercontroller:Enable(false)
            inst.components.playercontroller:RemotePausePrediction()
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("taunt")
            inst.sg:SetTimeout(3)
        end,

        timeline = {
            -- TimeEvent(10 * FRAMES, function(inst)
            --     inst.components.talker:Say(STRINGS.CHARACTERS.MAD_MITA.SKILLS_TALK.LETYOUSEE)
            --     local pos = inst:GetPosition()
            --     -- SpawnAt("miside_attune_in", Vector3(pos.x, 0.25, pos.z))
            -- end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,
    })
end)
