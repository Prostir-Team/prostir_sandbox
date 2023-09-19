// Hides this default hud elements:
local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
    //["CHudWeaponSelection"] = true,
    //["CHudWeaponSelectionItem"] = true,
}

// Doesn't draw ammo hud element for those weapons:
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
    ["ent_jack_gmod_eztoolbox"] = true,
    ["ent_jack_gmod_eztoolbox"] = true,
    ["remotecontroller"] = true,
    ["laserpointer"] = true,
    ["weapon_simmines"] = true,
    ["weapon_simremote"] = true,
    ["weapon_simrepair"] = true,
    ["weapon_medkit"] = true,
}

// Changes ammo hud elements for this weapons:
local ChargesWeapons = {
    ["weapon_slam"] = true,
    ["weapon_frag"] = true,
}

local PRSBOX_HUD_HOOK_NAME = "Prsbox_Hud_"
local MAIN_COLOR = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
local PANELS_COLOR = Color(0,0,0,105)
local MATERIALS_Health = Material("Icon_Health.png")
local MATERIALS_Shield = Material("Icon_Suit_Charge.png")

local CACHED_HEALTH = 0
local CACHED_SUIT = 0

// In function so can be updated on screen resolution changed hook
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
    //AMMO_TEXT_MAINTEXT_OFFET_X = PRSBOX_HUD_RES_W*0.04
end

function PRSBOX_HUD_UpdateColor()
    MAIN_COLOR = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
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

    // To make panel bigger/smaller depending on amount of hp to demonstrate
    surface.SetFont("PRSBOX_HUD_FONT_DEFAULT")
    local HealthTextSize = surface.GetTextSize(HealthString)

    draw.RoundedBox(8, HP_PANEL_POS_X, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+HealthTextSize, HP_PANEL_SIZE_Y, PANELS_COLOR)
    
    surface.SetDrawColor(MAIN_COLOR)

    surface.SetMaterial(MATERIALS_Health)
    surface.DrawTexturedRect(HP_PANEL_POS_X+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET, HP_PANEL_ICON_SIZE, HP_PANEL_ICON_SIZE)
    
    draw.DrawText(HealthString, "PRSBOX_HUD_FONT_DEFAULT", HP_PANEL_POS_X+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)

-- Suit
    if( Local_Player:Armor()>0 and Local_Player:Alive() ) then
        local SuitString = tostring( Local_Player:Armor() ).." "
        local SuitTextSize = surface.GetTextSize(SuitString)
        local Suit_X_Offset = HP_PANEL_POS_X+HP_PANEL_GAP+HealthTextSize

        draw.RoundedBox(8, Suit_X_Offset, HP_PANEL_POS_Y, HP_PANEL_SIZE_X+SuitTextSize, HP_PANEL_SIZE_Y, PANELS_COLOR)
        
        surface.SetDrawColor(MAIN_COLOR)
        surface.SetMaterial(MATERIALS_Shield)
        surface.DrawTexturedRect(Suit_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)
            
        draw.DrawText(SuitString, "PRSBOX_HUD_FONT_DEFAULT", Suit_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)
    end

-- Ammo
    local tempWeapon = Local_Player:GetActiveWeapon()

    if( IsValid(tempWeapon) and not IgnoreWeapon[tempWeapon:GetClass()] ) then
        local AmmoStringClip1 = tostring( tempWeapon:Clip1() ).." "
        local AmmoStringAmmoLeft = tostring( Local_Player:GetAmmoCount( tempWeapon:GetPrimaryAmmoType() ))

        if( string.len(AmmoStringAmmoLeft)<3 )then AmmoStringAmmoLeft = AmmoStringAmmoLeft.." " end -- "Kostyl". Idk why, but this makes HUD look nicer on different amount of ammo

        local AmmoStringAltLeft = ""
        local AmmoBlock1TextSize = surface.GetTextSize(AmmoStringClip1)+surface.GetTextSize(AmmoStringAmmoLeft)
        
        local Ammo_X_Offset = AMMO_PANEL_POS_X-(AmmoBlock1TextSize+HP_PANEL_ICON_SIZE) -- Offsets ammo panel on specified amount (left align basically).

        if( ChargesWeapons[tempWeapon:GetClass()] )then -- weapons with charges (granades, slam, etc. Specified at ChargesWeapons list at the start of this file)
        
        else -- default weapons
            draw.RoundedBox(8, Ammo_X_Offset, HP_PANEL_POS_Y, AmmoBlock1TextSize+HP_PANEL_ICON_SIZE+HP_PANEL_ICON_OFFSET, HP_PANEL_SIZE_Y, PANELS_COLOR)
            
            draw.DrawText(AmmoStringClip1, "PRSBOX_HUD_FONT_DEFAULT", Ammo_X_Offset+HP_PANEL_TEXT_X_OFFSET, HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.15, MAIN_COLOR, TEXT_ALIGN_LEFT)
            draw.DrawText(AmmoStringAmmoLeft, "PRSBOX_HUD_FONT_AMMO", Ammo_X_Offset+HP_PANEL_TEXT_X_OFFSET+surface.GetTextSize(AmmoStringClip1), HP_PANEL_POS_Y+HP_PANEL_SIZE_Y*0.35, MAIN_COLOR, TEXT_ALIGN_LEFT)
        end

        surface.SetDrawColor(MAIN_COLOR)
        surface.SetMaterial(MATERIALS_Shield)
        surface.DrawRect(Ammo_X_Offset+HP_PANEL_ICON_OFFSET, HP_PANEL_POS_Y+HP_PANEL_ICON_OFFSET,HP_PANEL_ICON_SIZE,HP_PANEL_ICON_SIZE)
    end

-- Elements
    if( PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE:GetBool() )then
        drawCompass()
    end
    if( PRSBOX_HUD_ELEMENTS_CROSSHAIR_ACTIVE:GetBool() )then
        drawCrosshair()
    end

    if(_G["QuestsPanel_drawQuests"]!=nil)then
        QuestsPanel_drawQuests(0, PRSBOX_HUD_RES_H*0.175) 
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