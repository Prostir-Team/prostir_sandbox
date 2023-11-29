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

        local ply_sweps = ply:GetWeapons()

        for _, i in ipairs(ply_sweps) do
            if (i:GetClass() == class) then
                return false
            end
        end

        ply:SubtractMoney(price)
    end
end)

hook.Add("PlayerSpawnSWEP", "PRSBOX.BuyAmmo", function(ply, class, info)
    local ply_sweps = ply:GetWeapons()

    for _, i in ipairs(ply_sweps) do
        if (i:GetClass() == class) then
            local ammotype = i:GetPrimaryAmmoType()
            local magsize = i:GetMaxClip1() -- these are MAGS, not CLIPS!
            ply:GiveAmmo(magsize, ammotype)
            break
        end
    end

    return false
end)

hook.Add("PlayerSpawnSENT", "PRSBOX.BuyEntity", function(ply, class)
    if table.HasValue(table.GetKeys(PRICES), class) then
        local money = ply:GetMoney()
        local price = tonumber(PRICES[class])

        if (money < price) then
            return false
        end

        if IsClassInCooldown(ply, class) or IsCategoryInCooldown(ply, scripted_ents.GetStored( class ).t.Category) then
            return false
        end

        ply:SubtractMoney(price)
    end
end)

concommand.Add("send_prices", function (ply)
    if not IsValid(ply) then return end

    --print("ajdljasldjk as")

    net.Start("PRSBOX.Net.SendPrices")
        net.WriteTable(PRICES)
    net.Send(ply)
end)