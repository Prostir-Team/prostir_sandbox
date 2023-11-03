util.AddNetworkString("PRSBOX.StartVote")
util.AddNetworkString("PRSBOX.AddVote")
util.AddNetworkString("PRSBOX.VoteUpdate")
util.AddNetworkString("PRSBOX.ShowMapWinner")

local votes = {}

local VOTE_START = 1
local VOTE_READY = 2
local VOTE_CHANGING = 3

local VOTE_STATE = VOTE_READY

local MESSAGE = {}
MESSAGE[VOTE_START] = "Почати голосування неможливо, тому що сервер тільки що змінив карту!"
MESSAGE[VOTE_CHANGING] = "Почати голосування неможливо, тому що сервер змінює карту!"

local function getMaps()
    local files = file.Find("maps/gm_*.bsp", "GAME")

    return files
end

local function startVote()
    if VOTE_STATE ~= VOTE_READY then
        MakeNotify(MESSAGE[VOTE_STATE], NOTIFY_ERROR, 10)

        return 
    end
    
    local maps = getMaps()

    OpenWindow("PRSBOX.VoteMenu", "Голосовуння", true, 380, 300, false, maps)
    MakeNotify("Почалося голосування за зміну карти!", NOTIFY_HINT, 30)

    timer.Simple(30, endVote)
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

    MakeNotify("Карта " .. mapsWinner .. " була обрана до зміни!", NOTIFY_HINT, 60)
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

hook.Add("PRSBOX:StartVote", "PRSBOX.StartVote", function ()
    startVote()
end)