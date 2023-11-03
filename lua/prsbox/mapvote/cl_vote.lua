---
--- Fonts
---

surface.CreateFont("PRSBOX.Vote.MapName", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(10),
    ["extended"] = true,
    ["weight"] = 700
})

---
--- Map button
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")

        self.Votes = 0
        self.CurrentColor = COLOR_BUTTON_NONE
        self.Chosen = false
    end

    function PANEL:SetMap(mapName)
        self.MapName = mapName
        self.MapIcon = Material("maps/thumb/" .. mapName .. ".png", "smooth")
    end

    function PANEL:PerformLayout()
        local wide, tall = ScreenScale(72), ScreenScale(90)

        self:SetSize(wide, tall)
    end

    function PANEL:AddVote()
        self.Votes = self.Votes + 1
    end

    function PANEL:SubtractVote()
        self.Votes = self.Votes - 1
    end

    function PANEL:Paint(w, h)
        if self:IsHovered() or self.Chosen then
            self.CurrentColor = LerpColor(FrameTime() * 20, self.CurrentColor, COLOR_BUTTON_BACKGROUND)
        else
            self.CurrentColor = LerpColor(FrameTime() * 20, self.CurrentColor, COLOR_BUTTON_NONE)
        end
        
        surface.SetDrawColor(self.CurrentColor)
        surface.DrawRect(0, 0, w, h)

        if not self.MapIcon then return end

        local sliderTall = ScreenScale(5)

        surface.SetDrawColor(COLOR_WHITE)
        surface.SetMaterial(self.MapIcon)
        surface.DrawTexturedRect(0, 0, w, w)

        draw.DrawText(self.MapName, "PRSBOX.Vote.MapName", w / 2, w + sliderTall, COLORWHITE, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(COLOR_BUTTON_TEXT)
        surface.DrawRect(0, w, w, sliderTall)
    end

    vgui.Register("PRSBOX.MapIcon", PANEL, "DButton")
end

---
--- Main vote panel
---

do
    local PANEL = {}

    function PANEL:Init()
        local scroll = vgui.Create("DScrollPanel", self)
        if IsValid(scroll) then
            self.Scroll = scroll

            scroll:Dock(FILL)

            local grid = vgui.Create("DGrid")
            if IsValid(grid) then
                self.Grid = grid
                
                grid:SetCols(4)

                scroll:AddItem(grid)
            end
        end
    end

    function PANEL:SetMaps()
        
    end

    function PANEL:PerformLayout()
        local grid = self.Grid
        if IsValid(grid) then
            local colWide, rowTall = ScreenScale(72), ScreenScale(90)
            local offset = ScreenScale(5)
            
            grid:SetColWide(colWide + offset)
            grid:SetRowHeight(rowTall + offset)
            grid:CenterHorizontal()
        end
    end

    vgui.Register("PRSBOX.VoteMenu", PANEL, "EditablePanel")
end