---
--- NET
---

util.AddNetworkString("PRSBOX.Net.PlayerChangeModel")

---
--- Table that saving all player models
---

PLAYER_MODELS = PLAYER_MODELS or {}

---
--- Functions 
---

function CreateModelsTable()
    sql.Query("CREATE DATABASE IF NOT EXISTS player_data")
	sql.Query("CREATE TABLE IF NOT EXISTS player_models (SteamID TEXT, ModelName TEXT)")
end 

function GetAllModels()
    return PLAYER_MODELS
end

function IsModelExist(modelPath)
    local playerModels = GetAllModels()

    for k, v in ipairs(playerModels) do
        if v["modelPath"] == modelPath then
            return true
        end
    end

    return false 
end 

concommand.Add("test_player", function ()
    print(IsModelExist("models/player/p2_chell.mdl"))
end)

function RegistPlayerModel(modelName, modelPath, settings)
    if not isstring(modelName) then return end
    if not isstring(modelName) then return end
    if not istable(settings) then return end
    if IsModelExist(modelPath) then return end

    local playerModel = {
        ["modelName"] = modelName,
        ["modelPath"] = modelPath,
        ["settings"] = settings
    }

    table.insert(PLAYER_MODELS, playerModel)

    print("Player model \"" .. modelName .. "\" (" .. modelPath .. ") successfully has been saved!")
end

function GetModelByModelPath(modelPath)
    local playerModels = GetAllModels()
    
    for k, v in ipairs(playerModels) do
        if v["modelPath"] == modelPath then
            return v
        end
    end
end

function PlayerGetModels(ply)
    local steamid = ply:SteamID()
    
    local data = sql.Query( "SELECT ModelName FROM player_models WHERE SteamID = " .. sql.SQLStr( steamid ) .. ";")
    if not data then return end

    local out = {}

    for k, v in ipairs(data) do
        table.insert(out, v["ModelName"])
    end

    return out
end

function PlayerHasModel(ply, modelName)
    local data = PlayerGetModels(ply)
    if not data then return end

    return table.HasValue(data, modelName)
end

function AddPlayerModel(ply, modelName)
    if PlayerHasModel(ply, modelName) then return end
    
    local steamid = ply:SteamID()

    sql.Query( "INSERT INTO player_models (SteamID, ModelName) VALUES(" .. sql.SQLStr(steamid) .. ", " .. sql.SQLStr(modelName) .. " )" )
end

function ChangePlayerModel(ply, oldModel, newModel)
    if not IsModelExist(oldModel) and not IsModelExist(newModel) then return end

    local model = GetModelByModelPath(newModel)

    local hookReturn = hook.Run("PRSBOX.Player.ChangedModel", ply, model, oldModel, newModel)
    if not hookReturn and hookReturn ~= nil then return end
    
    if not PlayerHasModel(ply, model["modelName"]) then
        print("=============")
        print("Model has been added to player database")
        
        AddPlayerModel(ply, model["modelName"])
    end

    ply:SetProstirModel(newModel)
end

concommand.Add("test_change", function (ply)
    local old = "models/player/p2_chell.mdl"
    local new = "models/player/kleiner.mdl"

    ChangePlayerModel(ply, old, new)
end)

net.Receive("PRSBOX.Net.PlayerChangeModel", function (len, ply)
    local oldModel = net.ReadString()
    local newModel = net.ReadString()

    ChangePlayerModel(ply, oldModel, newModel)
end)

CreateModelsTable()

concommand.Add("model_test", function(ply, cmd, args)
    if not IsValid(ply) then return end

    PrintTable(PlayerGetModels(ply))
end)