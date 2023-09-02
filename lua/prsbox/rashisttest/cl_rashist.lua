---
--- Fonts
---

surface.CreateFont("PRSBOX.Settings.Font.Question", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(13),
    ["extended"] = true,
    ["weight"] = 1000
})

---
--- Global variables
---

RASHIST_TEST = nil 

---
--- Rashist button
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.debug = false

        self.Active = false

        self.TextColor = COLOR_WHITE
        self.BackgroundColor = COLOR_BUTTON_NONE
        self.MarkWide = 0
        self.Speed = 10
    end

    function PANEL:Text(text)
        self.text = text
    end

    function PANEL:Start()
        local element = vgui.Create(self.Type, self)
        if not IsValid(element) then return end
        self.Element = element

        element:SetConvar(self.Convar)
    end

    function PANEL:DoClick()
        self.MainPanel:ResetButtons()

        self.Active = true 
        self.MainPanel:Choose(self.text)
    end 

    function PANEL:PerformLayout()
        local tall = ScreenScale(15)

        self:SetTall(tall)
    end

    function PANEL:Paint(w, h)
        local marginLeft = ScreenScale(3)
        
        if self.Active then
            self.MarkWide = Lerp(FrameTime() * self.Speed, self.MarkWide, ScreenScale(5))
        else
            self.MarkWide = Lerp(FrameTime() * self.Speed, self.MarkWide, 0)
        end

        if self:IsHovered() then
            self.TextColor = LerpColor(FrameTime() * self.Speed, self.TextColor, COLOR_BUTTON_BACKGROUND)
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_WHITE)
        else
            self.TextColor = LerpColor(FrameTime() * self.Speed * 2, self.TextColor, COLOR_WHITE)
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_WHITE_NONE)
        end
        
        surface.SetDrawColor(self.BackgroundColor)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(COLOR_BUTTON_TEXT)
        surface.DrawRect(0, 0, self.MarkWide, h)
        
        if not self.text then return end

        draw.DrawText(self.text, "PRSBOX.Lobby.Font.Info", marginLeft + self.MarkWide, ScreenScale(2.5), self.TextColor, TEXT_ALIGN_LEFT)
    end

    vgui.Register("PRSBOX.Rashist.Button", PANEL, "DButton")
end

---
--- Question panel
---

