---
--- Hooks
---

hook.Add("PlayerSpawn", "!!!PRSBOX.SetModel", function (ply, tr)
    if not IsValid(ply) then return end

    local playerModel = ply:GetInfo("prsbox_playermodel")

    ply:SetProstirModel(playerModel)
    ply:WeaponSetup()
    ply:GiveAllAmmos()
    
    hook.Run("PlayerPostSpawn", ply, tr)
end)

-- concommand.Add("setup_hands", function (ply)
--     ply:SetupHands()
-- end)


---
--- Network
---

util.AddNetworkString("PRSBOX.PlayerMessages")

local function SendPlyMessage( name, id )
    net.Start("PRSBOX.PlayerMessages")
        net.WriteString(name)
        net.WriteUInt(id, 2)
    net.Broadcast()
end

hook.Add("PlayerDisconnected", "PRSBOX.PlayerMessages.Leave", function(ply)
    SendPlyMessage( ply:Nick(), 1 ) 
end)

hook.Add("PlayerConnect", "PRSBOX.PlayerMessages.Join", function(name)
    SendPlyMessage( name, 2 ) 
end)

hook.Add("PlayerFullLoad", "PRSBOX.PlayerMessages.PlayerFullLoad", function(ply)
    SendPlyMessage( ply:Nick(), 3 ) 
end)