---
--- Fonts
---

---
--- Variables
---

Notifications = Notifications or {}
local hudPanel = GetHUDPanel()

local notifySpeed = 10

local Colors = {}
Colors[NOTIFY_GENERIC] = Color(97, 113, 130, 200)
Colors[NOTIFY_ERROR] = Color(255, 92, 88, 200)
Colors[NOTIFY_UNDO] = Color(0, 255, 102, 200)
Colors[NOTIFY_HINT] = Color(0, 174, 255, 200)
Colors[NOTIFY_CLEANUP] = Color(255, 157, 0, 200)

local Icons = {}
Icons[NOTIFY_GENERIC] = Material("notify/notify_generic.png", "smooth")
Icons[NOTIFY_ERROR] = Material("notify/notify_error.png", "smooth")
Icons[NOTIFY_UNDO] = Material("notify/notify_undo.png", "smooth")
Icons[NOTIFY_HINT] = Material("notify/notify_hint.png", "smooth")
Icons[NOTIFY_CLEANUP] = Material("notify/notify_hint.png", "smooth")

---
--- Local functions
---

local function printNotify()
    for k, v in ipairs(Notifications) do
        print(v.Text)
    end
end

local function deleteNotify(index)
    if #Notifications == index then 
        table.remove(Notifications, index)
        return 
    end

    local notify = Notifications[index]
    
    if not IsValid(notify) then return end
    
    local nextNotify = Notifications[index + 1]
    if not IsValid(nextNotify) then return end

    nextNotify:SetPreviousNotify(notify.PreviousNotify)

    table.remove(Notifications, index)

    for k, n in ipairs(Notifications) do
        if not IsValid(n) then continue end
        
        if k >= index then
            n:SetVerticalPos(k)
        end
    end
end

---
--- Notify
---

do
    local PANEL = {}

    function PANEL:Init()
        local scrW, scrH = ScrW(), ScrH()
        self:SetPos(scrW, scrH)

        self.RemoveState = false

        local message = vgui.Create("DLabel", self)
        if IsValid(message) then
            self.Message = message

            message:SetFont("PRSBOX.Lobby.Font.Info")
            message:SetTextColor(COLOR_WHITE)
        end

        surface.PlaySound("notify/notify.wav")
    end

    function PANEL:SetNotify(text, type, length)
        self.Text = text
        self.Type = type
        self.Icon = Icons[type]
        self.Length = length or 5
        self.Time = CurTime()

        local message = self.Message
        if IsValid(message) then
            message:SetText(self.Text)
            message:SetAutoStretchVertical(true)
            message:SetWrap(true)
        end

        self:PerformLayout()
    end

    function PANEL:SetVerticalPos(pos)
        self.VerticalPos = pos
    end

    function PANEL:SetPreviousNotify(panel)
        if not IsValid(panel) then return end
        
        self.PreviousNotify = panel
    end

    function PANEL:Start()
        timer.Simple(self.Length, function ()
            deleteNotify(self.VerticalPos)
            
            self.RemoveState = true
        end)
    end

    function PANEL:GetWishX()
        local wishX = 0
        local scrW = ScrW()

        if self.RemoveState then
            wishX = scrW * 1.5
        else
            local wide = self:GetWide()
            local marginRight = ScreenScale(20)

            wishX = scrW - marginRight - wide
        end

        return wishX
    end

    function PANEL:GetWishY()
        local scrH = ScrH()
        local tall = self:GetTall()
        local marginBottom = ScreenScale(50)
        
        local wishY = scrH - marginBottom - tall

        return wishY
    end

    function PANEL:Think()
        local offset = ScreenScale(5)

        local x, y = self:GetPos()
        local scrW = ScrW()
        
        if x >= scrW * 1.2 then
            self:Remove()
        end

        local frameTime = FrameTime()

        local wishX = self:GetWishX()
        local wishY = 0

        local prevNotify = self.PreviousNotify
        if IsValid(prevNotify) then
            local tall = self:GetTall()

            wishY = prevNotify:GetY() - offset - tall
        else
            wishY = self:GetWishY()
        end

        self:SetPos(Lerp(frameTime * notifySpeed, x, wishX), Lerp(frameTime * notifySpeed, y, wishY))
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

        local barSize = 0

        if self.Length >= 10 then
            barSize = ScreenScale(7)
        end 

        if messageWide >= notifyWideMax then
            self:SetWide(notifyWideMax)
            self:SetTall(message:GetTall() + messageMarginTall + barSize)
            message:SetWide(notifyWideMax - mTall * 2)
        else
            self:SetSize(messageWide, messageTall)
            message:SetWide(messageWide)
        end
    end

    function PANEL:Paint(w, h)
        surface.SetFont("PRSBOX.Lobby.Font.Info")
        local _, tall = surface.GetTextSize(self.Text)
        local offset = ScreenScale(0.4)
        local size = tall - offset
        
        local round = ScreenScale(2)
        local offset = ScreenScale(1)
        
        draw.RoundedBox(round, 0, 0, tall, h, Colors[self.Type])
        draw.RoundedBox(round, tall + offset, 0, w - tall - offset, h, COLOR_BUTTON_BACKGROUND)

        surface.SetDrawColor(COLOR_WHITE)
        surface.SetMaterial(self.Icon)
        surface.DrawTexturedRect(offset / 2, h / 2 - size / 2, size, size)

        local barX = tall + offset * 2
        local barY = h - offset * 3
        local barWide = w - barX - offset
        local currentBar = math.Clamp((CurTime() - self.Time), 0, self.Length) / self.Length

        draw.RoundedBox(3, barX, barY, barWide * currentBar, offset * 2, Colors[self.Type])
    end

    vgui.Register("PRSBOX.Notify", PANEL, "EditablePanel")
end

for k, notify in ipairs(Notifications) do
    if IsValid(notify) then
        notify:Remove()
    end
end

Notifications = {}

function notification.AddLegacy(text, type, length)
    local notify = vgui.Create("PRSBOX.Notify", hudPanel)
    notify:SetNotify(text, type, length)

    local notifyLenght = #Notifications

    if notifyLenght > 0 then
        notify:SetPreviousNotify(Notifications[notifyLenght])
    end

    table.insert(Notifications, notify)
    notify:SetVerticalPos(#Notifications)

    notify:Start()
end

net.Receive("PRSBOX.NotifySend", function (len)
    local text = net.ReadString()
    local type = net.ReadInt(6)
    local length = net.ReadInt(10)

    notification.AddLegacy(text, type, length)
end)

concommand.Add("print_notify", function()
    -- printNotify()
end)

concommand.Add("test_notify", function (ply, cmd, args)
    notification.AddLegacy("Hello World", NOTIFY_ERROR, 30)
end)