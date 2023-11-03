util.AddNetworkString("PRSBOX.StartVote")

concommand.Add("start_vote", function (ply)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return end
    
    ply:OpenWindow("PRSBOX.VoteMenu", "Голосовуння", true, 380, 300, true)
end)