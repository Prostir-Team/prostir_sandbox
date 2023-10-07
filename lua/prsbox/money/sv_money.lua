local DIR_MONEY = "prostir_money/"

local function initProstirMoney()
    if not file.Exists(DIR_MONEY, "DATA") then
        file.CreateDir(DIR_MONEY)
    end


end

local function formatPlayerMoney(steamid)
    return DIR_MONEY .. steamid .. ".dat"
end

local function playerMoneyExist(steamid)
    return file.Exists(formatPlayerMoney(steamid), "DATA")
end

local function createPlayerMoney(steamid)
    if playerMoneyExist(steamid) then return end

    file.Write(formatPlayerMoney(steamid), "0")
end

local function loadEntityPrices()
    
end

createPlayerMoney("76561198032071176") -- 76561198032071176

local function getPlayerMoney(steamid)
    if not playerMoneyExist(steamid) then
        createPlayerMoney(steamid)
    end

    local money = file.Read(formatPlayerMoney(steamid), "DATA")

    return tonumber(money)
end

local function setPlayerMoney(steamid, quantity)
    if not playerMoneyExist(steamid) then
        createPlayerMoney(steamid)
    end

    file.Write(formatPlayerMoney(steamid), tostring(quantity))
end

concommand.Add("money_get", function (ply, cmd, args)
    local money = getPlayerMoney(ply:SteamID64())

    print(money)
end)

concommand.Add("money_set", function (ply, cmd, args)
    setPlayerMoney(ply:SteamID64(), 1000)
end)

initProstirMoney()