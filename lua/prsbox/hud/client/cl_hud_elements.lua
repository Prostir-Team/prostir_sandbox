local CachedCompassAng = 0

function drawCompass()

end

function drawCrosshair()

end

function drawDamageNotify()
    local DamageType = net.ReadUInt( 8 )
    local DamageAmount = net.ReadUInt( 32 )
    local Attacker = net.ReadEntity()
end