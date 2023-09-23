local PLAYER_VOTES = {}

function ulx.rtv(calling_ply)
    if not IsValid(calling_ply) then return end
    if not calling_ply:IsPlayer() then return end

    local steamid = calling_ply:SteamID()

    if table.HasValue(PLAYER_VOTES, steamid) then
        print(calling_ply:Nick() .. " has already voted.")
        return
    end

   table.insert(PLAYER_VOTES, steamid) 
end

local rtv = ulx.command("Sandbox", "ulx rtv", ulx.rtv, "!rtv")
rtv:defaultAccess(ULib.ACCESS_ALL)
rtv:help("Голосування")