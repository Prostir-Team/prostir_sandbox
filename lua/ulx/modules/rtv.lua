local PLAYER_VOTES = {}

function ulx.rtv(calling_ply)
    if not IsValid(calling_ply) then return end
    if not calling_ply:IsPlayer() then return end

    local steamid = calling_ply:SteamID()

    if table.HasValue(PLAYER_VOTES, steamid) then
        ulx.fancyLogAdmin(calling_ply, "#A вже проголосував.")
        return
    end

    table.insert(PLAYER_VOTES, steamid)

    local playerCount = player.GetCount()
    ulx.fancyLogAdmin(calling_ply, "#A проголосував за зміну карти. (" .. #PLAYER_VOTES .. "/" .. math.ceil(playerCount / 2) .. ")")
    
    if #PLAYER_VOTES >= playerCount / 2 then
        hook.Run("PRSBOX:StartVote")

        PLAYER_VOTES = {}
    end
end

local rtv = ulx.command("Sandbox", "ulx rtv", ulx.rtv, "!rtv")
rtv:defaultAccess(ULib.ACCESS_ALL)
rtv:help("Голосування")