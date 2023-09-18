---
--- Hooks
---

hook.Add("PlayerSpawn", "!!!PRSBOX.SetModel", function (ply, tr)
    if not IsValid(ply) then return end

    local playerModel = ply:GetInfo("prsbox_playermodel")

    ply:SetProstirModel(playerModel)
    ply:WeaponSetup()
    ply:MovementSetup()
    ply:ColorSetup()
    
    hook.Run("PlayerPostSpawn", ply, tr)

    return false 
end)

concommand.Add("setup_hands", function (ply)
    ply:SetupHands()
end)