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

                parent:StartTest()
                self:Remove()
            end
        end
    end

    function PANEL:StartTest()
        print("Test has started")
    end
    
    function PANEL:Paint(w, h)
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Rashist", PANEL, "EditablePanel")
end
