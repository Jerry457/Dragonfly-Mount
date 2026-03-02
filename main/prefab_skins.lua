GLOBAL.setfenv(1, GLOBAL)

dragonfly_mount_clear_fn = function(inst) basic_clear_fn(inst, "dragonfly_mount_build") end

GlassicAPI.SkinHandler.AddModSkins({
    dragonfly_mount = {
        "dragonfly_mount_yule",
    }
})
