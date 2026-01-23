GLOBAL.setfenv(1, GLOBAL)

local Playerhud = require("screens/playerhud")

local _OpenSpellWheel = Playerhud.OpenSpellWheel
function Playerhud:OpenSpellWheel(invobject, ...)
    if invobject and invobject:HasTag("dragonfly_mount") then
        local screenwidth, screenheight = TheSim:GetScreenSize()
        local mouse_x, mouse_y = TheSim:GetPosition()
        -- 到鼠标位置
        self.controls.commandwheelroot:SetPosition(mouse_x - screenwidth/2, mouse_y - screenheight/2)
    end
    return _OpenSpellWheel(self, invobject, ...)
end

local _CloseSpellWheel = Playerhud.CloseSpellWheel
function Playerhud:CloseSpellWheel(...)
    self.controls.commandwheelroot:SetPosition(0, 0)
    return _CloseSpellWheel(self, ...)
end