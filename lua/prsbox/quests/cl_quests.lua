local ANIM_Time = 0.75 -- Defines at which delay is quest hud is fully hidden/shown (animation speed)
local ANIM_StartTime = 0 -- Used internally
local STATE_Closed, STATE_Closing, STATE_Opening, STATE_Opened = 1, 2, 3, 4
local CurrentState = 4
local ResW, ResH = ScrW(), ScrH()
local PANEL_Width, PANEL_Height, PANEL_Elements_H_Gap = ResW*0.25, ResH*0.05, ResH*0.01

local Quest_1_String, Quest_2_String, Quest_3_String = "", "", ""
local Quest_1_Finished, Quest_2_Finished, Quest_3_Finished = false, false, false

-- Draws quest panel
function QuestsPanel_drawQuests(x, y)
    local Real_X = 0 -- Used for animation offset
    x = x or 0
    y = y or ResH*0.25

    local CurTimeVar = CurTime() -- Just for slight optimization

    -- Stop animation block
    if( ANIM_StartTime+ANIM_Time<CurTimeVar and (CurrentState==STATE_Closing or CurrentState==STATE_Opening) )then
        if( CurrentState==STATE_Closing )then
            CurrentState = STATE_Closed
        else 
            CurrentState = STATE_Opened
        end
    end

    draw.NoTexture()
    if( CurrentState==STATE_Opened ) then
        Real_X = x
    elseif( CurrentState==STATE_Closed ) then
        Real_X = x-PANEL_Width
    else
        if( CurrentState==STATE_Opening )then -- Animating
            Real_X = Lerp((CurTimeVar-ANIM_StartTime)/ANIM_Time, x-PANEL_Width, x)
        else
            Real_X = Lerp((CurTimeVar-ANIM_StartTime)/ANIM_Time, x, x-PANEL_Width)
        end
    end

    //surface.SetMaterial(Material("Icon_Health.png"))
    surface.DrawTexturedRect(Real_X, y, PANEL_Width, PANEL_Height)

end

function QuestsPanel_IsOpened()
    if( STATE_Opened )then return true
    else return false end
end

function QuestsPanel_Open()
    print("Trying to open!")
    if( CurrentState==STATE_Opened or CurrentState==STATE_Opening )then return end
    CurrentState = STATE_Opening
    ANIM_StartTime = CurTime()
end

function QuestsPanel_Close()
    print("Trying to close!")
    if( CurrentState==STATE_Closed or CurrentState==STATE_Closing )then return end
    CurrentState = STATE_Closing
    ANIM_StartTime = CurTime()
end

function QuestsPanel_Toggle()
    
end

local function updateQuests()
    Quest_1_String = net.readString()
    Quest_2_String = net.readString()
    Quest_3_String = net.readString()

    Quest_1_Finished = net.ReadBool()
    Quest_2_Finished = net.ReadBool()
    Quest_3_Finished = net.ReadBool()
end

local function requestUpdateQuests()
    net.Start("PRSBOX_QUESTS_requestUpdate", true)
    net.WriteEntity(LocalPlayer())
    net.SendToServer()
end

concommand.Add( "prsbox_quests_update", requestUpdateQuests, nil, "Reloads list of your quests", 0 )
concommand.Add( "prsbox_quests_open", QuestsPanel_Open, nil, "Opens list of your quests", 0 )
concommand.Add( "prsbox_quests_close", QuestsPanel_Close, nil, "Closes list of your quests", 0 )


hook.Add( "OnScreenSizeChanged", "Prsbox_Quests_OnScreenSizeChanged", function( oldWidth, oldHeight )
	ResW = ScrW()
	ResH = ScrH()
    PANEL_Width = ResW*0.25
    PANEL_Height = ResH*0.05
end )

net.Receive("PRSBOX_QUESTS_Update", updateQuests)