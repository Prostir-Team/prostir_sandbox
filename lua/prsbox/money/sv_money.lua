util.AddNetworkString("PRSBOX.Net.OnMoneyGet")

local DIR_MONEY = "prostir_money/"

local function initProstirMoney()
    if not file.Exists(DIR_MONEY, "DATA") then
        file.CreateDir(DIR_MONEY)
    end
end

local function updateClientMoney(steamid, quantity)
    local ply = player.GetBySteamID64(steamid)
    if not IsValid(ply) then return end

    net.Start("PRSBOX.Net.OnMoneyGet")
        net.WriteInt(quantity, 21) -- Player money
    net.Send(ply)
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

function getPlayerMoney(steamid)
    if not playerMoneyExist(steamid) then
        createPlayerMoney(steamid)
    end

    local money = file.Read(formatPlayerMoney(steamid), "DATA")

    return tonumber(money)
end

function setPlayerMoney(steamid, quantity)
    if not playerMoneyExist(steamid) then
        createPlayerMoney(steamid)
    end

    file.Write(formatPlayerMoney(steamid), tostring(quantity))

    updateClientMoney(steamid, quantity)
end

hook.Add("PlayerInitialSpawn", "PRSBOX.UpdateMoney", function (ply)
    local steamid = ply:SteamID64()
    
    updateClientMoney(steamid, getPlayerMoney(steamid))
end)

initProstirMoney()