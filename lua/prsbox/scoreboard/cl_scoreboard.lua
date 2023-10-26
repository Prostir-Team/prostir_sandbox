surface.CreateFont("PROSTIR.FontLarge", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(15),
    ["extended"] = true,
    ["weight"] = 700
})
surface.CreateFont("PROSTIR.FontMiddle", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(13),
    ["extended"] = true,
    ["weight"] = 700
})
surface.CreateFont("PROSTIR.FontLittle", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(10),
    ["extended"] = true,
    ["weight"] = 700
})

local SCRW, SCRH = ScrW(), ScrH()

hook.Add( "OnScreenSizeChanged", "PRSBOX.SCORE_BOARD.SCR", function()
    SCRW, SCRH = ScrW(), ScrH()
end)

local guiMousePos = gui.MousePos
local IsValid = IsValid
local teamGetColor = team.GetColor
local drawSimpleText = draw.SimpleText
local drawRoundedBox = draw.RoundedBox
local stringformat = string.format
local surfaceSetFont = surface.SetFont
local surfaceGetTextSize = surface.GetTextSize
local ScreenScale = ScreenScale
local drawRoundedBoxEx = draw.RoundedBoxEx
local drawDrawText = draw.DrawText

-- unused
-- local scrW = ScrW()
-- local scrH = ScrH()

local color_background = Color(0, 0, 0, 100)

local color_player = Color(0, 0, 0, 200)
local color_player_hovered = Color(0, 0, 0, 230)

local color_player_build = Color(0, 0, 50, 200)
local color_player_hovered_build = Color(0, 0, 50, 230)

local color_player_death = Color(90, 0, 0, 200)
local color_player_hovered_death = Color(90, 0, 0, 230)

local color_white = Color(255, 255, 255)
local color_black = Color(0, 0, 0)
-- local color_orange = Color(234, 137, 0) -- unused

local padding = ScreenScale(2)
local scroll_margin = ScreenScale(8)

local scoreboard_width = ScreenScale(350)
local scoreboard_height = ScreenScale(200)

local player_size = ScreenScale(15)

local frags_pos = ScreenScale(260)
local death_pos = ScreenScale(290)
local ping_pos = ScreenScale(320)


local user_groups = {
    ["superadmin"] = Color(142, 255, 114), -- Команда
    ["admin"] = Color(245, 193, 81), -- Головний модератор
    ["operator"] = Color(255, 81, 81), -- Модератор
    ["user"] = Color(0, 140, 255) -- Гравець
}

local user_names = {
    ["superadmin"] = "Команда",
    ["admin"] = "Головний модератор",
    ["operator"] = "Модератор",
    ["user"] = "Звичайний гравець"
}

-- Scoreboard player button

local menu_button_wide = ScreenScale(50)
local menu_button_tall = ScreenScale(10)

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.text = ""
    end

    function PANEL:Text(text)
        self.text = text
        self.size_text = surface.GetTextSize(self.text)
        self:SetSize(menu_button_wide, menu_button_tall)
    end

    function PANEL:Paint(w, h)
        -- drawRoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
        
        drawDrawText(self.text, "PROSTIR.FontLittle", 0, 0, color_white, TEXT_ALIGN_LEFT)
        surface.SetDrawColor(color_white)
        if self:IsHovered() then
            surface.DrawRect(0, h - ScreenScale(1), surface.GetTextSize(self.text), ScreenScale(1))
        end
    end

    vgui.Register("PR.Scoreboard.Button", PANEL, "DButton")
end

-- Icon Button
do
    local PANEL = {}

    local mute_size = ScreenScale(13)

    local icons = {
        ["true"] = Material("icon16/sound_mute.png"),
        ["false"] = Material("icon16/sound.png")
    }

    function PANEL:Init()
        self:SetText("")
    end

    function PANEL:PerformLayout()
        self:SetSize(mute_size, mute_size)
        self:SetPos(scoreboard_width - mute_size - padding - scroll_margin, ScreenScale(1.5))
    end

    function PANEL:AddPlayer(ply)
        self.ply = ply

        self.currentIcon = icons[tostring(ply:IsMuted())]
    end

    function PANEL:DoClick()
        self.ply:SetMuted(not self.ply:IsMuted())
        self.currentIcon = icons[tostring(self.ply:IsMuted())]
    end

    function PANEL:Paint(w, h)
        if not IsValid(self.ply) then return end

        surface.SetMaterial(self.currentIcon)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    vgui.Register("PR.Button", PANEL, "DButton")
