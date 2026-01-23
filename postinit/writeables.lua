

GLOBAL.setfenv(1, GLOBAL)
local writeables = require "writeables"

local dragonfly_mount_layout =
{
    prompt = STRINGS.SIGNS.MENU.PROMPT_DRAGONFLY,
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),
	maxcharacters = TUNING.BEEFALO_NAMING_MAX_LENGTH,


    defaulttext = function(inst, doer)
        return subfmt(STRINGS.NAMES.DRAGONFLY_BUDDY_NAME, { buddy = doer.name })
    end,

    cancelbtn = {
        text = STRINGS.BEEFALONAMING.MENU.CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },
    middlebtn = {
        text = STRINGS.BEEFALONAMING.MENU.RANDOM,
        cb = function(inst, doer, widget)
            local name_index = math.random(#STRINGS.DRAGONFLYNAMING.DRAGONFLYNAMES)
            widget:OverrideText(STRINGS.DRAGONFLYNAMING.DRAGONFLYNAMES[name_index] )
        end,
        control = CONTROL_MENU_MISC_2
    },
    acceptbtn = {
        text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
}

writeables.AddLayout("dragonfly_mount", dragonfly_mount_layout)