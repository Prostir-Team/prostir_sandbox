CreateClientConVar("prsbox_lobby_button_speed", "10", true, false, "", 5, 100)

--- Button colors

local ButtonColors = {
    [BUTTON_OPENED] = COLOR_BUTTON_TEXT,
    [BUTTON_CLOSED] = COLOR_BUTTON_TEXT_LOCKED
}

---
--- Modern button for lobby menu
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.debug = false

        self.ButtonState = BUTTON_OPENED

        self.TextColor = COLOR_WHITE
        self.BackgroundColor = COLOR_BUTTON_NONE
        self.MarkWide = 0
        self.MarkWideMax = ScreenScale(5)
        self.Speed = GetConVar("prsbox_lobby_button_speed"):GetInt()
    end

    function PANEL:Text(text)
        self.Text = text
    end

    function PANEL:PerformLayout()
        local tall = ScreenScale(20)
        
        self:SetTall(tall)
    end

    function PANEL:Paint(w, h)
        local marginLeft = ScreenScale(3)
        
        if self:IsHovered() then
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_BACKGROUND)
            self.TextColor = LerpColor(FrameTime() * self.Speed, self.TextColor, ButtonColors[self.ButtonState])
            self.MarkWide = Lerp(FrameTime() * self.Speed, self.MarkWide, self.MarkWideMax)
        else
            self.TextColor = LerpColor(FrameTime() * self.Speed, self.TextColor, COLOR_WHITE)
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_NONE)

            self.MarkWide = Lerp(FrameTime() * self.Speed, self.MarkWide, 0)
        end
        
        surface.SetDrawColor(self.BackgroundColor)
        surface.DrawRect(self.MarkWide, 0, w - self.MarkWide, h)

        surface.SetDrawColor(ButtonColors[self.ButtonState])
        surface.DrawRect(0, 0, self.MarkWide, h)
        
        if not self.Text then return end

        draw.DrawText(self.Text, "PRSBOX.Lobby.Font.Button", marginLeft + self.MarkWide, ScreenScale(2.3), self.TextColor, TEXT_ALIGN_LEFT)
    end

    vgui.Register("PRSBOX.Lobby.Button", PANEL, "DButton")
end
