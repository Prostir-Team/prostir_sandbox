util.AddNetworkString("PRSBOX.Net.SendPrices")
local PRICES = {}

local function getPrices()
    local f = file.Open("cfg/money/prices.cfg", "r", "GAME")
    local data = f:Read()
    local data_splited = string.Split(data, "\n")
    local out = {}

    for k, line in ipairs(data_splited) do
        if line == "" then continue end
        if line[1] == "#" then continue end

        local price = string.Split(line, "=")
        
        out[price[1]] = price[2]
    end

    return out
end

PRICES = getPrices()

hook.Add("PlayerInitialSpawn", "PRSBOX.Spawnmenu.Money.SendPrices", function (ply, tr)
    net.Start("PRSBOX.Net.SendPrices")
        net.WriteTable(PRICES)
    net.Send(ply)
end)

hook.Add("PlayerGiveSWEP", "PRSBOX.BuyWeapon", function(ply, class, info)
	if table.HasValue(table.GetKeys(PRICES), class) then
        local money = ply:GetMoney()
        local price = tonumber(PRICES[class])

        if money < price then
            return false 
        end

        ply:SubtractMoney(price)
    end

    return true
end)

concommand.Add("send_prices", function (ply)
    if not IsValid(ply) then return end

    print("ajdljasldjk as")

    net.Start("PRSBOX.Net.SendPrices")
        net.WriteTable(PRICES)
    net.Send(ply)
end)