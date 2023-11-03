

concommand.Add("start_vote", function (ply)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return end

    print(ply:Nick() .. " has activated vote system.")
    
    ply:OpenWindow("DButton", "Test window", true, 200, 100, true)
end)