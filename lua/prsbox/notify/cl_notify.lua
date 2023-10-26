---
--- Fonts
---

---
--- Variables
---

Notifications = Notifications or {}
local hudPanel = GetHUDPanel()

local Colors = {}
Colors[NOTIFY_GENERIC] = Color(97, 113, 130, 200)
Colors[NOTIFY_ERROR] = Color(255, 92, 88, 200)
Colors[NOTIFY_UNDO] = Color(0, 255, 102, 200)
Colors[NOTIFY_HINT] = Color(0, 174, 255, 200)
Colors[NOTIFY_CLEANUP] = Color(255, 157, 0, 200)

do
    local PANEL = {}

    function PANEL:Init()
        local message = vgui.Create("DLabel", self)
        if IsValid(message) then
            self.Message = message

            message:SetFont("PRSBOX.Lobby.Font.Info")
            message:SetTextColor(COLOR_WHITE)
        end
    end

    function PANEL:SetNotify(text, type, length)
        self.Text = text
        self.Type = type
        self.Length = length

        local message = self.Message
        if IsValid(message) then
            message:SetText(self.Text)
            message:SetAutoStretchVertical(true)
            message:SetWrap(true)
        end
    end

    function PANEL:PerformLayout(w, h)
        local message = self.Message
        if not IsValid(message) then return end
        
        local messageMaringWide = ScreenScale(5)
        
        local messageMarginTall = ScreenScale(3)
        local halfMessageMargin = messageMarginTall / 2

        surface.SetFont("PRSBOX.Lobby.Font.Info")
        local notifyWideMax = ScreenScale(200)
        local messageWide, messageTall = surface.GetTextSize(self.Text)

        local mTall = messageTall

        messageWide = messageWide + mTall * 2
        messageTall = messageTall + messageMarginTall

        message:SetPos(mTall * 1.3, halfMessageMargin)

        if messageWide >= notifyWideMax then
            self:SetWide(notifyWideMax)
            self:SetTall(message:GetTall() + messageMarginTall)
            message:SetWide(notifyWideMax - mTall * 2)
        else
            self:SetSize(messageWide, messageTall)
            message:SetWide(messageWide)
        end

        self:SetPos(100, 100)    
    end

    function PANEL:Paint(w, h)
        surface.SetFont("PRSBOX.Lobby.Font.Info")
        local _, tall = surface.GetTextSize(self.Text)
        
        local round = ScreenScale(5)
        local offset = ScreenScale(4)
        
        
        draw.RoundedBoxEx(tall, 0, 0, tall, h, Colors[self.Type], true, false, true, false)
        draw.RoundedBoxEx(round, tall, 0, w - tall, h, COLOR_BUTTON_BACKGROUND, false, true, false, true)
    end

    vgui.Register("PRSBOX.Notify", PANEL, "EditablePanel")
end

for k, notify in ipairs(Notifications) do
    if IsValid(notify) then
        notify:Remove()
    end
end

function notification.AddLegacy(text, type, length)
    local notify = vgui.Create("PRSBOX.Notify", hudPanel)
    notify:SetNotify(text, type, length)

    table.insert(Notifications, notify)
end


concommand.Add("test_notify", function (ply, cmd, args)
    notification.AddLegacy("Test notification", NOTIFY_HINT, 10)
end)