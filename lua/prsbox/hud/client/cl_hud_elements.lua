local COMPASS_CachedAng = 0

local CROSSHAIR_Color = Color(PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_R:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_G:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_B:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_Alpha:GetInt())
local CROSSHAIR_Outline_Color = Color(PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_R:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_G:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_B:GetInt(), PRSBOX_HUD_ELEMENTS_CROSSHAIR_Alpha:GetInt())
local RealThickness = 1

function drawCompass()

end

function drawCrosshair()
    surface.SetDrawColor(CROSSHAIR_Color)
    draw.NoTexture()
    if( PRSBOX_HUD_ELEMENTS_CROSSHAIR_IsDot ) then
        //surface.DrawRect(PRSBOX_HUD_RES_W*0.5-RealThickness, 1000, 100, 100 )
        //surface.DrawRect(PRSBOX_HUD_RES_W*0.5-(PRSBOX_HUD_RES_H*0.5-RealThickness), PRSBOX_HUD_RES_H*0.5-RealThickness, PRSBOX_HUD_RES_W*0.5+(PRSBOX_HUD_RES_H*0.5+RealThickness*2), PRSBOX_HUD_RES_H*0.5+RealThickness*2 )
    end

end

function drawDamageNotify()
    local DamageType = net.ReadUInt( 8 )
    local DamageAmount = net.ReadUInt( 32 )
    local Attacker = net.ReadEntity()
end