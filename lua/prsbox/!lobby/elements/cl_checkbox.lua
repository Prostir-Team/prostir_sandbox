---
--- Checkbox button
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.debug = false

        self.ButtonState = BUTTON_OPENED

        self.Active = false

        self.TextColor = COLOR_WHITE
        self.BackgroundColor = COLOR_BUTTON_WHITE_NONE
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

    function PANEL:Paint(w, h)
        local marginLeft = ScreenScale(3)
        
        if self:IsHovered() or self.Active then
            self.TextColor = LerpColor(FrameTime() * self.Speed, self.TextColor, COLOR_BUTTON_BACKGROUND)
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_WHITE)
        else
            self.TextColor = LerpColor(FrameTime() * self.Speed * 2, self.TextColor, COLOR_WHITE)
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_WHITE_NONE)
        end
        
        surface.SetDrawColor(self.BackgroundColor)
        surface.DrawRect(0, 0, w, h)
        
        if not self.text then return end

        draw.DrawText(self.text, "PRSBOX.Lobby.Font.Button", w / 2, ScreenScale(2.3), self.TextColor, TEXT_ALIGN_CENTER)
    end

    vgui.Register("PRSBOX.Lobby.CheckboxButton", PANEL, "DButton")
end

---
--- Check box panel
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetZPos(10)

        self.State = CHECKBOX_GOOD

        local titleLabel = vgui.Create("DLabel", self)
        if IsValid(titleLabel) then
            self.TitleLabel = titleLabel

            titleLabel:SetFont("PRSBOX.Lobby.Font.Big")
            titleLabel:SetColor(COLOR_BUTTON_BACKGROUND)
            titleLabel:SetText("")
        end

        local textLabel = vgui.Create("RichText", self)
        if IsValid(textLabel) then
            self.TextLabel = textLabel
        end

        local yesButton = vgui.Create("PRSBOX.Lobby.CheckboxButton", self)
        if IsValid(yesButton) then
            self.YesButton = yesButton

            yesButton:Text("Погодитись")

            function yesButton:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                parent:OnYesClick()
            end
        end

        local noButton = vgui.Create("PRSBOX.Lobby.CheckboxButton", self)
        if IsValid(noButton) then
            self.NoButton = noButton

            noButton:Text("Відмовитись")
            
            function noButton:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                parent:OnNoClick()
            end
        end
        
    end

    function PANEL:SetState(state)
        self.State = state
    end

    function PANEL:OnYesClick()
    end

    function PANEL:OnNoClick()
    end

    function PANEL:SetTitle(title)
        local titleLabel = self.TitleLabel
        if IsValid(titleLabel) then
            titleLabel:SetText(title)
        end
    end

    function PANEL:SetText(text)
        local textLabel = self.TextLabel
        if IsValid(textLabel) then
            textLabel:AppendText(text)
        end
    end
    
    function PANEL:PerformLayout()
        local wide, tall = ScreenScale(250), ScreenScale(100)

        self:SetSize(wide, tall)
        self:Center()

        local titleTall = ScreenScale(20)
        local buttonTall = ScreenScale(20)
        local margin = ScreenScale(5)


        local titleLabel = self.TitleLabel
        if IsValid(titleLabel) then
            titleLabel:SetPos(margin, 0)
            titleLabel:SetSize(wide - margin, titleTall)
        end

        local textLabel = self.TextLabel
        if IsValid(textLabel) then
            local textTall = ScreenScale(10)
            
            textLabel:SetPos(margin, titleTall + margin)
            textLabel:SetSize(wide, tall - titleTall - buttonTall)
            textLabel:SetVerticalScrollbarEnabled(false)
            textLabel:SetFontInternal("PRSBOX.Lobby.Font.Info")
			textLabel:SetFGColor(COLOR_WHITE)
        end


        local yesButton = self.YesButton
        if IsValid(yesButton) then
            local textSize = surface.GetTextSize("PRSBOX.Lobby.Font.Button", yesButton.text) / 1.9

            yesButton:SetSize(textSize, buttonTall)
            yesButton:SetPos(wide - textSize, tall - buttonTall)
        end

        local noButton = self.NoButton
        if IsValid(noButton) then
            local textSize = surface.GetTextSize("PRSBOX.Lobby.Font.Button", noButton.text) / 1.9

            noButton:SetSize(textSize, buttonTall)
            noButton:SetPos(wide - margin - textSize * 2, tall - buttonTall)
        end
    end

    function PANEL:Paint(w, h)
        local titleTall = ScreenScale(20)
        
        surface.SetDrawColor(self.State)
        surface.DrawRect(0, 0, w, titleTall)

        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, titleTall, w, h)
    end
    
    vgui.Register("PRSBOX.Lobby.Checkbox", PANEL, "EditablePanel")
end