print("PRSBOX Module system has been started!")

local function startSQLModules()
    sql.Query("CREATE TABLEIF NOT EXISTS modules (name TEXT, enabled INTEGER);")

    print("SQL Database has been created.")
end

local function isModuleExists(name)
    local data = sql.Query("SELECT * FROM modules WHERE name = " .. sql.SQLStr(name) .. ";")

    return data ~= nil and data
end

local function addSQLModule(name)
    if isModuleExists(name) then return end

    local data = sql.Query("INSERT INTO modules (name, enabled) VALUES( " .. sql.SQLStr(name) .. ", 1 );")
end

local function getAllModules()
    local data = sql.Query("SELECT * FROM modules;")

    return data
end

local function getModuleState(name)
    if not isModuleExists(name) then return end

    local data = sql.Query("SELECT enabled FROM modules WHERE name = " .. sql.SQLStr(name) ..";")

    if data then
        return data[1]["enabled"]
    end
end

local function bool_to_number(value)
    return value and 1 or 0
end

local function setModuleState(name, state)
    if not isModuleExists(name) then return end
    if not isnumber(state) or state < 0 or state > 1 then return end 

    sql.Query("UPDATE modules SET enabled = " .. state .. " WHERE name = " .. sql.SQLStr(name) .. ";")
end

local function reverseModuleState(name)
    if not isModuleExists(name) then return end
    
    local state = getModuleState(name)
    state = bool_to_number(not tobool(state))

    sql.Query("UPDATE modules SET enabled = " .. state .. " WHERE name = " .. sql.SQLStr(name) .. ";")
end

local function startModule()
    local files, directories = file.Find("prsbox/*", "LUA")
    
    for k, name in ipairs(directories) do
        local path = "prsbox/" .. name .. "/main.lua"

        if SERVER then
            addSQLModule(name)
            local state = getModuleState(name)

            print(name)
            print(state)

            if tobool(state) then
                print("Added " .. name)
                
                include(path)
                AddCSLuaFile(path)
            end

            print("-------")
        end
        
        if CLIENT then
            include(path)
        end
    end
end

concommand.Add("prsbox_module_get", function (ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local modules = getAllModules()
    for k, m in ipairs(modules) do
        print(m["name"] .. " = " .. m["enabled"])
    end
end)

concommand.Add("prsbox_module_set", function (ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    if #args ~= 2 or not isstring(args[1]) or not isstring(args[2]) then return end

    local name = args[1]
    local state = tonumber(args[2])
    
    setModuleState(name, state)
end)

if SERVER then
    startSQLModules()

    -- changeModuleState("hitmarkers")
    PrintTable(getAllModules())
end

startModule()

hook.Add("Initialize", "PRSBOX.Init", function ()
    startModule()
end)