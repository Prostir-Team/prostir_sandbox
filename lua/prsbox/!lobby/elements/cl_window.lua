---
--- Top bar buttons
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")

        self.CurrentColor = table.Copy(COLOR_BUTTON_TEXT)
    end

    function PANEL:SetWindowIcon(path)
        self.IconMaterial = Material(path, "smooth")
    end 

    function PANEL:Paint(w, h)
        if self:IsHovered() then
            self.CurrentColor = LerpColor(FrameTime() * 10, self.CurrentColor, COLOR_WHITE)
        else
            self.CurrentColor = LerpColor(FrameTime() * 10, self.CurrentColor, COLOR_BUTTON_TEXT)
        end
        
        surface.SetDrawColor(self.CurrentColor)

        if self.IconMaterial then
            local offset = ScreenScale(2)
            local size = h - offset

            surface.SetMaterial(self.IconMaterial)
            surface.DrawTexturedRect(w/2 - size/2, offset / 2, size, size)
        end
    end

    vgui.Register("PRSBOX.Window.Button", PANEL, "DButton")
end

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

                local lobby = parent.Lobby
                -- if not IsValid(lobby) then return end
                lobby:ChangeZPosWindow(parent.InfoClassName)

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

    function PANEL:CloseWindow()
        local parent = self:GetParent()
        if not IsValid(parent) then return end
        
        parent:OnWindowClose(self.InfoClassName)
        self:Remove()
    end

    function PANEL:SetLobby(lobby)
        self.Lobby = lobby
    end

    function PANEL:SetCloseButton(closebutton)
        local topBar = self.TopBar
        if not IsValid(topBar) then return end

        if closebutton then
            local closeButton = vgui.Create("PRSBOX.Window.Button", topBar)
            if IsValid(closeButton) then
                self.CloseButton = closeButton

                closeButton:SetWindowIcon("prostir/ui/CloseButton.png")
                closeButton.DoClick = function ()
                    self:CloseWindow()
                end
            end
        end

        local minimizeButton = vgui.Create("PRSBOX.Window.Button", topBar)
        if IsValid(minimizeButton) then
            self.MinimizeButton = minimizeButton

            minimizeButton:SetWindowIcon("prostir/ui/MinimizeButton.png")
            minimizeButton.DoClick = function ()
                self.Minimize = not self.Minimize

                if self.Minimize then
                    local scrollTall = ScreenScale(10)

                    self.CustomHeight = scrollTall
                else
                    self.CustomHeight = self.CurrentHeight

                    local infoPanel = self.InfoPanel
                    if IsValid(infoPanel) then
                        infoPanel:SetVisible(true)
                    end
                end
                local wide = self:GetWide()

                self:SizeTo(wide, self.CustomHeight, 0.1, 0, -1, function ()
                    if self.Minimize == false then return end

                    local infoPanel = self.InfoPanel
                    if IsValid(infoPanel) then
                        infoPanel:SetVisible(false)
                    end
                end)
            end
        end
    end

    function PANEL:SetInfoPanel(classname)
        local infoPanel = vgui.Create(classname, self)
        if not IsValid(infoPanel) then return end


        self.InfoClassName = classname
        self.InfoPanel = infoPanel
        self:PerformLayout()
    end

    function PANEL:GiveData(data)
        local infoPanel = self.InfoPanel
        if not IsValid(infoPanel) then return end

        infoPanel.Data = data

        if infoPanel.FullInit then
            infoPanel:FullInit()
        end
    end

    function PANEL:SetWindowSize(wide, tall)
        local scrollTall = ScreenScale(10)
        local x = ScreenScale(200)
        local scrH = ScrH()

        self.CustomWidth = ScreenScale(wide)
        self.CustomHeight = ScreenScale(tall) + scrollTall
        self.CurrentHeight = self.CustomHeight

        self:SetSize(self.CustomWidth, self.CustomHeight)

        self:SetPos(x, scrH / 2 - self.CustomHeight / 2)
    end

    function PANEL:SetWindowName(name)
        self.Name = name
    end

    function PANEL:PerformLayout(w, h)
        local wide, tall = ScreenScale(380), ScreenScale(300)
        local scrollTall = ScreenScale(10)

        -- self:SetSize(self.CustomWidth, self.CustomHeight)

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