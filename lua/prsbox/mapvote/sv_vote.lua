util.AddNetworkString("PROSTIR.VoteMenu")
util.AddNetworkString("PROSTIR.UpdateVote")
util.AddNetworkString("PROSTIR.EndVote")
util.AddNetworkString("PROSTIR.WarningVote")

SetGlobalBool("PROSTIR.GLOBAL.vote", false)

local curTime

local timeToVoteEnd = 30
local warningTime = 60

local voteTimeEnable = false 
local lastMap = ""

local GAME = "GAME"

local function getMaps()
    local f = file.Open("cfg/maps.json", "r", "GAME")
    if not f then return end

    local data = f:Read( f:Size() )
    if data == "" then return end

    local maps = util.JSONToTable( data )

    for map, desc in pairs( maps ) do
        if ( not file.Exists( "maps/" .. map .. ".bsp", GAME ) ) then
            MsgAll( map .. " Is MISSING!!!" )
            maps[ map ] = nil
        end
    end
    
    if lastMap ~= "" then
        table.RemoveByValue(maps, lastMap)
    end
    
    return maps
end

local function loadIcons()
    local maps = table.GetKeys(getMaps())

    for k, map in ipairs(maps) do
        resource.AddSingleFile("maps/thumb/" .. map .. ".png")
    end
end

loadIcons()

local function resetPlayerVotes()
    local players = player.GetAll()

    for _, ply in ipairs(players) do
        ply:SetNWString("PROSTIR.NW.VoteMap", "")
    end
end

local function changeToVotedMap()
    local players = player.GetAll()
    local votes = {}
    local win_maps = {}

    for _, ply in ipairs(players) do
        if not IsValid(ply) then continue end
        
        local map = tostring( ply:GetNWString("PROSTIR.NW.VoteMap", "") )
        if map == "" then continue end

        if ( votes[map] ) then 
            votes[map] = votes[map] + 1
        else
            votes[map] = 1
        end
    end

    local sorted = table.SortByKey(votes)

    local max_vote = votes[sorted[1]]

    for v, k in pairs( votes ) do
        if votes[v] == max_vote then
            table.insert(win_maps, v)
        end
    end

    local map = ""

    if #win_maps == 1 then
        map = win_maps[1]
    else
        map = game.GetMap()
    end

    local map_change = map == game.GetMap()

    net.Start("PROSTIR.EndVote")
        net.WriteString(map)
        net.WriteBool( map_change )
    net.Broadcast()

    SetGlobalBool("PROSTIR.GLOBAL.vote", not map_change)

    if map_change then 
        lastMap = map
        
        return 
    end
    
    timer.Simple(60, function ()
        RunConsoleCommand("changelevel", map)
    end)
end

local function startVote()
    if GetGlobalBool("PROSTIR.GLOBAL.vote") then return end
    
    resetPlayerVotes()

    local maps = getMaps()

    net.Start("PROSTIR.VoteMenu")
        net.WriteString( util.TableToJSON(maps) )
        net.WriteFloat( timeToVoteEnd )
    net.Broadcast()

    SetGlobalBool("PROSTIR.GLOBAL.vote", true)

    curTime = CurTime()
end


hook.Add("Tick", "PRSBOX.Vote.Tick", function ()
    if not curTime then return end

    if CurTime() - curTime > timeToVoteEnd then
        curTime = nil 

        changeToVotedMap()
    end
end)

hook.Add("PRSBOX:StartVote", "PRSBOX.Start.Vote", startVote)

util.PRSBOXStartVote = startVote

concommand.Add("StartVote", function (ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    
    hook.Run("PRSBOX:StartVote")
end)

concommand.Add("prostir_vote", function (ply, cmd, args)
    if not GetGlobalBool("PROSTIR.GLOBAL.vote") then return end
    
    local prev_map = ply:GetNWString("PROSTIR.NW.VoteMap", "")
    local map = args[1]

    if map == prev_map then return end

    ply:SetNWString("PROSTIR.NW.VoteMap", map)

    local send = {
        ["prev_map"] = prev_map,
        ["map"] = map
    }

    net.Start("PROSTIR.UpdateVote")
        net.WriteString(util.TableToJSON(send))
    net.Broadcast()
end)