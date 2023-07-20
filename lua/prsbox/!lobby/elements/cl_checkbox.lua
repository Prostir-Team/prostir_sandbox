print("Check box clientside")

---
--- Check box panel
---

do
    local PANEL = {}

    function PANEL:Init()
        print("Hello World")
    end

    function PANEL:PerformLayout()
        local wide, tall = ScreenScale(300), ScreenScale(250)

        self:SetSize(wide, tall)
        self:Center()
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, h)
    end
    
    vgui.Register("PRSBOX.Lobby.Checkbox", PANEL, "EditablePanel")
end