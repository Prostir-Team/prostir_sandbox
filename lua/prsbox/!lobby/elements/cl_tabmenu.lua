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
        self.Speed = GetConVar("prsbox_lobby_button_speed"):GetInt()

    end

    function PANEL:Text(text)
        self.text = text
    end

    function PANEL:SetMenuClassName(className)
        self.MenuClassName = className
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

        parent:OpenMenu(self.text, self.MenuClassName, self.callback)
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
        
        if not self.text then return end

        draw.DrawText(self.text, "PRSBOX.Lobby.Font.Button", marginLeft, ScreenScale(2.3), self.TextColor, TEXT_ALIGN_LEFT)
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

    function PANEL:AddTab(text, className, callback)
        local tab = {
            ["text"] = text,
            ["className"] = className,
            ["callback"] = callback
        }
        
        table.insert(self.Tabs, tab)
    end

    function PANEL:InitButtons()
        for k, buttonInfo in ipairs(self.Tabs) do
            local button = vgui.Create("PRSBOX.Lobby.TabButton", self)
            if not IsValid(button) then continue end

            button:Text(buttonInfo["text"])
            button:SetMenuClassName(buttonInfo["className"])
            button.callback = buttonInfo["callback"]

            table.insert(self.ButtonTabs, button)
        end

        local firstButton = self.ButtonTabs[1]
        if not IsValid(firstButton) then return end

        firstButton.Active = true
        
        self:OpenMenu(firstButton.text, firstButton.MenuClassName, firstButton.callback)
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

    function PANEL:OnMenuOpen(buttonText, menu)

    end

    function PANEL:OpenMenu(buttonText, className, callback)
        if IsValid(self.CurrentMenu) then
            self.CurrentMenu:Remove()
        end
        
        local parent = self:GetParent()
        if not IsValid(parent) then return end

        print(className)

        local menuPanel = vgui.Create(className, parent)
        if not IsValid(menuPanel) then return end
        self.CurrentMenu = menuPanel

        menuPanel:Dock(FILL)

        callback(buttonText, menuPanel)
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
            for i=1, 5 do
                tabMenu:AddTab("TEST " .. i, "TEST.TAB")
            end

            tabMenu:InitButtons()
        end
    end

    vgui.Register("TEST.Button", PANEL, "EditablePanel")
end

---
--- TEST TAB
---
do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("Hello World")
    end

    vgui.Register("TEST.TAB", PANEL, "DButton")
end