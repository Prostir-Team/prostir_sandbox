//BoxRocket

-- Init default values
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
    //["CHudWeaponSelection"] = true,
    //["CHudWeaponSelectionItem"] = true,
}

local IgnoreWeapon = {
    ["weapon_bugbait"] = true,
    ["weapon_crowbar"] = true,
    ["weapon_physcannon"] = true,
    ["weapon_stunstick"] = true,
    ["weapon_fists"] = true,
    ["gmod_tool"] = true,
    ["wep_jack_gmod_hands"] = true,
    ["none"] = true,
    ["weapon_physgun"] = true,
    ["weapon_rpg"] = true,
}

local ChargesWeapons = {
    ["weapon_slam"] = true,
    ["weapon_frag"] = true,
}

local PRSBOX_HUD_HOOK_NAME = "Prsbox_Hud_"
local MAIN_COLOR = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
local PANELS_COLOR = Color(0,0,0,105)
local MATERIALS_Health = Material("health-placeholder")
local MATERIALS_Shield = Material("armor-placeholder")

local CACHED_HEALTH = 0
local CACHED_SUIT = 0

/*
local HP_PANEL_POS_X = PRSBOX_HUD_RES_W*0.02
local HP_PANEL_POS_Y = PRSBOX_HUD_RES_H*0.9
local HP_PANEL_SIZE_X = PRSBOX_HUD_RES_H*0.075
local HP_PANEL_SIZE_Y = PRSBOX_HUD_RES_H*0.075
local HP_PANEL_ICON_OFFSET = PRSBOX_HUD_RES_H*0.0125
local HP_PANEL_ICON_SIZE = PRSBOX_HUD_RES_H*0.05
local HP_PANEL_TEXT_X_OFFSET = PRSBOX_HUD_RES_H*0.075
local HP_PANEL_GAP = PRSBOX_HUD_RES_W*0.05

local AMMO_PANEL_POS_X = PRSBOX_HUD_RES_W*0.85
local AMMO_PANEL_SIZE_X = PRSBOX_HUD_RES_W*0.15
local AMMO_PANEL_SIZE_Y = PRSBOX_HUD_RES_H*0.075
*/

local function updateStaticValues()
    HP_PANEL_POS_X = PRSBOX_HUD_RES_W*0.02
    HP_PANEL_POS_Y = PRSBOX_HUD_RES_H*0.9
    HP_PANEL_SIZE_X = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_SIZE_Y = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_ICON_OFFSET = PRSBOX_HUD_RES_H*0.0125
    HP_PANEL_ICON_SIZE = PRSBOX_HUD_RES_H*0.05
    HP_PANEL_TEXT_X_OFFSET = PRSBOX_HUD_RES_H*0.075
    HP_PANEL_GAP = PRSBOX_HUD_RES_W*0.05

    AMMO_PANEL_POS_X = PRSBOX_HUD_RES_W*0.8625
    AMMO_PANEL_SIZE_X = PRSBOX_HUD_RES_W*0.125
    AMMO_PANEL_SIZE_Y = PRSBOX_HUD_RES_H*0.075
end

updateStaticValues()

----------=================[Main Functions]=================----------
local function UpdateHUD()
    local Local_Player = LocalPlayer()
-- Health
    local HealthString = ""
    if( Local_Player:Alive() )then
        HealthString = tostring( Local_Player:Health() ).." "
    else
        HealthString = "KIA "
    end

    surface.SetFont("PRSBOX_HUD_FONT_HEALTH")
    local HealthTextSize = surface.GetTextSize(HealthString)

    draw.RoundedBox(8, HP_PANEL_POS_X, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+HealthTextSize, HP_PANEL_SIZE_Y, PANELS_COLOR)
    
    surface.SetDrawColor(MAIN_COLOR)
    surface.SetMaterial(MATERIALS_Health)
    surface.DrawRect(HP_PANEL_POS_X+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET, HP_PANEL_ICON_SIZE, HP_PANEL_ICON_SIZE)
    
    
    draw.DrawText(HealthString, "PRSBOX_HUD_FONT_HEALTH", HP_PANEL_POS_X+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.25, MAIN_COLOR, TEXT_ALIGN_LEFT)

