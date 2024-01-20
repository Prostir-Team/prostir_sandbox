---
--- Fonts
---

surface.CreateFont("PRSBOX.Vote.MapName", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(7),
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
        self.SliderWide = 0

        self.PlayerCount = player.GetCount()
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
        local newWide = (w * self.Votes) / self.PlayerCount
        self.SliderWide = Lerp(FrameTime() * 10, self.SliderWide, newWide)
        surface.DrawRect(0, w, self.SliderWide, sliderTall)
    end

    vgui.Register("PRSBOX.MapIcon", PANEL, "DButton")
end

---
--- Main vote panel
---

do
    local PANEL = {}

    function PANEL:Init()
        self.Maps = {}
        
        self.PrevMap = ""

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

    function PANEL:OnVote(mapName)
        net.Start("PRSBOX.AddVote")
            net.WriteString(mapName)
            net.WriteString(self.PrevMap)
        net.SendToServer()

        self.PrevMap = mapName
    end

    function PANEL:FullInit()
        local data = self.Data
        local grid = self.Grid
        if not IsValid(grid) then return end

        for k, map in ipairs(data) do
            local mapName = string.Split(map, ".")[1]

            local button = vgui.Create("PRSBOX.MapIcon")
            if not IsValid(button) then return end

            button:SetMap(mapName)
            grid:AddItem(button)

            button.DoClick = function ()
                self:OnVote(button.MapName)
            end

            self.Maps[mapName] = button
        end
    end

    function PANEL:ShowWinnerMap(map)
        
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

local function addVote(mapName, prevMapName)
    if prevMapName == mapName then return end
    
    local voteMenu = MAIN_MENU:GetWindow("PRSBOX.VoteMenu")
    if not IsValid(voteMenu) then return end

    local map = voteMenu.Maps[mapName]
    local prevMap = voteMenu.Maps[prevMapName]

    if IsValid(map) then
        map:AddVote()
    end

    if IsValid(prevMap) then
        prevMap:SubtractVote()
    end
end

net.Receive("PRSBOX.VoteUpdate", function (len)
    local map = net.ReadString()
    local prevMap = net.ReadString()

    addVote(map, prevMap)
end)

net.Receive("PRSBOX.ShowMapWinner", function (len)
    local map = net.ReadString()
    
    local voteMenu = MAIN_MENU:GetWindow("PRSBOX.VoteMenu")
    if not IsValid(voteMenu) then return end

    voteMenu:ShowWinnerMap()
end)