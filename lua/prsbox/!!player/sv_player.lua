---
--- Hooks
---

hook.Add("PlayerSpawn", "!!!PRSBOX.SetModel", function (ply, tr)
    if not IsValid(ply) then return end

    local playerModel = ply:GetInfo("prsbox_playermodel")

    timer.Simple(0.1, function ()
        ply:SetProstirModel(playerModel)
        
        hook.Run("PlayerPostSpawn", ply, tr)
    end)
end)