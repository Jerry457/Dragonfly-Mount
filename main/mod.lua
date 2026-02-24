local AddSimPostInit = AddSimPostInit

GLOBAL.setfenv(1, GLOBAL)
global("HUA_SKILL_CONSTANTS")
global("DragonflyMountHookOnRemoteLeftClick")

-- 修复神话书说施法
AddSimPostInit(function()
    if HUA_SKILL_CONSTANTS and HUA_SKILL_CONSTANTS.SKILL_RETICULE_INDEX then
        local notified = false
        local default = HUA_SKILL_CONSTANTS.SKILL_RETICULE_INDEX["mk_yzqt"] or {}

        local mt = {
            __index = function(t, k)
                if not notified then
                    notified = true
                    print("Invalid key", k, "Fallback to default")
                    if TheWorld.ismastersim then
                        TheNet:Announce("[Dragonfly Mount]神话书说模组与轮盘施法不兼容！")
                    end
                end
                return default
            end
        }
        setmetatable(HUA_SKILL_CONSTANTS.SKILL_RETICULE_INDEX, mt)

        -- -- 由于神话覆盖，需要重新hook
        -- if DragonflyMountHookOnRemoteLeftClick then
        --     DragonflyMountHookOnRemoteLeftClick()
        -- end
    end
end)
