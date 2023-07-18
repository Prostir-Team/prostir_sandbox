---
--- Tab button
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.debug = false

        self.ButtonState = BUTTON_OPENED

        self.Active = false

        self.TextColor = COLOR_WHITE
        self.BackgroundColor = COLOR_WHITE
        self.MarkTall = 0
        self.Speed = GetConVar("presbox_lobby_button_speed"):GetInt()
    end

    function PANEL:Text(text)
        self.Text = text
    end

    function PANEL:PerformLayout()
        local tall = ScreenScale(20)

        self:SetTall(tall)
    end

    function PANEL:DoClick()
        local parent = self:GetParent()
        if not IsValid(parent) then return end

        parent:ResetActiveButtons()

        self.Active = true 
    end

    function PANEL:Paint(w, h)
        local marginLeft = ScreenScale(3)
        
        if self:IsHovered() or self.Active then
            self.TextColor = LerpColor(FrameTime() * self.Speed, self.TextColor, COLOR_BUTTON_BACKGROUND)
            self.MarkTall = Lerp(FrameTime() * self.Speed, self.MarkTall, h)
        else
            self.TextColor = LerpColor(FrameTime() * self.Speed * 2, self.TextColor, COLOR_WHITE)
            self.MarkTall = Lerp(FrameTime() * self.Speed, self.MarkTall, 0)
        end
        
        surface.SetDrawColor(self.BackgroundColor)
        surface.DrawRect(0, h - self.MarkTall, w, self.MarkTall)
        
        if not self.Text then return end

        draw.DrawText(self.Text, "PRSBOX.Lobby.Font.Button", marginLeft, ScreenScale(2.3), self.TextColor, TEXT_ALIGN_LEFT)
    end

    vgui.Register("PRSBOX.Lobby.TabButton", PANEL, "DButton")
end

--- 
--- Tab menu
---

do
    local PANEL = {}

    function PANEL:Init()
        self.Tabs = {}
        self.ButtonTabs = {}
    end

    function PANEL:AddTab(text, className)
        local tab = {
            ["text"] = text,
            ["className"] = className
        }
        
        table.insert(self.Tabs, tab)
    end

    function PANEL:InitButtons()
        for k, buttonInfo in ipairs(self.Tabs) do
            local button = vgui.Create("PRSBOX.Lobby.TabButton", self)
            if not IsValid(button) then continue end

            button:Text(buttonInfo["text"])

            table.insert(self.ButtonTabs, button)
        end
    end

    function PANEL:SetupButtonSize(w)
        local buttonWide = w / #self.Tabs
        
        for k, button in ipairs(self.ButtonTabs) do
            button:SetWide(buttonWide)
            button:SetX((k - 1) * buttonWide)
        end
    end

    function PANEL:ResetActiveButtons()
        for k, button in ipairs(self.ButtonTabs) do
            button.Active = false 
        end
    end

    function PANEL:PerformLayout(w, h)
        local tall = ScreenScale(20)

        self:SetTall(tall)

        self:SetupButtonSize(w)
    end

    function PANEL:Paint(w, h)
        -- surface.SetDrawColor(COLOR_RED)
        -- surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Lobby.TabMenu", PANEL, "EditablePanel")
end

---
--- TEST BUTTON
---
do
    local PANEL = {}

    function PANEL:Init()
        local tabMenu = vgui.Create("PRSBOX.Lobby.TabMenu", self)
        if IsValid(tabMenu) then
            self.TabMenu = tabMenu

            tabMenu:Dock(TOP)
            tabMenu:AddTab("Hello World", "test")
            tabMenu:AddTab("Hello World", "test")
            tabMenu:AddTab("Hello World", "test")
            tabMenu:AddTab("Hello World", "test")
            tabMenu:AddTab("Hello World", "test")

            tabMenu:InitButtons()
        end
    end

    vgui.Register("TEST.Button", PANEL, "EditablePanel")
end