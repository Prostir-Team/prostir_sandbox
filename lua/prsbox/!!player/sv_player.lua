DEFINE_BASECLASS("gamemode_base")

---
--- Local variables
---

local DEFAULT_MODEL = "models/player/kleiner.mdl"

---
--- Hooks
---

hook.Add("PlayerSpawn", "!!!PRSBOX.SetModel", function (ply, tr)
    if not IsValid(ply) then return end

    local playerModel = ply:GetInfo("prsbox_playermodel")

    if not playerModel or playerModel == "" then
        playerModel = DEFAULT_MODEL
    end

    timer.Simple(0.1, function ()
        ply:SetProstirModel(playerModel)
        
        hook.Run("PlayerPostSpawn", ply, tr)
    end)
end)