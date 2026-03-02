local files = {
    "postinit/actions.lua",
    "postinit/entityscript.lua",
    "postinit/loottables.lua",
    "postinit/writeables.lua",
    "postinit/components/combat.lua",
    "postinit/components/locomotor.lua",
    "postinit/components/playercontroller.lua",
    "postinit/prefabs/dragonfly.lua",
    "postinit/prefabs/player.lua",
    "postinit/screens/playerhud.lua",
    "postinit/stategraphs/SGcommon.lua",
    "postinit/stategraphs/SGdragonfly.lua",
    "postinit/stategraphs/SGwilson.lua",
    "postinit/stategraphs/SGwilson_client.lua",
    "postinit/widgets/statusdisplays.lua"
}

for _, file in ipairs(files) do
    modimport(file)
end
