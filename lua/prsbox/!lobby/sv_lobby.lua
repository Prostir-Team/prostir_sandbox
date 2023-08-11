util.AddNetworkString("PRSBOX.Lobby.StartMenu")
util.AddNetworkString("PRSBOX.Lobby.CheckDeath")

local PLAYER_LAST_WEAPON = NULL 

hook.Add("PlayerInitialSpawn", "PRSBOX.Lobby.InitSpawn", function (ply)
    ply:SetNWBool("PRSBOX.InLobby", true)
end)

hook.Add("PlayerPostSpawn", "PRSBOX.Lobby.StartMenu", function (ply, tr)
    if not IsValid(ply) then return end
    if ply:IsBot() then return end

    local inLobby = ply:GetNWBool("PRSBOX.InLobby")


    if inLobby then
        ply:Freeze(true)
        ply:SetActiveWeapon(NULL)
        net.Start("PRSBOX.Lobby.StartMenu")
        net.Send(ply)
    else
        ply:Freeze(false)
    end
end)

concommand.Add("prsbox_lobby_test", function (ply, cmd, args)
    if not IsValid(ply) then return end 

    ply:SetNWBool("PRSBOX.InLobby", true )
    ply:Spawn()
end)

concommand.Add("prsbox_lobby_start", function (ply, cmd, args)
    if not IsValid(ply) then return end 

    ply:SetNWBool("PRSBOX.InLobby", false)
    ply:Spawn()
end)

hook.Add("PostPlayerDeath", "PRSBOX.Lobby.CheckDeath", function (ply)
    if not IsValid(ply) then return end

    net.Start("PRSBOX.Lobby.CheckDeath")
    net.Send(ply)
end)