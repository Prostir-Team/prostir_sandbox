---
--- Main window
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetZPos(10)

        self.Clicked = false

        self.OffsetX = 0
        self.OffsetY = 0

        self.CustomWidth = ScreenScale(100)
        self.CustomHeight = ScreenScale(100)
        self.CurrentHeight = self.CustomHeight

        self.Minimize = false 

        local topBar = vgui.Create("EditablePanel", self)
        if IsValid(topBar) then
            self.TopBar = topBar

            function topBar:OnMousePressed(key)
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                if key ~= MOUSE_LEFT then return end

                local cursorX, cursorY = input.GetCursorPos()
                local x, y = parent:GetX(), parent:GetY()

                parent.OffsetX = cursorX - x
                parent.OffsetY = cursorY - y

                local localCursorX, localCursorY = parent:LocalCursorPos()
                local scrollTall = ScreenScale(10)

                parent.Clicked = true
                self:SetCursor("sizeall")
            end

            function topBar:OnMouseReleased(key)
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                if key ~= MOUSE_LEFT then return end

                parent.Clicked = false 
                self:SetCursor("arrow")
            end
        end
    end

    function PANEL:Think()
        local cursorX, cursorY = input.GetCursorPos()

        if self.Clicked then
            self:SetPos(cursorX - self.OffsetX, cursorY - self.OffsetY)
        end
    end

    function PANEL:SetCloseButton(closebutton)
        local topBar = self.TopBar
        if not IsValid(topBar) then return end

        if closebutton then
            local closeButton = vgui.Create("DButton", topBar)
            if IsValid(closeButton) then
                self.CloseButton = closeButton

                closeButton:SetText("X")
                closeButton.DoClick = function ()
                    self:Remove()
                end
            end
        end

        local minimizeButton = vgui.Create("DButton", topBar)
        if IsValid(minimizeButton) then
            self.MinimizeButton = minimizeButton

            minimizeButton:SetText("-")
            minimizeButton.DoClick = function ()
                self.Minimize = not self.Minimize

                local infoPanel = self.InfoPanel
                if IsValid(infoPanel) then
                    infoPanel:SetVisible(not self.Minimize)
                end

                if self.Minimize then
                    local scrollTall = ScreenScale(10)

                    self.CustomHeight = scrollTall
                else
                    self.CustomHeight = self.CurrentHeight
                end

                self:PerformLayout()
            end
        end

        self:PerformLayout()
    end

    function PANEL:SetInfoPanel(classname)
        local infoPanel = vgui.Create(classname, self)
        if not IsValid(infoPanel) then return end

        self.InfoPanel = infoPanel
        self:PerformLayout()
    end

    function PANEL:SetWindowSize(wide, tall)
        local scrollTall = ScreenScale(10)
        local x = ScreenScale(200)
        local scrH = ScrH()

        self.CustomWidth = ScreenScale(wide)
        self.CustomHeight = ScreenScale(tall) + scrollTall
        self.CurrentHeight = self.CustomHeight

        self:PerformLayout()

        local h = self:GetTall()
        self:SetPos(x, scrH / 2 - h / 2)
    end

    function PANEL:SetWindowName(name)
        self.Name = name
    end

    function PANEL:PerformLayout(w, h)
        local wide, tall = ScreenScale(380), ScreenScale(300)
        local scrollTall = ScreenScale(10)

        self:SetSize(self.CustomWidth, self.CustomHeight)

        local topBar = self.TopBar
        if IsValid(topBar) then
            topBar:Dock(TOP)
            topBar:SetTall(scrollTall)
        end

        local closeButton = self.CloseButton
        if IsValid(closeButton) then
            closeButton:Dock(RIGHT)
        end

        local minimizeButton = self.MinimizeButton
        if IsValid(minimizeButton) then
            minimizeButton:Dock(RIGHT)
        end

        local infoPanel = self.InfoPanel
        if IsValid(infoPanel) then
            infoPanel:Dock(FILL)
            -- infoPanel:DockMargin(0, scrollTall, 0, 0)
        end
    end

    function PANEL:Paint(w, h)
        local scrollTall = ScreenScale(10)
        
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, scrollTall)
        
        if self.Name then
            local offsetX = ScreenScale(5)
            
            draw.DrawText(self.Name, "PRSBOX.Lobby.Font.Info", w / 2, 0, COLOR_BUTTON_TEXT, TEXT_ALIGN_CENTER)
        end
    end

    vgui.Register("PRSBOX.Lobby.Window", PANEL, "EditablePanel")
end