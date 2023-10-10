-- Hides this default hud elements:
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
    //["CHudWeaponSelection"] = true,
    //["CHudWeaponSelectionItem"] = true,
}

local Ammo_Icons = {
    ["Shotgun"] = Material("Icon_Ammo_Shotgun.png"),
    ["SLAM"] = Material("Icon_Ammo_SLAM.png"),
    ["Grenade"] = Material("Icon_Ammo_Grenade.png"),
    ["Magnum"] = Material("Icon_Ammo_Magnum.png"),
    ["Pistol"] = Material("Icon_Ammo_Pistol.png"),
    ["RPG"] = Material("Icon_Ammo_RPG.png"),
    ["SMG"] = Material("Icon_Ammo_SMG.png"),
}

local WeaponIcons = {
    ["weapon_shotgun"] = Ammo_Icons["Shotgun"],
    ["weapon_357"] = Ammo_Icons["Magnum"],
    ["weapon_crossbow"] = Ammo_Icons["Magnum"],
    ["weapon_pistol"] = Ammo_Icons["Pistol"],
    ["weapon_rpg"] = Ammo_Icons["RPG"],
    ["weapon_frag"] = Ammo_Icons["Grenade"],
    ["weapon_slam"] = Ammo_Icons["SLAM"],
}

-- Doesn't draw ammo hud element for those weapons:
local IgnoreWeapon = {
    ["weapon_bugbait"] = true,
    ["weapon_physcannon"] = true,
    ["weapon_medkit"] = true,
    ["weapon_slam"] = true,
}

-- Changes ammo hud elements for this weapons (and overrides IgnoreWeapon if item is present there)
local ChargesWeapons = {
    ["weapon_slam"] = true,
    ["weapon_frag"] = true,
}

local PRSBOX_HUD_HOOK_NAME = "Prsbox_Hud_"
local MAIN_COLOR = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
local PANELS_COLOR = Color(0,0,0,105)
local MATERIALS_Health = Material("Icon_Health.png")
local MATERIALS_Shield = Material("Icon_Suit_Charge.png")

local ANIM_Delay = 0.5 -- Delay of animation in seconds
local ANIM_StartedTime_Health, ANIM_StartedTime_Suit = 0, 0
local ANIM_PLAYING, ANIM_IDLE = 1, 0
local ANIM_STATE_Health, ANIM_STATE_Suit = 0, 0

-- Used for comparing to start animation
local CACHED_HEALTH, CACHED_SUIT = 0, 0

-- In function so can be updated on screen resolution changed hook
local function updateStaticValues()
    HP_PANEL_POS_X = PRSBOX_HUD_RES_W*0.02
    HP_PANEL_POS_Y = PRSBOX_HUD_RES_H*0.9
    HP_PANEL_SIZE_X = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_SIZE_Y = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_ICON_OFFSET = PRSBOX_HUD_RES_H*0.0125
    HP_PANEL_ICON_SIZE = PRSBOX_HUD_RES_H*0.05
    HP_PANEL_TEXT_X_OFFSET = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_GAP = PRSBOX_HUD_RES_W*0.05

    AMMO_PANEL_POS_X = PRSBOX_HUD_RES_W*0.98
    AMMO_PANEL_SIZE_X = PRSBOX_HUD_RES_W*0.125
end

-- Function to update HUD color on cvar change
function PRSBOX_HUD_UpdateColor()
    MAIN_COLOR = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
end

updateStaticValues()

----------=================[Main Functions]=================----------
local function UpdateHUD()
    local Local_Player = LocalPlayer()
    local PanelColor = PANELS_COLOR
    local CurTimeVar = CurTime()

