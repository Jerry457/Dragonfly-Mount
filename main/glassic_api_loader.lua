if GLOBAL.rawget(GLOBAL, "GlassicAPI") then
    return
end

local _mod_root = MODROOT
local _assets = Assets
local _prefabfiles = PrefabFiles
local _preloadassets = PreloadAssets

MODROOT = MODROOT .. "GlassicAPI/"
Assets = {}
PrefabFiles = {}
PreloadAssets = {}

modimport("modmain")

MODROOT = _mod_root
GLOBAL.ArrayUnion(_assets, Assets)
GLOBAL.ArrayUnion(_prefabfiles, PrefabFiles)
GLOBAL.ArrayUnion(_preloadassets, PreloadAssets)
Assets = _assets
PrefabFiles = _prefabfiles
PreloadAssets = _preloadassets