do
    local PANEL = {}

    function PANEL:Init()
        self:Dock(TOP)

        local label = vgui.Create("DLabel", self)
        if IsValid(label) then
            self.Label = label

            label:SetFont("PRSBOX.Settings.Font.Question")
            label:SetTextColor(COLOR_BUTTON_TEXT)
            label:Dock(TOP)

            function label:PerformLayout(w, h)
                local tall = ScreenScale(15)

                self:SetTall(tall)
            end
        end
    end

    function PANEL:ResetButtons()
        for k, button in ipairs(self.Buttons) do
            button.Active = false
        end

        for k, answer in ipairs(table.GetKeys(self.Data)) do
            self.MainPanel.Data[self.Question][answer] = false 
        end
    end

    function PANEL:Choose(answerText)
        for k, answer in ipairs(table.GetKeys(self.Data)) do
            if answerText == answer then
                self.MainPanel.Data[self.Question][answer] = true 
            end
        end

        PrintTable(self.MainPanel.Data[self.Question])
    end

    function PANEL:SetData(question, data)
        self.Data = data
        self.Question = question
        
        local label = self.Label
        if IsValid(label) then
            label:SetText(question)
        end

        self.Buttons = {}

        for k, answer in ipairs(table.GetKeys(data)) do
            local answerButton = vgui.Create("PRSBOX.Rashist.Button", self)
            if not IsValid(answerButton) then continue end
            answerButton:Dock(TOP)
            answerButton:Text(answer)
            answerButton.MainPanel = self

            table.insert(self.Buttons, answerButton)
        end

        -- self:PerformLayout()
    end

    function PANEL:PerformLayout()
        local tall = ScreenScale(15)
        local margin = ScreenScale(5)

        self:DockMargin(margin, margin, 0, margin)

        if not self.Data then return end
        
        self:SetTall(#table.GetKeys(self.Data) * tall + ScreenScale(14))
    end

    function PANEL:Paint(w, h)
        -- surface.SetDrawColor(COLOR_RED)
        -- surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Rashist.Question", PANEL, "EditablePanel")
end

---
--- Main rahist menu
---

do
    local PANEL = {}

    function PANEL:Init()
        local startButton = vgui.Create("PRSBOX.Lobby.TabButton", self)
        if IsValid(startButton) then
            self.StartButton = startButton
            
            startButton:Text("Почати тестування")
            
            function startButton:PerformLayout()
                local wide, tall = ScreenScale(120), ScreenScale(20)

                self:SetSize(wide, tall)

                self:Center()
            end

            function startButton:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                net.Start("PRSBOX.Client.Rahist.Start")
                net.SendToServer()

                self:Remove()
            end
        end
        
        RASHIST_TEST = self
    end

    function PANEL:StartTest(data)
        self.Data = data
        local scroll = vgui.Create("DScrollPanel", self)
        if not IsValid(scroll) then return end
        self.Scroll = scroll
        
        scroll:Dock(FILL)

        scroll:SetAlpha(0)
        scroll:AlphaTo(255, 0.5, 0)

        local sbar = scroll:GetVBar()
        if not IsValid(sbar) then return end
        self.Sbar = sbar

        sbar:DockPadding(sbar:GetWide(), 0, 0, 0)
        sbar:SetHideButtons(true)

        function sbar:Paint(w, h)
            surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
            surface.DrawRect(0, 0, w, h)
        end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
            surface.SetDrawColor(COLOR_WHITE)
            surface.DrawRect(0, 0, w, h)
        end

        for k, question in ipairs(table.GetKeys(data)) do
            local questionPanel = vgui.Create("PRSBOX.Rashist.Question")
            questionPanel.MainPanel = self
            questionPanel:SetData(question, data[question])

            scroll:AddItem(questionPanel)
        end

        local applyButton = vgui.Create("PRSBOX.Rashist.Button")
        if not IsValid(applyButton) then return end
        self.ApplyButton = applyButton

        applyButton:Dock(TOP)
        applyButton:Text("Здати тест")
        applyButton.MainPanel = self

        function applyButton:DoClick()
            self.MainPanel:CheckResults()
        end

        scroll:AddItem(applyButton)
    end
    
    function PANEL:CheckResults()
        net.Start("PRSBOX.Net.CheckTester")
            net.WriteTable(self.Data)
        net.SendToServer()
    end

    function PANEL:EndTest()
        local scroll = self.Scroll
        if IsValid(scroll) then
            scroll:Remove()
        end
        
        local panel = vgui.Create("EditablePanel", self)
        if not IsValid(panel) then return end
        self.EndPanel = panel

        panel:SetAlpha(0)

        panel:AlphaTo(255, 0.5, 0)

        local startButton = vgui.Create("PRSBOX.Lobby.TabButton", panel)
        if IsValid(startButton) then
            self.StartButton = startButton
            
            startButton:Text("Почати гру на сервері!")
            startButton:Dock(BOTTOM)
            function startButton:PerformLayout()
                local tall = ScreenScale(20)

                self:SetTall(tall)
            end

            function startButton:DoClick()
                local ply = LocalPlayer()
                if not IsValid(ply) then return end
                
                PLAYER_STATE = PLAYER_NONE
                
                RunConsoleCommand("prsbox_lobby_start")
                MAIN_MENU:Remove()
            end
        end

        function panel:PerformLayout()
            local wide, tall = ScreenScale(137), ScreenScale(100)
            
            self:SetSize(wide, tall)
            self:Center()
        end

        function panel:Paint(w, h)
            -- surface.SetDrawColor(COLOR_RED)
            -- surface.DrawRect(0, 0, w, h)

            draw.DrawText("Ви успішно\nпройшли тест!\nПриємної гри!", "PRSBOX.Lobby.Font.Big", w / 2, 0, COLOR_BUTTON_TEXT, TEXT_ALIGN_CENTER)
        end
    end

    function PANEL:Bad()
        local scroll = self.Scroll
        if IsValid(scroll) then
            scroll:Remove()
        end
        
        local panel = vgui.Create("EditablePanel", self)
        if not IsValid(panel) then return end
        self.EndPanel = panel

        panel:SetAlpha(0)

        panel:AlphaTo(255, 0.5, 0)

        local startButton = vgui.Create("PRSBOX.Lobby.TabButton", panel)
        if IsValid(startButton) then
            self.StartButton = startButton
            
            startButton:Text("Вийти")
            startButton:Dock(BOTTOM)
            function startButton:PerformLayout()
                local tall = ScreenScale(20)

                self:SetTall(tall)
            end

            function startButton:DoClick()
                RunConsoleCommand("disconnect")
            end
        end

        function panel:PerformLayout()
            local wide, tall = ScreenScale(137), ScreenScale(100)
            
            self:SetSize(wide, tall)
            self:Center()
        end

        function panel:Paint(w, h)
            draw.DrawText("Ви, на жаль,\nпровалили тест!", "PRSBOX.Lobby.Font.Big", w / 2, 0, COLOR_BUTTON_TEXT_LOCKED, TEXT_ALIGN_CENTER)
        end
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Rashist", PANEL, "EditablePanel")
end

---
--- Net methods
---

net.Receive("PRSBOX.Net.StartTester", function(len, ply)
    if not IsValid(RASHIST_TEST) then return end

    local data = net.ReadTable()

    RASHIST_TEST:StartTest(data)
    -- RASHIST_TEST:EndTest()
end)

net.Receive("PRSBOX.Net.EndTester", function (len, ply)
    if not IsValid(RASHIST_TEST) then return end

    RASHIST_TEST:EndTest()

    hook.Run("OnMenuClose", MENU_PANEL)
    hook.Run("PRSBOX.RahistTestEnd", ply)
end)

net.Receive("PRSBOX.Net.EndBadTester", function (len, ply)
    if not IsValid(RASHIST_TEST) then return end

    RASHIST_TEST:Bad()
end)