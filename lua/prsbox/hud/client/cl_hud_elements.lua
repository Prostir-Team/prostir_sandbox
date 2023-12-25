local COMPASS_CachedAng = 0
local ply = LocalPlayer()
local MaterialStamina = Material("hud/stamina_bolt.png")

local LIMITATIONS = {
    ["FadeTime"] = 1, -- "Popping in/out" time
    ["RemainingTime"] = 2.5, -- For how many seconds should display be remained after it was changed last time?
    ["COLOR_Background"] = Color(0,0,0,105),
    ["COLOR_Exhausted"] = Color(40,40,40,255),
    ["COLOR_HUD"] = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), 255),
    
    ["STAMINA"] = {
        ["MaxStamina"] = ply:GetNWInt("prsbox.sprint_stamina_max"),
        ["MaxChunk"] = ply:GetNWInt("prsbox.sprint_stamina_max")/7,
        ["CachedValue"] = ply:GetNWInt("prsbox.sprint_stamina"),
        ["LastChanged"] = CurTime(),
        ["IconSize"] = PRSBOX_HUD_RES_H*.035,

        ["IsDisplayed"] = 0,
        ["FadePlaying"] = 0,
        ["FadeProgress"] = 0,
    },
    ["AIR"] = {
        ["MaxAir"] = ply:GetNWInt("prsbox.air_stamina_max"),
        ["CachedValue"] = ply:GetNWInt("prsbox.air_stamina"),
        ["LastChanged"] = CurTime(),

        ["IsDisplayed"] = 0,
        ["FadePlaying"] = 0,
        ["FadeProgress"] = 0,
        ["AnimPlaying"] = 0,
        ["AnimProgress"] = 0,
    },
}

-- Draws compass if active
function PRSBOX_HUD_drawCompass()

end

-- Draws two types of Stamina indicators, depending if either prsbox hud is enabled or not.
function PRSBOX_HUD_StaminaIndicator()
    local RemainingStamina = ply:GetNWInt("prsbox.sprint_stamina")/LIMITATIONS["STAMINA"]["MaxStamina"]

    -- Anim starters
    if( LIMITATIONS["STAMINA"]["CachedValue"]!=ply:GetNWInt("prsbox.sprint_stamina") )then -- If value changed and it isn't displaying - start displaying
        if( LIMITATIONS["STAMINA"]["IsDisplayed"]==0 )then
            LIMITATIONS["STAMINA"]["IsDisplayed"] = 1
            LIMITATIONS["STAMINA"]["FadePlaying"] = 1
            LIMITATIONS["STAMINA"]["FadeProgress"] = 0
        end
        LIMITATIONS["STAMINA"]["LastChanged"] = CurTime()
    elseif( LIMITATIONS["STAMINA"]["LastChanged"]+LIMITATIONS["RemainingTime"]<CurTime() and LIMITATIONS["STAMINA"]["IsDisplayed"]==1 )then
        LIMITATIONS["STAMINA"]["IsDisplayed"] = 0
        LIMITATIONS["STAMINA"]["FadePlaying"] = 1
        LIMITATIONS["STAMINA"]["FadeProgress"] = 0
    end

    if( LIMITATIONS["STAMINA"]["IsDisplayed"]==1 )then
        if( PRSBOX_HUD_ACTIVE:GetBool() )then -- If hud is enabled -> draw custom display
            draw.NoTexture()
            //surface.SetDrawColor(LIMITATIONS["COLOR_Background"])

            draw.RoundedBox(8, PRSBOX_HUD_RES_W*.02, PRSBOX_HUD_RES_H*.825, PRSBOX_HUD_RES_H*.3, PRSBOX_HUD_RES_H*.06, LIMITATIONS["COLOR_Background"])
            draw.DrawText("STAMINA", "CloseCaption_Bold", PRSBOX_HUD_RES_W*.02+PRSBOX_HUD_RES_H*.15, PRSBOX_HUD_RES_H*.825, LIMITATIONS["COLOR_HUD"], TEXT_ALIGN_CENTER)
        
            surface.SetDrawColor(LIMITATIONS["COLOR_HUD"])
            surface.SetMaterial(MaterialStamina)

            local STEP = PRSBOX_HUD_RES_H*.043
            local GAP = PRSBOX_HUD_RES_H*.004
            local TempStamina = RemainingStamina*LIMITATIONS["STAMINA"]["MaxStamina"]

            for i=1, 7 do
                if( TempStamina>LIMITATIONS["STAMINA"]["MaxChunk"] )then
                    surface.SetDrawColor(LIMITATIONS["COLOR_HUD"])
                elseif( TempStamina>0 )then
                    surface.SetDrawColor(LerpColor(TempStamina/LIMITATIONS["STAMINA"]["MaxChunk"], LIMITATIONS["COLOR_Exhausted"], LIMITATIONS["COLOR_HUD"]))
                else
                    surface.SetDrawColor(LIMITATIONS["COLOR_Exhausted"])
                end

                surface.DrawTexturedRect(PRSBOX_HUD_RES_W*.02+GAP, PRSBOX_HUD_RES_H*.845, LIMITATIONS["STAMINA"]["IconSize"], LIMITATIONS["STAMINA"]["IconSize"])
                GAP = GAP+STEP
                TempStamina = TempStamina - LIMITATIONS["STAMINA"]["MaxChunk"]
            end
        else -- If hud is disabled -> draw as close as possible to original
            
        end
    end

    LIMITATIONS["STAMINA"]["CachedValue"] = RemainingStamina*LIMITATIONS["STAMINA"]["MaxStamina"]
end

-- Draws two types of Air indicators, depending if either prsbox hud is enabled or not.
function PRSBOX_HUD_AirIndicator()

end

function PRSBOX_HUD_drawDamageNotify()
    local DamageType = net.ReadUInt( 8 )
    local DamageAmount = net.ReadUInt( 32 )
    local Attacker = net.ReadEntity()
end

function PRSBOX_HUD_SuffocationNotificationHandler()
    
end