local ResW, ResH
local QUEST_TAB_Width, QUEST_TAB_Height, QUEST_TAB_QuestSize, QUEST_TAB_QuestGap, QUEST_TAB_VerticalColorBarHeight, QUEST_TAB_IconSize
local color_white = Color(255,255,255, 255)
-- Precaching functions lol
local ScreenScale = ScreenScale
local IsValid = IsValid
local drawRoundedBoxEx = draw.RoundedBoxEx

local Quests = {
    ["Amount"] = 0,
    ["DoneAmount"] = 0,
    ["Color"] = {
        ["Unfinished"] = Color(255,210,0, 255),
        ["Finished"] = Color(0,255,85, 255),
        ["UnfinishedPanel"] = Color(255,210,0, 40),
        ["FinishedPanel"] = Color(0,255,85, 40)
    },
    ["DefaultText"] = "No quest! Use command \"prsbox_quests_update\" to reload quests!"
}

QUEST_TAB_COLOR_Background = Color(40,40,40, 180)
QUEST_TAB_COLOR_Background_Hovered = Color(80,80,80, 180)
QUEST_TAB_COLOR_Background_Idle = Color(120,150,150, 180)

local Material_GradientLeft = Material("gui/gradient")

local function updateScrVars()
	ResW = ScrW()
	ResH = ScrH()

    QUEST_TAB_Width = ResW*0.2
    QUEST_TAB_Height = ResH*0.05
    QUEST_TAB_QuestSize = ResH*0.075
    QUEST_TAB_QuestGap = ResH*0.01
    QUEST_TAB_VerticalColorBarHeight = ResH*0.005
    QUEST_TAB_IconSize = ResH*0.04

    surface.CreateFont( "PRSBOX_QUESTS_FONT_DEFAULT", {
        font = "DermaDefault",
        extended = true,
        size = ResH*0.0175,
        weight = 900,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )

    surface.CreateFont( "PRSBOX_QUESTS_FONT_STRIKEOUT", {
        font = "DermaDefault",
        extended = true,
        size = ResH*0.0175,
        weight = 900,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = true,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )
end updateScrVars()

-- Main Tab
do
    //print("CL_QUESTS DEBUG: TAB INIT")
    local PANEL = {}
    local up_padding = ScreenScale(20)

    function PANEL:Init()
        self.opened = false
        self.color = QUEST_TAB_COLOR_Background_Hovered
        self.segmentColor = Color(255,255,255, 255)
        self.iconMaterial = Material("gui/html/forward")

        self:MakePopup()

        self:SetKeyboardInputEnabled( false )
    end

    function PANEL:Resize()
        if self.opened then
            self:SetSize(QUEST_TAB_Width, QUEST_TAB_Height+QUEST_TAB_QuestGap+(QUEST_TAB_QuestSize+QUEST_TAB_QuestGap)*Quests["Amount"])
        else
            self:SetSize(QUEST_TAB_Width, QUEST_TAB_Height)
        end
    end

    function PANEL:PerformLayout()
        self:SetY(ResH * .02)

        self:Resize()

        self:CenterHorizontal(0.885)
    end

    function PANEL:Think()
        if self:IsHovered() then
            self.color = QUEST_TAB_COLOR_Background_Idle
        else
            self.color = QUEST_TAB_COLOR_Background_Hovered
        end
    end

    function PANEL:OnMousePressed( keyCode )
        self.opened = not self.opened

        self:Resize()
    end

    function PANEL:ShowQuests()
        self:Show()

        self:SetMouseInputEnabled( true )
        self:SetKeyboardInputEnabled( false )
        self:AlphaTo(255, FrameTime() * 2, 0)
    end

    function PANEL:HideQuests()
        self:SetMouseInputEnabled( false )
        self:AlphaTo(0, FrameTime() * 2, 0, function ()
            self:Hide()
        end)
    end

    function PANEL:Paint(w, h)
        drawRoundedBoxEx(32, 0, 0, QUEST_TAB_Width, QUEST_TAB_VerticalColorBarHeight, self.segmentColor, true, true, false, false)
        drawRoundedBoxEx(16, 0, QUEST_TAB_VerticalColorBarHeight, QUEST_TAB_Width, QUEST_TAB_Height-QUEST_TAB_VerticalColorBarHeight, self.color, false, false, not self.opened, not self.opened)

        local TempString = "Завдання "..Quests["DoneAmount"].."/"..Quests["Amount"]
        local TempHeight = QUEST_TAB_VerticalColorBarHeight+QUEST_TAB_Height*0.125
        draw.DrawText(TempString, "PROSTIR.FontLittle", QUEST_TAB_Width*.5+ScreenScale(1), TempHeight+ScreenScale(1), color_black, TEXT_ALIGN_CENTER)
        draw.DrawText(TempString, "PROSTIR.FontLittle", QUEST_TAB_Width*.5, TempHeight, color_white, TEXT_ALIGN_CENTER)
        
        surface.SetMaterial(self.iconMaterial) -- "Arrow" suggesting that quest tab can be minimized
        surface.SetDrawColor(color_white)

        if self.opened then -- Draws quests list itself
            surface.DrawTexturedRectRotated(QUEST_TAB_Width*.93, QUEST_TAB_Height*.5+QUEST_TAB_VerticalColorBarHeight*.5, QUEST_TAB_IconSize, QUEST_TAB_IconSize, 90)
            draw.NoTexture()
            
            drawRoundedBoxEx(16, 0, QUEST_TAB_Height, w, h-QUEST_TAB_Height, QUEST_TAB_COLOR_Background, false, false, true, true)

            for i=0, Quests["Amount"]-1 do
                local BarColor = Quests["Color"]["Unfinished"]
                local BackgroundColor = Quests["Color"]["UnfinishedPanel"]

                if Quests["Quest"..i+1]["IsDone"] then
                    BarColor = Quests["Color"]["Finished"]
                    BackgroundColor = Quests["Color"]["FinishedPanel"]
                end
                
                local CurrentHeight = QUEST_TAB_Height+QUEST_TAB_QuestGap+(QUEST_TAB_QuestGap+QUEST_TAB_QuestSize)*i
                
                -- Background
                drawRoundedBoxEx(32, QUEST_TAB_QuestGap, CurrentHeight, QUEST_TAB_VerticalColorBarHeight, QUEST_TAB_QuestSize, BarColor, true, false, true, false)
                drawRoundedBoxEx(8, QUEST_TAB_QuestGap+QUEST_TAB_VerticalColorBarHeight, CurrentHeight, QUEST_TAB_Width-QUEST_TAB_QuestGap*2-QUEST_TAB_VerticalColorBarHeight, QUEST_TAB_QuestSize, BackgroundColor, false, true, false, true)
            
                CurrentHeight = CurrentHeight+ResH*0.005

                -- Text
                local TempString = Quests["Quest"..i+1]["Text"]
                draw.DrawText(TempString, "PRSBOX_QUESTS_FONT_DEFAULT", QUEST_TAB_Width*.5+ScreenScale(1), CurrentHeight+ScreenScale(1), color_black, TEXT_ALIGN_CENTER)
                draw.DrawText(TempString, "PRSBOX_QUESTS_FONT_DEFAULT", QUEST_TAB_Width*.5, CurrentHeight, color_white, TEXT_ALIGN_CENTER)
            end
        else
            surface.DrawTexturedRectRotated(QUEST_TAB_Width*.93, QUEST_TAB_Height*.5+QUEST_TAB_VerticalColorBarHeight*.5, QUEST_TAB_IconSize, QUEST_TAB_IconSize, -90)
        end

    end

    vgui.Register("Quest.Main", PANEL)
end

-- Loads text and status from server to the client
local function updateQuests()
    Quests["Amount"] = net.ReadUInt(8)
    Quests["DoneAmount"] = 0

    for i=1, Quests["Amount"]do
        Quests["Quest"..i] = {}
        Quests["Quest"..i]["Text"] = net.ReadString()
        Quests["Quest"..i]["IsDone"] = net.ReadBool()
        if Quests["Quest"..i]["IsDone"] then
            Quests["DoneAmount"] = Quests["DoneAmount"]+1
        end
    end
end

-- Requests server to send Quests update.
local function requestUpdateQuests()
    net.Start("PRSBOX_QUESTS_requestUpdate", true)
    net.WriteEntity(LocalPlayer())
    net.SendToServer()
end

concommand.Add( "prsbox_quests_update", requestUpdateQuests, nil, "Reloads list of your quests", 0 )

hook.Add( "OnScreenSizeChanged", "Prsbox_Quests_OnScreenSizeChanged", updateScrVars )
hook.Add( "InitPostEntity", "Prsbox_Quets_RequestUpdateOnInitPostEntity", requestUpdateQuests )

if IsValid( PRSBOXQUESTBOARD ) then PRSBOXQUESTBOARD:Remove() end

hook.Add("Prsbox_ScoreboardShow", "Prsbox_Quest_ScoreboardShow1", function()
    if ( not IsValid( PRSBOXQUESTBOARD ) ) then
        PRSBOXQUESTBOARD = vgui.Create( "Quest.Main", GetHUDPanel() )
    end

    PRSBOXQUESTBOARD:ShowQuests()
end)

hook.Add("ScoreboardHide", "Prsbox_Quest_ScoreboardHide", function()
    if IsValid( PRSBOXQUESTBOARD ) then
        PRSBOXQUESTBOARD:HideQuests()
    end
end)

net.Receive("PRSBOX_QUESTS_Update", updateQuests)