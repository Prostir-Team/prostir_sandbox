local COMPASS_CachedAng = 0

-- Draws compass if active
function drawCompass()

end

-- Draws two types of Air indicators, depending if either prsbox hud is enabled or not.
function AirIndicator()

end

function drawDamageNotify()
    local DamageType = net.ReadUInt( 8 )
    local DamageAmount = net.ReadUInt( 32 )
    local Attacker = net.ReadEntity()
end

PRSBOX_HUD_ServerAirNotificationHandler(){
    
}