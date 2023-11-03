util.AddNetworkString("PRSBOX.StartVote")
util.AddNetworkString("PRSBOX.AddVote")
util.AddNetworkString("PRSBOX.VoteUpdate")

local votes = {}

local function getMaps()
    local files = file.Find("maps/gm_*.bsp", "GAME")

    return files
end

local function startVote()
    local maps = getMaps()

    OpenWindow("PRSBOX.VoteMenu", "Голосовуння", true, 380, 300, true, maps)
end

local function getWinner()
    local voteKeys = table.GetKeys(votes)

    local max = 0

    for k, v in ipairs(voteKeys) do
        local vote = votes[v]
        if not vote then continue end

        if #vote > max then
            max = #vote
        end
    end

    if max == 0 then
        return {}
    end

    local winnerMaps = {}

    for k, v in ipairs(voteKeys) do
        local vote = votes[v]
        if not vote then continue end

        if #vote == max then
            table.insert(winnerMaps, v)
        end
    end

    return winnerMaps
end

local function endVote()
    local mapsWinner = getWinner(votes)
    local mapWinner = table.Random(mapsWinner)
    print(mapWinner)
end


net.Receive("PRSBOX.AddVote", function (len, ply)
    local map = net.ReadString()
    local prevMap = net.ReadString()
    local steamid = ply:SteamID()

    if map == prevMap then return end

    if not votes[map] then
        votes[map] = {}
    end

    if not table.HasValue(votes[map], steamid) then 
        table.insert(votes[map], steamid)
    end
    
    if prevMap ~= "" then
        if not votes[prevMap] and prevMap ~= "" then
            votes[prevMap] = {}
        end

        if table.HasValue(votes[prevMap], steamid) then 
            table.RemoveByValue(votes[prevMap], steamid)
        end
    end

    net.Start("PRSBOX.VoteUpdate")
        net.WriteString(map)
        net.WriteString(prevMap)
    net.Broadcast()
end)

concommand.Add("test_end_vote", function()
    endVote()
end)

concommand.Add("start_vote", function (ply)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then return end   

    startVote()
end)