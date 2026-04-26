-- This information tells other players more about the mod
name = "Move!!Dragonfly"  ---mod名字
version = "26.04.05" -- mod版本 上传mod需要两次的版本不一样
description ="·在饥荒世界中，挑战并击败强大的BOSS——龙蝇，即可获得珍贵的龙蝇蛋。\n·收集龙蝇蛋后，你可以进行孵化，耐心等待小龙蝇破壳而出。\n·龙蝇孵化后，需要通过喂养使其逐渐成长，待龙蝇完全长大，你将可以骑乘它穿梭于饥荒世界，解锁全新的移动体验！\n󰀀!!!兼容性!!!：\n·模组目前使用了Glassic API来实现龙蝇皮肤，无法兼容使用了Modded API的皮肤模组。"  --mod描述
author = "WIGFRID、Guto、jerry457" --作者

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name .. "-dev"
end

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true --兼容联机

-- Not compatible with Don't Starve
dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

-- Character mods need this set to true
all_clients_require_mod = true --所有人mod

priority = -1

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {  --服务器标签
    "dragonfly_mount",
}

local ZH = (locale == "zh" or locale == "zhr")

local function AddSetting(name, label, hover, default, options)
    return {
        name = name,
        label = label,
        hover = hover,
        options = options,
        default = default
    }
end

local mult_options = {
    {description="0.25",data=0.25},
    {description="0.5",data=0.5},
    {description="0.75",data=0.75},
    {description="1.0",data=1.0},
    {description="1.25",data=1.25},
    {description="1.5",data=1.5},
    {description="1.75",data=1.75},
    {description="2.0",data=2.0},
}

local grow_days = {
    {description="1",data=1},
    {description="3",data=3},
    {description="5",data=5},
    {description="7",data=7},
    {description="9",data=9},
    {description="11",data=11},
}

configuration_options = {
    ZH and
    AddSetting("damage_mult", "龙蝇伤害系数", "龙蝇伤害系数", 1.0, mult_options)
    or
    AddSetting("damage_mult", "Damage Mult", "Damage Mult", 1.0, mult_options)
    ,

    ZH and
    AddSetting("health_mult", "龙蝇生命系数", "龙蝇生命系数", 1.0, mult_options)
    or
    AddSetting("health_mult", "Health Mult", "Health Mult", 1.0, mult_options)
    ,

    ZH and
    AddSetting("grow_days", "成长天数", "成长天数", 5, grow_days)
    or
    AddSetting("grow_days", "Grow Days", "Grow Days", 5, grow_days)
    ,
}