-- Suit
    if( Local_Player:Armor()>0 && Local_Player:Alive() ) then
        local SuitString = tostring( Local_Player:Armor() ).." "
        local SuitTextSize = surface.GetTextSize(SuitString)
        local Suit_X_Offset = HP_PANEL_POS_X+HP_PANEL_GAP+HealthTextSize
        draw.RoundedBox(8, Suit_X_Offset, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+SuitTextSize, HP_PANEL_SIZE_Y, PANELS_COLOR)
        
        surface.SetDrawColor(MAIN_COLOR)
        surface.SetMaterial(MATERIALS_Shield)
        surface.DrawRect(Suit_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)

        draw.DrawText(SuitString, "PRSBOX_HUD_FONT_HEALTH", Suit_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.25, MAIN_COLOR, TEXT_ALIGN_LEFT)
    end

-- Ammo
    local tempWeapon = Local_Player:GetActiveWeapon()
    if( IsValid(tempWeapon) and not IgnoreWeapon[tempWeapon:GetClass()] ) then
        if( tempWeapon:Clip2()!=-1 and not ChargesWeapons[tempWeapon:GetClass()] )then
            draw.RoundedBox(8, AMMO_PANEL_POS_X, HP_PANEL_POS_Y, AMMO_PANEL_SIZE_X*0.5, AMMO_PANEL_SIZE_Y, PANELS_COLOR)
            draw.DrawText(tempWeapon:Clip2(), "PRSBOX_HUD_FONT_HEALTH", AMMO_PANEL_POS_X, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.25, MAIN_COLOR, TEXT_ALIGN_LEFT)
         
            draw.RoundedBox(8, AMMO_PANEL_POS_X, HP_PANEL_POS_Y, AMMO_PANEL_SIZE_X, AMMO_PANEL_SIZE_Y, PANELS_COLOR)
            draw.DrawText(tempWeapon:Clip1(), "PRSBOX_HUD_FONT_HEALTH", AMMO_PANEL_POS_X, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.25, MAIN_COLOR, TEXT_ALIGN_LEFT)
        else
            draw.RoundedBox(8, AMMO_PANEL_POS_X, HP_PANEL_POS_Y, AMMO_PANEL_SIZE_X, AMMO_PANEL_SIZE_Y, PANELS_COLOR)
            draw.DrawText(tempWeapon:Clip1(), "PRSBOX_HUD_FONT_HEALTH", AMMO_PANEL_POS_X, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.25, MAIN_COLOR, TEXT_ALIGN_LEFT)
        end
    end

-- Elements
    if( PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE:GetBool() )then
        drawCompass()
    end
    if( PRSBOX_HUD_ELEMENTS_CROSSHAIR_ACTIVE:GetBool() )then
        drawCrosshair()
    end
end



----------=================[HOOKS+HANDLERS]=================----------

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

hook.Add("HUDShouldDraw", PRSBOX_HUD_HOOK_NAME.."HUDShouldDraw", function(name)
    if(hide[name] and PRSBOX_HUD_ACTIVE:GetBool()) then
        return false
    end
end )

hook.Add("HUDPaint", PRSBOX_HUD_HOOK_NAME.."HUDPaint", function()
    if(not IsValid(LocalPlayer()) or not PRSBOX_HUD_ACTIVE:GetBool()) then
        return
    end

    UpdateHUD()
end )

hook.Add( "OnScreenSizeChanged", PRSBOX_HUD_HOOK_NAME.."OnScreenSizeChanged", updateStaticValues )

net.Receive("PRSBOX_HUD_DamageNotify", drawDamageNotify)