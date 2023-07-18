util.AddNetworkString("PRSBOX.Lobby.StartMenu")

hook.Add("PlayerInitialSpawn", "PRSBOX.Lobby.InitSpawn", function (ply)
    ply:SetNWBool("PRSBOX.InLobby", true)
end)

hook.Add("PlayerSpawn", "PRSBOX.Lobby.MakeSpectator", function (ply, trans)
    if not IsValid(ply) then return end
    
    local inLobby = ply:GetNWBool("PRSBOX.InLobby")
    
    if inLobby then
        ply:CrosshairDisable()
        ply:Freeze(true)
        net.Start("PRSBOX.Lobby.StartMenu")
        net.Send(ply)

        return true 
    end

    ply:Freeze(false)
end)

concommand.Add("prsbox_lobby_test", function (ply, cmd, args)
    if not IsValid(ply) then return end 

    ply:SetNWBool("PRSBOX.InLobby", true )
    ply:KillSilent()
end)

concommand.Add("prsbox_lobby_start", function (ply, cmd, args)
    if not IsValid(ply) then return end 

    ply:SetNWBool("PRSBOX.InLobby", false)
    ply:Spawn()
end)