local files = {
    "postinit/entityscript.lua",
    "postinit/loottables.lua",
    "postinit/stategraphs/SGcommon.lua",
    "postinit/stategraphs/SGwilson.lua",
    "postinit/stategraphs/SGwilson_client.lua",
    "postinit/prefabs/player.lua",
    "postinit/components/locomotor.lua",
    "postinit/actions.lua",
    "postinit/writeables.lua",
    "postinit/components/playercontroller.lua",
    "postinit/screens/playerhud.lua",
    "postinit/components/combat.lua",
    "postinit/stategraphs/SGdragonfly.lua",
    "postinit/widgets/statusdisplays.lua",
}

for _, file in ipairs(files) do
    modimport(file)
end
