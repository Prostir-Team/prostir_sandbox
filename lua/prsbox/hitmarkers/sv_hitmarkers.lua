util.AddNetworkString("PRSBOX.Hitmarkers.Netcode")

hook.Add("PostEntityTakeDamage", "PRSBOX.Hitmarkers.Server", function(ent, dmg, took)
    local attacker = dmg:GetAttacker()
    local isHead = false
    local h = ent:Health()
    if ( h <= 0 ) then return end
    --if ( h == ent:GetMaxHealth() ) then return end
    if ( ent:IsRagdoll() ) then return end
    if ( dmg:GetDamage() <= 0 ) then return end
    if ( ent:IsPlayer() and ent:LastHitGroup() == 1 ) then -- if headshot then send it
        isHead = true
    end
    if ( attacker:IsPlayer() and took) then
        net.Start("PRSBOX.Hitmarkers.Netcode")
        net.WriteBool(isHead)
        net.Send(attacker)
    end
end)