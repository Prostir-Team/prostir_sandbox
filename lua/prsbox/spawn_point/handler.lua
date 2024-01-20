
hook.Add( "PlayerDisconnected", "FindyasSpawn.Ragequit", function(player)
	if !IsValid(player.SvistoSpawndelka) then return end
	player.SvistoSpawndelka:kys()
end)

hook.Add( "PlayerSpawn", "FindyasSpawn.RespawnPos", function(player)
	if !IsValid(player.SvistoSpawndelka) then return end
    player:EmitSound("buttons/button5.wav")
	player:SetPos( player.SvistoSpawndelka:GetPos() )
end)


