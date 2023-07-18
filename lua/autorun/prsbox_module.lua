print("PRSBOX Module system has been started!")

function bool_to_number(value)
    return value and 1 or 0
end

if SERVER then
    local function startSaveModules()
        if file.Exists("modules.dat", "DATA") then return end
        
        file.Write("modules.dat", "")
    end
    
    function getAllModules()
        local f = file.Open("modules.dat", "r", "DATA")

        local data = f:Read()

        if file.Size("modules.dat", "DATA") == 0 then return end

        local data = string.Split(data, "\n")
        local out = {}

        for k, line in ipairs(data) do
            table.insert(out, string.Split(line, " "))
        end
        
        return out
    end

    function isModuleExists(name)
        local modules = getAllModules()
        
        if not modules then return end

        for k, m in ipairs(modules) do
            if m[1] == name then
                return true 
            end
        end
    end
    
    function addSaveModule(name)
        if isModuleExists(name) then return end
    
        file.Append("modules.dat", name .. " 1\n")
    end
    
    function getModuleState(name)
        if not isModuleExists(name) then return end
    
        local data = getAllModules()
        if not data then return end

        for k, m in ipairs(data) do
            if m[1] == name then
                return m[2]
            end
        end
    end
    
    function modulesToString(modules)
        local out = ""

        for k, m in ipairs(modules) do
            if m[1] == "" then continue end
            
            out = out .. m[1] .. " " .. m[2] .. "\n"
        end

        return out
    end

    function setModuleState(name, state)
        if not isModuleExists(name) then return end
        if not isnumber(state) or state < 0 or state > 1 then return end 
        
        local modules = getAllModules()

        for k, m in ipairs(modules) do
            if m[1] == name then
                m[2] = state
            end
        end

        if not file.Exists("modules.dat", "DATA") then return end

        file.Write("modules.dat", modulesToString(modules))
    end
    
    function reverseModuleState(name)
        if not isModuleExists(name) then return end
        
        local state = getModuleState(name)
        state = bool_to_number(not tobool(state))
    
        setModuleState(name, state)
    end

    startSaveModules()
end


local function startModule()
    local files, directories = file.Find("prsbox/*", "LUA")
    
    for k, name in ipairs(directories) do
        local path = "prsbox/" .. name .. "/main.lua"

        if SERVER then
            addSaveModule(name)
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

if SERVER then
    concommand.Add("prsbox_module_get", function (ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local modules = getAllModules()
        for k, m in ipairs(modules) do
            if m[1] == "" then continue end
            
            print(m[1] .. " = " .. m[2])
        end
    end)

    concommand.Add("prsbox_module_set", function (ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        if #args ~= 2 or not isstring(args[1]) or not isstring(args[2]) then return end

        local name = args[1]
        local state = tonumber(args[2])
        
        setModuleState(name, state)
    end)
end

startModule()

hook.Add("Initialize", "PRSBOX.Init", function ()
    startModule()
end)