end

-- Player 
do
    local PANEL = {}

    local corner_round = ScreenScale(5)
    local avatar_size = ScreenScale(12)

    local name_pos_x = corner_round + padding * 2 + avatar_size

    function PANEL:Init()
        self:SetText("")

        self.color = color_players
        self.opened = false 

        self:SetSize(scoreboard_width, player_size)

        self._alpha = 0
        self.alpha_to = 0
    end

    function PANEL:Open()
        local tall = self.grid:GetRowHeight() * math.ceil(#self.grid:GetItems() / 6)

        self:SizeTo(-1, player_size + ScreenScale(.5) + tall, 0.1, 0, -1)
    end

    function PANEL:Close()
        self:SizeTo(-1, player_size, 0.1, 0, -1)
    end

    function PANEL:DoClick()
        self.opened = not self.opened

        if self.opened then
            self:Open()
            self.alpha_to = 255
        else
            self:Close()
            self.alpha_to = 0
        end
    end

    function PANEL:Think()
        if not IsValid(self.ply) then return end

        self._alpha = math.Clamp(Lerp(FrameTime() * 10, self._alpha, self.alpha_to), 0, 255)

        self.frags = self.ply:Frags()
        self.deaths = self.ply:Deaths()
        self.ping = self.ply:Ping()

        -- if ( PRSOXDRAWSTATUS[self.ply] and PRSOXDRAWSTATUS[self.ply][PRSBOX_STS_BUILDENUM] ) then
        --     if self:IsHovered() then
        --         self.color = color_player_hovered_build
        --         return
        --     end
        --     self.color = color_player_build
        --     return
        -- end

        local Dead = not self.ply:Alive()

        if self:IsHovered() then
            if ( Dead ) then
                self.color = color_player_hovered_death
                return
            end
            self.color = color_player_hovered
        else
            if ( Dead ) then
                self.color = color_player_death
                return
            end
            self.color = color_player
        end
    end

    function PANEL:SetupButtons()
        -- Grid Panel
        self.grid = vgui.Create("DGrid", self)
        self.grid:SetCols(6)
        self.grid:SetColWide(menu_button_wide)
        self.grid:SetRowHeight(menu_button_tall + ScreenScale(.5))
        self.grid:Dock(FILL)
        self.grid:DockMargin(name_pos_x, player_size + ScreenScale(.5), 0, 0)

        -- Copy steam id
        self.steamid_button = vgui.Create("PR.Scoreboard.Button", self)
        self.steamid_button:Text("Steam id")
        self.steamid_button.DoClick = function ()
            SetClipboardText(self.ply:SteamID())
        end
        
        self.grid:AddItem(self.steamid_button) 
        
        if LocalPlayer():GetUserGroup() == "user" then return end
        if self.ply == LocalPlayer() then return end

        -- Teleport button
        self.goto_button = vgui.Create("PR.Scoreboard.Button", self)
        self.goto_button:Text("Teleport to")
        self.goto_button.DoClick = function ()
            RunConsoleCommand("ulx", "goto", self.name)
        end

        self.grid:AddItem(self.goto_button) 

        -- Bring button
        self.bring_button = vgui.Create("PR.Scoreboard.Button", self)
        self.bring_button:Text("Bring")
        self.bring_button.DoClick = function ()
            RunConsoleCommand("ulx", "bring", self.name)
        end

        self.grid:AddItem(self.bring_button) 

        -- Jail  button
        self.jail_button = vgui.Create("PR.Scoreboard.Button", self)
        self.jail_button:Text("Jail")
        self.jail_button.DoClick = function ()
            RunConsoleCommand("ulx", "jailtp", self.name)
        end

        self.grid:AddItem(self.jail_button) 

        -- Unjail  button
        self.unjail_button = vgui.Create("PR.Scoreboard.Button", self)
        self.unjail_button:Text("Unjail")
        self.unjail_button.DoClick = function ()
            RunConsoleCommand("ulx", "unjail", self.name)
        end

        self.grid:AddItem(self.unjail_button) 

    end

    local formattext = "https://steamcommunity.com/profiles/%s"

    function PANEL:Setup(ply)
        self.ply = ply
        self.group = ply:GetUserGroup()

        self.avatarbutton = vgui.Create("DButton", self )
        self.avatarbutton:SetSize(avatar_size, avatar_size)
        self.avatarbutton:SetPos( corner_round + padding, ScreenScale(1.5) )
        self.avatarbutton:SetMouseInputEnabled( true )
        self.avatarbutton.Paint = function() end

        self.avatar = vgui.Create("AvatarImage", self.avatarbutton)
        self.avatar:SetPlayer(ply, 32)
        self.avatar:Dock(FILL)
        self.avatar:SetMouseInputEnabled( false )

        self.avatarbutton.DoClick = function()
            self.ply:ShowProfile()
            local text = string.format( formattext, self.ply:SteamID64() )
            SetClipboardText( text )
        end

        self.name = ply:GetName()
        self.frags = ply:Frags()
        self.deaths = ply:Deaths()
        self.ping = ply:Ping()

        if ply ~= LocalPlayer() then
            self.mute = vgui.Create("PR.Button", self)
            self.mute:AddPlayer(ply)
            self.mute.Col = Color( 255, 255, 255, 0 )
        end

        self:SetupButtons()
    end

    function PANEL:Paint(w, h)
        -- drawRoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
        local group_color = user_groups[ self.group ]

        drawRoundedBoxEx(corner_round, 0, 0, corner_round, h, group_color, true, false, true, false)

        drawRoundedBoxEx(corner_round, corner_round, 0, w - corner_round, h, self.color, false, true, false, true)
        drawDrawText(self.name, "PROSTIR.FontMiddle", name_pos_x, ScreenScale(.5), color_white, TEXT_ALIGN_LEFT)
        
        local us_color = Color(group_color.r, group_color.g, group_color.b, self._alpha)
        drawDrawText(user_names[self.group], "PROSTIR.FontMiddle", name_pos_x + surface.GetTextSize(self.name) + ScreenScale(5), ScreenScale(.5), us_color, TEXT_ALIGN_LEFT)

        drawDrawText(self.frags, "PROSTIR.FontLittle", frags_pos, ScreenScale(2.5), color_white, TEXT_ALIGN_CENTER)
        drawDrawText(self.deaths, "PROSTIR.FontLittle", death_pos, ScreenScale(2.5), color_white, TEXT_ALIGN_CENTER)
        drawDrawText(self.ping, "PROSTIR.FontLittle", ping_pos, ScreenScale(2.5), color_white, TEXT_ALIGN_CENTER)
    end

    vgui.Register("PR.Player", PANEL, "DButton")
end

-- Main panel
do
    local PANEL = {}
    local up_padding = ScreenScale(20)
    local button_margin = ScreenScale(3)

    function PANEL:Init()
        self.buttons = {}
        self.hostName = GetHostName()
        self.players = player.GetCount()
        self.maxPlayers = game.MaxPlayers()

        self:MakePopup()

        self:SetKeyboardInputEnabled( false )
    end

    function PANEL:Think()
        self.players = player.GetCount()
    end

    function PANEL:PerformLayout()
        self:SetY(SCRH * .25 - player_size)
        self:SetSize(scoreboard_width, SCRH - SCRH * .25 )
        
        self:CenterHorizontal()

        self.scroll:SetPos(0, up_padding)
        self.scroll:SetSize(scoreboard_width, SCRH - SCRH * .25 - up_padding)
    end

    function PANEL:Setup()
        self.scroll = vgui.Create("DScrollPanel", self)
        self.sbar = self.scroll:GetVBar()

        self.sbar:DockPadding(self.sbar:GetWide(), 0, 0, 0)
        
        function self.sbar:Paint(w, h)
            drawRoundedBox(ScreenScale(5), 0, 0, w, h, color_background)
        end
        function self.sbar.btnUp:Paint(w, h) end
        function self.sbar.btnDown:Paint(w, h) end
        function self.sbar.btnGrip:Paint(w, h)
            drawRoundedBox(ScreenScale(5), 0, 0, w, h, color_player)
        end
    end

    function PANEL:Update()
        local players = player.GetAll()

        table.sort(players, function (ply1, ply2)
            return ply1:Frags() > ply2:Frags()
        end)

        for k, v in ipairs(self.buttons) do
            v:Remove()
        end

        for k, ply in ipairs(players) do
            button = vgui.Create("PR.Player")
            button:Dock(TOP)
            button:DockMargin(0, button_margin, 0, 0)
            
            -- button:SetY((k - 1) * (player_size + button_margin))
            button:Setup(ply)
            table.insert(self.buttons, button)
            self.scroll:AddItem(button)
        end
    end

    function PANEL:ShowScoreboard()
        self:Show()

        self:SetMouseInputEnabled( true )
        self:SetKeyboardInputEnabled( false )
        self:AlphaTo(255, FrameTime() * 2, 0)
    end

    function PANEL:HideScoreboard()
        self:SetMouseInputEnabled( false )
        self:AlphaTo(0, FrameTime() * 2, 0, function ()
            self:Hide()
        end)
    end

    function PANEL:Paint(w, h)
        -- drawRoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
        
        drawDrawText(self.hostName, "PROSTIR.FontLarge", ScreenScale(1), ScreenScale(1), color_black, TEXT_ALIGN_LEFT)
        drawDrawText(self.hostName, "PROSTIR.FontLarge", 0, 0, color_white, TEXT_ALIGN_LEFT)

        surfaceSetFont("PROSTIR.FontLarge")
        local text_size = surfaceGetTextSize(self.hostName)

        -- drawDrawText("(" .. self.players .. "/" .. self.maxPlayers .. ")", "PROSTIR.FontLittle", surfaceGetTextSize(self.hostName) + padding, ScreenScale(4), color_white, TEXT_ALIGN_LEFT)

        drawDrawText("(" .. self.players .. "/" .. self.maxPlayers .. ")", "PROSTIR.FontLittle", text_size + padding + ScreenScale(1), ScreenScale(4), color_black, TEXT_ALIGN_LEFT)
        drawDrawText("(" .. self.players .. "/" .. self.maxPlayers .. ")", "PROSTIR.FontLittle", text_size + padding, ScreenScale(3), color_white, TEXT_ALIGN_LEFT)

        drawDrawText("K", "PROSTIR.FontLittle", frags_pos + ScreenScale(1), ScreenScale(4), color_black, TEXT_ALIGN_CENTER)
        drawDrawText("K", "PROSTIR.FontLittle", frags_pos, ScreenScale(3), color_white, TEXT_ALIGN_CENTER)

        drawDrawText("D", "PROSTIR.FontLittle", death_pos + ScreenScale(1), ScreenScale(4), color_black, TEXT_ALIGN_CENTER)
        drawDrawText("D", "PROSTIR.FontLittle", death_pos, ScreenScale(3), color_white, TEXT_ALIGN_CENTER)

        drawDrawText("P", "PROSTIR.FontLittle", ping_pos + ScreenScale(1), ScreenScale(4), color_black, TEXT_ALIGN_CENTER)
        drawDrawText("P", "PROSTIR.FontLittle", ping_pos, ScreenScale(3), color_white, TEXT_ALIGN_CENTER)
    end

    vgui.Register("PR.Scoreboard", PANEL)
end

if IsValid( PRSBOXSCOREBOARD ) then PRSBOXSCOREBOARD:Remove() end

hook.Add("ScoreboardShow", "PROSTIR.ScoreboardShow", function()
    if ( not IsValid( PRSBOXSCOREBOARD ) ) then
        PRSBOXSCOREBOARD = vgui.Create( "PR.Scoreboard", GetHUDPanel() )
        PRSBOXSCOREBOARD:Setup()
    end

    PRSBOXSCOREBOARD:Update()
    PRSBOXSCOREBOARD:ShowScoreboard()

    hook.Run("Prsbox_ScoreboardShow")
    return true
end)

hook.Add("ScoreboardHide", "PROSTIR.ScoreboardHide", function()
    if IsValid( PRSBOXSCOREBOARD ) then
        PRSBOXSCOREBOARD:HideScoreboard()
    end
end)

concommand.Add( "scoreboard_reload", function( ply, cmd, args ) 
    if IsValid( PRSBOXSCOREBOARD ) then 
        PRSBOXSCOREBOARD:Remove() 
    end 
end)