util.AddNetworkString("PRSBOX.Hitmarkers.Netcode")

local hitmarkerType = 0

--[[
  hitmarkerType possible values:
  0: simple marker
  1: headshot marker
  2: death marker
]]--

hook.Add("PostEntityTakeDamage", "PRSBOX.Hitmarkers.Server", function(ent, dmg, took)
    local attacker = dmg:GetAttacker()
    local h = ent:Health()
    if ( h <= 0 ) then return end
    --if ( h == ent:GetMaxHealth() ) then return end
    if ( ent:IsRagdoll() ) then return end
    if ( dmg:GetDamage() <= 0 ) then return end
    if ( ent:IsPlayer() and ent:LastHitGroup() == HITGROUP_HEAD ) then -- if headshot then send it
        hitmarkerType = 1
    end
    if ( attacker:IsPlayer() and took) then
        net.Start("PRSBOX.Hitmarkers.Netcode")
        net.WriteUInt(hitmarkerType, 2)
        net.Send(attacker)
    end

    hitmarkerType = 0
end)

hook.Add("PlayerDeath", "PRSBOX.Hitmarkers.Server", function(victim, inflictor, attacker)
    if not ( attacker:IsPlayer() ) then return end
    if ( attacker == victim ) then return end
    hitmarkerType = 2
    net.Start("PRSBOX.Hitmarkers.Netcode")
    net.WriteUInt(hitmarkerType, 2)
    net.Send(attacker)
    hitmarkerType = 0
end)