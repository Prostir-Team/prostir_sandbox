surface.CreateFont("PROSTIR.FONT.MapName", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(7),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PROSTIR.FONT.DescriptionMap", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(9),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PROSTIR.FONT.VoteInfo", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(14),
    ["extended"] = true,
    ["weight"] = 700
})

local VoteTime = 30

local scrW, scrH = ScrW(), ScrH()
local HscrW, HscrH = ScrW() * .5, ScrH() * .5

hook.Add( "OnScreenSizeChanged", "PRSBOX.VOTEMENU.SCR", function()
    scrW, scrH = ScrW(), ScrH()
    HscrW, HscrH = ScrW() * .5, ScrH() * .5
end)

local color_white = Color(255, 255, 255, 255)

local button_size_w = ScreenScale(70)
local button_size_h = ScreenScale(75)

-- Map Button
do 
    local PANEL = {}

    local sound_click = "UI/buttonclick.wav"

    local icon_size = ScreenScale(50)

    local color_background = Color(0, 0, 0, 200)
    local color_background_hovered = Color(0, 0, 0, 240)

    local color_bar_backround = Color(100, 100, 100, 25)
    local color_bar = Color(142, 255, 114)
    
    local rect_round = ScreenScale(3)
    local image_margin = ScreenScale(5)

    local bar_size_w = button_size_w - image_margin * 2
    local bar_size_h = ScreenScale(5)
    local bar_speed = 10

    function PANEL:Init()
        self:SetText("")
        self.text = ""

        self.current_color = color_background
        self.votes = 0
        self.player_count = player.GetCount()

        self.bar_size = 0
    end

    function PANEL:Setup(parent)
        self.parent = parent
    end

    local noThumb =  Material("thumb/no_thumb_map.png")

    function PANEL:Text(text)
        self.map = text
        if file.Exists("maps/thumb/" .. text .. ".png", "GAME") then
            self.mat = Material("maps/thumb/" .. text .. ".png")
        else
            self.mat = noThumb
        end

        self.text = text
    end

    function PANEL:PerformLayout()
        self:SetSize(button_size_w, button_size_h)
    end
    
    function PANEL:GetBarSize()
        return (self.votes / self.player_count) * bar_size_w
    end

    function PANEL:Paint(w, h)
        if not self.mat then return end
        
        if self:IsHovered() then
            self.current_color = color_background_hovered
        else
            self.current_color = color_background
        end
        
        draw.RoundedBox(rect_round, 0, 0, w, h, self.current_color)
        draw.DrawText(self.text, "PROSTIR.FONT.MapName", w * .5, icon_size + image_margin, color_white, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(color_bar_backround)
        surface.DrawRect(image_margin, w - image_margin, bar_size_w, bar_size_h)

        self.bar_size = Lerp(FrameTime() * bar_speed, self.bar_size, self:GetBarSize())

        surface.SetDrawColor(color_bar)
        surface.DrawRect(image_margin, w - image_margin, self.bar_size, bar_size_h)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(self.mat)
        surface.DrawTexturedRect(w * .5 - icon_size * .5, image_margin, icon_size, icon_size)
    end

    function PANEL:DoClick()
        if not IsValid(self.parent) then return end
        if self.parent.current_buton == self then return end

        self.parent.current_buton = self
        surface.PlaySound(sound_click)
        RunConsoleCommand("prostir_vote", self.map)
    end

    vgui.Register("PROSTIR.UI.MapButton", PANEL, "DButton")
end

-- Main Panel
do
    local PANEL = {}

    local color_background = Color(0, 0, 0, 200)
    local color_scroll = Color(0, 0, 0)
    local color_bar = Color(142, 255, 114, 100)

    local col_size = ScreenScale(75)
    local col_amnt = 5
    local row_size = ScreenScale(85)

    local margin = ScreenScale(10)
    local scroll_top = ScreenScale(24)
    local scroll_down = ScreenScale(2)

    local bar_speed = 10

    local function findButtonByMap(buttons, map_name)
        for k, button in ipairs(buttons) do
            if button.map ~= map_name then continue end

            return button
        end

        return false
    end

    function PANEL:Init()
        self.curTime = CurTime()
        
        self.bar_size = 0

        self.scroll = vgui.Create("DScrollPanel", self)
        self.scroll:Dock(FILL)

        self.grid = vgui.Create("DGrid", self.scroll)
        self.grid:Dock( FILL )

        self.buttons = {}
        self.current_button = NULL

        self.to_alpha = 255

        self:MakePopup()

        self:SetKeyboardInputEnabled(false)
        self:SetAlpha(0)
        -- surface.PlaySound("music/hl1_song25_remix3.mp3")
    end

    function PANEL:Setup(maps_json)
        local maps = table.GetKeys(maps_json)
        
        for k, v in pairs(maps) do
            local button = vgui.Create("PROSTIR.UI.MapButton")
            
            button:Setup(self)
            button:Text(v)
            self.grid:AddItem(button)
            table.insert(self.buttons, button)
        end
    end

    function PANEL:PerformLayout(w, h)
        self:SetSize(scrW, scrH)
        self:SetPos(0, 0)
        
        local scroll_wide = col_size * col_amnt + margin
        local scroll_margin = (w - scroll_wide) * .5

        self.scroll:DockMargin(scroll_margin, scroll_top, scroll_margin, scroll_down)
        
        self.sbar = self.scroll:GetVBar()

        self.sbar:SetHideButtons(true)

        function self.sbar:Paint(w, h)
            draw.RoundedBox(ScreenScale(5), 0, 0, w, h, color_background)
        end
        function self.sbar.btnUp:Paint(w, h) end
        function self.sbar.btnDown:Paint(w, h) end
        function self.sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(ScreenScale(5), 0, 0, w, h, color_scroll)
        end

        self.grid:SetColWide(col_size)
        self.grid:SetRowHeight(row_size)
        self.grid:SetCols(col_amnt)
        self.grid:CenterHorizontal()
    end

    function PANEL:Think()
        self:SetAlpha(Lerp(FrameTime() * 10, self:GetAlpha(), self.to_alpha))

        if CurTime() - self.curTime >= VoteTime then
            self.to_alpha = 0
            self:SetMouseInputEnabled( false )
            self:SetKeyboardInputEnabled( false )
        end

        if CurTime() - self.curTime >= VoteTime + 1 then
            self:Remove()
        end
    end

    function PANEL:GetBarSize(w)
        return ( (CurTime() - self.curTime) / VoteTime ) * w
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(color_background)
        surface.DrawRect(0, 0, w, h)

        draw.DrawText("Голосування на зміну карти!", "PROSTIR.FONT.VoteInfo", w * .5, 0, color_white, TEXT_ALIGN_CENTER)

        self.bar_size = Lerp( FrameTime() * bar_speed, self.bar_size, self:GetBarSize(w) )

        surface.SetDrawColor(color_bar)
        surface.DrawRect(0, h - scroll_down, self.bar_size, scroll_down)
    end
    
    function PANEL:UpdateButtons(data)
        if table.HasValue(table.GetKeys(data), "prev_map") and data["prev_map"] ~= "" then
            local prev_button = findButtonByMap(self.buttons, data["prev_map"])

            prev_button.votes = prev_button.votes - 1
        end
        
        local button = findButtonByMap(self.buttons, data["map"])

        button.votes = button.votes + 1
    end

    vgui.Register("PROSTIR.UI.VoteMenu", PANEL, "Panel")
end

local panel

net.Receive("PROSTIR.VoteMenu", function (len, ply)
    local maps = util.JSONToTable(net.ReadString())
    VoteTime = net.ReadFloat()
    
    panel = vgui.Create("PROSTIR.UI.VoteMenu", GetHUDPanel())
    panel:Dock( FILL )
    panel:Setup(maps)
end)

net.Receive("PROSTIR.UpdateVote", function (len, ply)
    local data = util.JSONToTable(net.ReadString())

    if ( IsValid(panel) ) then
        panel:UpdateButtons(data)
    end
end)

local mtc_margin = ScreenScale(5)
local mtc_round = ScreenScale(5)
local color_bar = Color(142, 255, 114)
local color_background = Color(0, 0, 0, 200)
local mtc_tall = ScreenScale(16)
local mtc_y = ScreenScale(2)

net.Receive("PROSTIR.EndVote", function (len, ply)
    local map = net.ReadString()
    local block = net.ReadBool()

    if block then return end
    
    local curTime = CurTime()

    hook.Add("HUDPaint", "PROSTIR.Vote.MapToChange", function ()
        local time = tostring( math.Clamp(60 - math.Round(CurTime() - curTime), 0, 60) )
        
        local text = "Наступна карта: " .. map .. " (" .. time .. ")"
        surface.SetFont("PROSTIR.FONT.VoteInfo")
        local text_size = surface.GetTextSize(text)

        local mtc_wide = text_size + mtc_margin * 2

        draw.RoundedBoxEx(mtc_round, (HscrW - mtc_wide * .5) - mtc_round, mtc_y, mtc_round, mtc_tall, color_bar, true, false, true, false)
        draw.RoundedBoxEx(mtc_round, HscrW - mtc_wide * .5, mtc_y, mtc_wide, mtc_tall, color_background, false, true, false, true)

        draw.DrawText(text, "PROSTIR.FONT.VoteInfo", HscrW, mtc_y + ScreenScale(0.5), color_white, TEXT_ALIGN_CENTER)
    end)
end)