print("Hello World")

---
--- Money panel
---

do
    local PANEL = {}

    function PANEL:Init()
        local playersPanel = vgui.Create("EditablePanel", self)
        if IsValid(playersPanel) then
            self.PlayersPanel = playersPanel

            playersPanel:Dock(FILL)
        end

        local quantityPanel = vgui.Create("EditablePanel", self)
        if IsValid(quantityPanel) then
            self.QuantityPanel = quantityPanel

            quantityPanel:Dock(BOTTOM)

            function quantityPanel:Paint(w, h)
                surface.SetDrawColor(Color(255, 0, 0))
                surface.DrawRect(0, 0, w, h)
            end

            function quantityPanel:PerformLayout()
                local tall = ScreenScale(20)

                self:SetTall(tall)
            end
        end
    end

    function PANEL:FullInit()
        local players = player.GetAll()

        for k, ply in ipairs(players) do
            if not IsValid(ply) then continue end

            local label = vgui.Create("DLabel", self)
            label:SetText(ply:Nick())

            label:Dock(TOP)
        end
    end

    function PANEL:PerformLayout()

    end

    vgui.Register("PRSBOX.Money.Menu", PANEL, "EditablePanel")
end

---
--- Menu buttons 
---

-- MENU:RegisterButton("Передати гроші", 3, PLAYER_NONE, function (menu, button)
--     menu:OpenWindow("PRSBOX.Money.Menu", "Money menu", true, 200, 100)
-- end)