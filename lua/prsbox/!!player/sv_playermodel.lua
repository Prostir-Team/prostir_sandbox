---
--- Table that saving all player models
---

local PLAYER_MODELS = {}

---
--- Types for all player models
---

MODEL_FREE = 1
MODEL_BUY = 2
MODEL_ACHIVEMENT = 3
MODEL_SUBSCRIBE = 4

---
--- Functions 
---

function CreateModelsTable()
    sql.Query("CREATE DATABASE IF NOT EXISTS player_data")
	sql.Query("CREATE TABLE IF NOT EXISTS player_models (SteamID TEXT, ModelName TEXT)")
end 

function IsModelExist(modelName)
    return false 
end 

function RegistPlayerModel(modelName, modelPath, type, settings)
    if not isstring(modelName) then return end
    if not isstring(modelName) then return end
    if not isnumber(type) then return end
    if not istable(settings) then return end

    local playerModel = {
        ["modelName"] = modelName,
        ["modelPath"] = modelPath,
        ["type"] = type,
        ["settings"] = settings
    }

    table.insert(PLAYER_MODELS, playerModel)

    print("Player model \"" .. modelName .. "\" (" .. modelPath .. ") successfully has been saved!")
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

function GetAllModels()
    return PLAYER_MODELS
end

CreateModelsTable()

concommand.Add("model_test", function(ply, cmd, args)
    if not IsValid(ply) then return end

    PrintTable(PlayerGetModels(ply))
end)