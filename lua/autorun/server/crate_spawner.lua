local traces = {}

local MapName = game.GetMap()
local Chance = 50

concommand.Add("test_command", function (ply)
    local ent = ents.Create("jmod_resource_tradebox")
    ent:SetPos(Vector(0, 0, 0))
    ent:Activate()
    ent:SetNWString("Owner", "World")
    ent:Spawn()
end)

concommand.Add("get_all_poses", function (ply)
    if not IsValid(ply) then return end

    PrintTable(traces)
end)

concommand.Add("get_pos", function (ply)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()

    if not trace then return end

    local ent = ents.Create("prop_physics")
    ent:SetModel("models/props_c17/oildrum001.mdl")
    ent:SetPos(trace.HitPos)
    ent:SetAngles(Angle(0, math.random(0, 360), 0))
    ent:Spawn()

    table.insert(traces, trace.HitPos)
end)

local vecPos = Vector(0,0,0)
local angOff = Angle(0,0,0)

local SP = game.SinglePlayer()

local function spawnCreate( pos, forced )
    if ( not forced ) then
        local chance = math.random(0, 100)
        if chance > Chance then return end
    end
    
    local ent = ents.Create("jmod_resource_tradebox")

    vecPos.x = tonumber( pos[1] )
    vecPos.y = tonumber( pos[2] )
    vecPos.z = tonumber( pos[3] )

    ent:SetPos( vecPos )

    if ( pos[4] and pos[5] and pos[6] ) then
        angOff.p = tonumber( pos[4] )
        angOff.y = tonumber( pos[5] )
        angOff.z = tonumber( pos[6] )

        ent:SetAngles( angOff )
    end

    if ( SP ) then
        debugoverlay.Cross( vecPos, 1, 8, nil, true )
    end
    ent:DropToGround()

    ent:Activate()
    ent:SetNWString("Owner", "World")
    ent:Spawn()
end

local function spawnAllCrates(allPos)
    local l = #allPos
    local hl = math.floor(l * .5)
    for i, strPos in ipairs(allPos) do
        if strPos == "" then continue end

        local pos = string.Split(strPos, " ")
        local forced = ( i == 1 or i == hl or i == l ) or nil
        spawnCreate(pos, forced)
    end
end

local function getFromFileAllPos()
    local mapPath = "maps/" .. MapName .. "_sellbox.txt"
    if not file.Exists(mapPath, "GAME") then return end

    local f = file.Open(mapPath, "r", "GAME")
    if not f then return end

    local data = f:Read()

    return string.Split(data, "\n")
end

local function loadAll()
    local allPos = getFromFileAllPos()
    if not allPos then return end

    spawnAllCrates(allPos)
end

hook.Add("InitPostEntity", "PRSBOX.SpawnCrates", loadAll)
hook.Add("PostCleanupMap", "PRSBOX.SpawnCratesWhenMapHasCleandUp", loadAll)