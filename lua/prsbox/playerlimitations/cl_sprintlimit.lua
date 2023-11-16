local ply = LocalPlayer()
local stamina = 1

function PRSBOX_PlayerLimitations_SprintPing()
    print("AirPong!")
end

hook.Add("Think", "PRSBOX.Playerlimits.hud", function()
    stamina = math.Clamp(ply:GetNWInt("prsbox.sprint_stamina") / ply:GetNWInt("prsbox.sprint_stamina_max"), 0, 1)
    --print("current sprint percentage:", stamina * 100)
end)