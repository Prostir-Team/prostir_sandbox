local ply = LocalPlayer()
local airlimit = 1

function PRSBOX_PlayerLimitations_AirPing()
    print("AirPong!")
end

hook.Add("Think", "PRSBOX.Playerlimits.hud", function()
    airlimit = math.Clamp(ply:GetNWInt("prsbox.air_stamina") / ply:GetNWInt("prsbox.air_stamina_max"), 0, 1)
    --print("current air percentage:", airlimit * 100)
end)