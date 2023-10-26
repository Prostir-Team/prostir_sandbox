local COMPASS_CachedAng = 0

-- Draws compass if active
function PRSBOX_HUD_drawCompass()

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