-- Health
    -- If animation cvar is 1 - then decides should the animation start
    if( PRSBOX_HUD_ANIMATION_ACTIVE:GetBool() )then
        if( math.abs((Local_Player:Health()-CACHED_HEALTH))>2 )then
            ANIM_STATE_Health = ANIM_PLAYING
            ANIM_StartedTime_Health = CurTimeVar
        end

        CACHED_HEALTH = Local_Player:Health()

        -- Animation
        if( ANIM_STATE_Health==ANIM_PLAYING )then
            PanelColor = LerpColor((CurTimeVar-ANIM_StartedTime_Health)/ANIM_Delay, MAIN_COLOR, PANELS_COLOR)
            if( (CurTimeVar-ANIM_StartedTime_Health)/ANIM_Delay>=1 )then ANIM_STATE_Health = ANIM_IDLE end
        end
    end

    -- " " needed here to make resizing correct.
    local HealthString = hook.Run("PRSBOX.HUD.HealthString")
    if not HealthString then
        if( Local_Player:Alive() )then
            HealthString = tostring( Local_Player:Health() ).." "
        else
            HealthString = "KIA "
        end
    end

    local HealthColor = hook.Run("PRSBOX.HUD.HealthColor")
    if not HealthColor then
        HealthColor = MAIN_COLOR
    end
    
    -- To make panel bigger/smaller depending on amount of hp to demonstrate
    surface.SetFont("PRSBOX_HUD_FONT_DEFAULT")
    local HealthTextSize = surface.GetTextSize(HealthString)

    draw.RoundedBox(8, HP_PANEL_POS_X, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+HealthTextSize, HP_PANEL_SIZE_Y, PanelColor)
    
    surface.SetDrawColor(HealthColor)

    surface.SetMaterial(MATERIALS_Health)
    surface.DrawTexturedRect(HP_PANEL_POS_X+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET, HP_PANEL_ICON_SIZE, HP_PANEL_ICON_SIZE)
    
    draw.DrawText(HealthString, "PRSBOX_HUD_FONT_DEFAULT", HP_PANEL_POS_X+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, HealthColor, TEXT_ALIGN_LEFT)

-- Suit
    PanelColor = PANELS_COLOR
    if( PRSBOX_HUD_ANIMATION_ACTIVE:GetBool() )then
        if( math.abs((Local_Player:Armor()-CACHED_SUIT))>2 )then
            ANIM_STATE_Suit = ANIM_PLAYING
            ANIM_StartedTime_Suit = CurTimeVar
        end

        CACHED_SUIT = Local_Player:Armor()

        if( ANIM_STATE_Suit==ANIM_PLAYING )then
            PanelColor = LerpColor((CurTimeVar-ANIM_StartedTime_Suit)/ANIM_Delay, MAIN_COLOR, PANELS_COLOR)
            if( (CurTimeVar-ANIM_StartedTime_Suit)/ANIM_Delay>=1 )then ANIM_STATE_Suit = ANIM_IDLE end
        end
    end

    if( Local_Player:Armor()>0 and Local_Player:Alive() ) then
        local SuitString = tostring( Local_Player:Armor() ).." "
        local SuitTextSize = surface.GetTextSize(SuitString)
        local Suit_X_Offset = HP_PANEL_POS_X+HP_PANEL_GAP+HealthTextSize

        draw.RoundedBox(8, Suit_X_Offset, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+SuitTextSize, HP_PANEL_SIZE_Y, PanelColor)
        
        surface.SetDrawColor(MAIN_COLOR)
        surface.SetMaterial(MATERIALS_Shield)
        surface.DrawTexturedRect(Suit_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)
            
        draw.DrawText(SuitString, "PRSBOX_HUD_FONT_DEFAULT", Suit_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)
    end

