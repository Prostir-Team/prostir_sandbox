CreateClientConVar("prsbox_lobby_fov", "80", true, false, "", 80, 110)

hook.Add("CalcView", "PRSBOX.Lobby.Camera", function (ply, pos, angles)
    if not IsValid(ply) then return end

    local fov = GetConVar("prsbox_lobby_fov"):GetInt()

    local view = {
		origin = pos - ( angles:Up() * 10 ),
		angles = angles,
		fov = fov,
		drawviewer = false
	}

	return view
end)