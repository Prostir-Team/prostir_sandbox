local ply = LocalPlayer()
local stamina = 1

hook.Add("Think", "PRSBOX.Playerlimits.hud", function()
    stamina = math.Clamp(ply:GetNWInt("prsbox.sprint_stamina") / ply:GetNWInt("prsbox.sprint_stamina_max"), 0, 1)
    --print("current sprint percentage:", stamina * 100)
end)