-- Ammo
    local tempWeapon = Local_Player:GetActiveWeapon()
    if( tempWeapon:IsValid() )then
        local tempWeaponClass = tempWeapon:GetClass()

        if( not IgnoreWeapon[tempWeaponClass] and tempWeapon:Clip1()!=-1 ) then
            local AmmoStringClip1 = tostring( tempWeapon:Clip1() ).." "
            local AmmoStringAmmoLeft = tostring( Local_Player:GetAmmoCount( tempWeapon:GetPrimaryAmmoType() ))

            if( string.len(AmmoStringAmmoLeft)<3 )then AmmoStringAmmoLeft = AmmoStringAmmoLeft.." " end -- "Kostyl". Idk why, but this makes HUD look nicer on different amount of ammo

            local AmmoBlock1TextSize = surface.GetTextSize(AmmoStringClip1)+surface.GetTextSize(AmmoStringAmmoLeft)
            
            local Ammo_X_Offset = AMMO_PANEL_POS_X-(AmmoBlock1TextSize+HP_PANEL_ICON_SIZE) -- Offsets ammo panel on specified amount (left align basically).

            draw.RoundedBox(8, Ammo_X_Offset, HP_PANEL_POS_Y, AmmoBlock1TextSize+HP_PANEL_ICON_SIZE+HP_PANEL_ICON_OFFSET, HP_PANEL_SIZE_Y, PANELS_COLOR)
                
            draw.DrawText(AmmoStringClip1, "PRSBOX_HUD_FONT_DEFAULT", Ammo_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)
            draw.DrawText(AmmoStringAmmoLeft, "PRSBOX_HUD_FONT_AMMO", Ammo_X_Offset+HP_PANEL_TEXT_X_OFFSET+surface.GetTextSize(AmmoStringClip1), HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.35, MAIN_COLOR, TEXT_ALIGN_LEFT)

            surface.SetDrawColor(MAIN_COLOR)
            local TempMaterial = WeaponIcons[tempWeaponClass] or Ammo_Icons["SMG"]

            surface.SetMaterial(TempMaterial)
            surface.DrawTexturedRect(Ammo_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)
        end

        if( ChargesWeapons[tempWeaponClass] )then
            local AmmoStringClip1 = tostring( tempWeapon:Clip1() ).."  "
            local TempMaterial = WeaponIcons[tempWeaponClass] or WeaponIcons["Grenade"]

            if( tempWeaponClass=="weapon_frag" )then
                AmmoStringClip1 = tostring( Local_Player:GetAmmoCount( tempWeapon:GetPrimaryAmmoType() )).."  "
            elseif( tempWeaponClass=="weapon_slam" )then
                AmmoStringClip1 = tostring( Local_Player:GetAmmoCount( tempWeapon:GetSecondaryAmmoType() )).."  "
            end

            local AmmoBlock1TextSize = surface.GetTextSize(AmmoStringClip1)
            
            local Ammo_X_Offset = AMMO_PANEL_POS_X-(AmmoBlock1TextSize+HP_PANEL_ICON_SIZE) -- Offsets ammo panel on specified amount (left align basically).

            draw.RoundedBox(8, Ammo_X_Offset, HP_PANEL_POS_Y, AmmoBlock1TextSize+HP_PANEL_ICON_SIZE+HP_PANEL_ICON_OFFSET, HP_PANEL_SIZE_Y, PANELS_COLOR)
                
            draw.DrawText(AmmoStringClip1, "PRSBOX_HUD_FONT_DEFAULT", Ammo_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)
            
            surface.SetDrawColor(MAIN_COLOR)
            surface.SetMaterial(TempMaterial)
            surface.DrawTexturedRect(Ammo_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)
        end
    end

    -- Elements
    if( PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE:GetBool() )then
        drawCompass()
    end

    AirIndicator()

    -- if QuestsPanel_drawQuests exists then call it.
    if(_G["QuestsPanel_drawQuests"]!=nil)then
        QuestsPanel_drawQuests(0, PRSBOX_HUD_RES_H*0.175) 
    end
end


----------=================[HOOKS+HANDLERS]=================----------

-- Welcome message
hook.Add("Initialize", PRSBOX_HUD_HOOK_NAME.."Initialize", function()
    print("\n\n")
    print([[
        ====================================================
        =          Prostir Sandbox HUD is loaded!          =
        = You can turn it on/off in Utilities->prsbox->HUD =
        =    for any bug reports - contact @deltamolfar    =
        ====================================================
        ]]
    )
    print("\n\n")
end )

-- Hook to hide elements that were rewritten with this addon
hook.Add("HUDShouldDraw", PRSBOX_HUD_HOOK_NAME.."HUDShouldDraw", function(name)
    if(hide[name] and PRSBOX_HUD_ACTIVE:GetBool()) then
        return false
    end
end )

-- Hook for drawing the HUD
hook.Add("HUDPaint", PRSBOX_HUD_HOOK_NAME.."HUDPaint", function()
    if(not IsValid(LocalPlayer()) or not PRSBOX_HUD_ACTIVE:GetBool()) then
        return
    end

    UpdateHUD()
end )

-- Hook for handling screen resolution changes
hook.Add( "OnScreenSizeChanged", PRSBOX_HUD_HOOK_NAME.."OnScreenSizeChanged", updateStaticValues )

-- Network receive hook for damage notifications
net.Receive("PRSBOX_HUD_DamageNotify", drawDamageNotify)

net.Receive("PlayerPreSuffocationMsg", PRSBOX_HUD_ServerAirNotificationHandler)