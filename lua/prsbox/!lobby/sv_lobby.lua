util.AddNetworkString("PRSBOX.Lobby.StartMenu")

hook.Add("PlayerSpawn", "PRSBOX.Lobby.MakeSpectator", function (ply, trans)
    if not IsValid(ply) then return end
    
    ply:Spectate(OBS_MODE_IN_EYE)
    ply:CrosshairDisable()

    return true 
end)