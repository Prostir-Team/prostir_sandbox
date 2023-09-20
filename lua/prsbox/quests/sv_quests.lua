util.AddNetworkString("PRSBOX_QUESTS_requestUpdate")
util.AddNetworkString("PRSBOX_QUESTS_Update")

local QuestsTable = {}
local PlayersQuestsTable = {}
local Quests_ID_Craft = {1}
local Quests_ID_Kill = {2, 3, 4}

-- Loads quests/linked entity names/etc. from daily_quests_list.json file
local function updateQuestsTable()
    local QuestJSONPath = "lua/prsbox/quests/daily_quests_list.json"
    local JSON_String = file.Read(QuestJSONPath, true)

    if not JSON_String then
        print("SV_QUESTS.LUA ERROR: COULDN'T OPEN/READ QUESTS JSON FILE")
        return
    end

    QuestsTable = util.JSONToTable(JSON_String)
    //PrintTable(QuestsTable.Tasks)
end

updateQuestsTable()

-- Generates quests table for the given player
local function generateQuestsFor(ply)
    local Task1ID, Task2ID, Task3ID = nil, nil, nil

    local BackupIterator = 0 -- To avoid crashing/infinite loops with syntax errors in JSON.
    local CurrentTask = 1

    while (not Task1ID or not Task2ID or not Task3ID) and BackupIterator < 1000 do
        BackupIterator = BackupIterator + 1

        local TaskID = math.random(1, table.Count(QuestsTable.Tasks))

        if TaskID == Task1ID or TaskID == Task2ID or TaskID == Task3ID then
            continue
        end

        local TaskStr = "Task" .. tostring(CurrentTask)
        PlayersQuestsTable[ply:Name()] = PlayersQuestsTable[ply:Name()] or {}
        PlayersQuestsTable[ply:Name()][TaskStr .. "_id"] = QuestsTable.Tasks[TaskID].id
        PlayersQuestsTable[ply:Name()][TaskStr .. "_desc"] = QuestsTable.Tasks[TaskID].description
        PlayersQuestsTable[ply:Name()][TaskStr .. "_isDone"] = false
        PlayersQuestsTable[ply:Name()][TaskStr .. "_progress"] = 0
        PlayersQuestsTable[ply:Name()][TaskStr .. "_quota"] = math.random( QuestsTable.Tasks[TaskID].quota.min, QuestsTable.Tasks[TaskID].quota.max )

        -- Store the generated task IDs to prevent duplicates
        if CurrentTask == 1 then
            Task1ID = TaskID
        elseif CurrentTask == 2 then
            Task2ID = TaskID
        elseif CurrentTask == 3 then
            Task3ID = TaskID
        end

        CurrentTask = CurrentTask + 1
    end

    if BackupIterator == 1000 then
        print("generateQuestsFor ERROR: Couldn't generate tasks for " .. ply:Name())
        return {}
    end

    return PlayersQuestsTable[ply:Name()]
end

-- Returns table of quests for the specified player
local function getQuestsTableFor(ply)
    local TempTable = {}

    if not doesPlayerHaveQuests(ply) then
        TempTable = generateQuestsFor(ply)
    else
        TempTable = PlayersQuestsTable[ply:Name()]
    end

    return TempTable
end

function doesPlayerHaveQuests(ply)
    return PlayersQuestsTable[ply:Name()] ~= nil
end

local function sendQuestsTableUpdate(ply)
    net.Start("PRSBOX_QUESTS_Update", false)

    local TempTable = getQuestsTableFor(ply)

    for i = 1, 3 do
        local taskID = "Task"..i

        local TempStrArray = string.Explode("*", TempTable[taskID .. "_desc"])
        local TempString = TempStrArray[1] .. "(" .. TempTable[taskID .. "_progress"] .. "/" .. TempTable[taskID .. "_quota"]..")"..TempStrArray[2]

        net.WriteString(TempString)
        net.WriteBool(TempTable[taskID .. "_isDone"])
    end

    net.Send(ply)
end

net.Receive("PRSBOX_QUESTS_requestUpdate", function(_, ply)
    sendQuestsTableUpdate(ply)
end)

hook.Add("PlayerConnect", "PRSBOX_QUESTS_SV_PlayerConnect", function(name, ip)
    -- Add any additional functionality when a player connects
end)

-- Adds a hook that updates attacker's quests if they have kill quests.
hook.Add( "PlayerDeath", "GlobalDeathMessage", function( victim, inflictor, attacker )
    if ( victim == attacker or !attacker:IsPlayer()) then return end

    local TempTable = getQuestsTableFor( attacker )
    for i = 1, 3 do
        local taskID = "Task"..i

        if( TempTable[taskID .. "_isDone"] or not table.HasValue(Quests_ID_Kill, TempTable[taskID .. "_id"]) ) then continue end

        TempTable[taskID .. "_progress"] = TempTable[taskID .. "_progress"]+1

        if( TempTable[taskID .. "_progress"]>=TempTable[taskID .. "_quota"] )then 
            TempTable[taskID .. "_isDone"] = true
            attacker:EmitSound("garrysmod/save_load1.wav")
        end
    end

    sendQuestsTableUpdate(attacker)
end )
