local cfg = {}

-- мінімальне та максимальне значення к/д як множителя
cfg.rewardMultiplier = {}
cfg.rewardMultiplier.min = 0.5
cfg.rewardMultiplier.max = 3.0

cfg.simpleKill = {}
cfg.simpleKill.minMoney = 60
cfg.simpleKill.maxMoney = 80

cfg.headshotKill = {}
cfg.headshotKill.minMoney = 110
cfg.headshotKill.maxMoney = 170

cfg.roadKill = {}
cfg.roadKill.minMoney = 30
cfg.roadKill.maxMoney = 60


local function calculateKD(kills, deaths)
    if (kills <= 0) then
        return cfg.rewardMultiplier.min
    end

    if (deaths <= 0) then -- якщо жертва ще не вмирала, ділити вбивства на 1
        return math.Clamp(kills / 1, cfg.rewardMultiplier.min, cfg.rewardMultiplier.max)
    end

    return math.Clamp(kills / deaths, cfg.rewardMultiplier.min, cfg.rewardMultiplier.max)
end


local function checkWeapon(player)

    local weaponsToCheck = {
        ["weapon_physgun"] = true,
        ["gmod_tool"] = true,
        ["gmod_camera"] = true,
        ["weapon_physcannon"] = true,
        ["weapon_fists"] = true
    }

    for _, weapon in pairs( player:GetWeapons() ) do
            local weaponClass = weapon:GetClass()

            if not weaponsToCheck[weaponClass] then
                return true
            end
    end
    return false
end

hook.Add("PlayerDeath", "PRSBOX.MoneyForKill", function(victim, inflictor, attacker)
    if (attacker == victim) then return end
    if not (attacker:IsPlayer()) then return end
    if not (victim:IsPlayer()) then return end
    if not (inflictor:IsValid()) then return end
    print(victim:GetClass(), inflictor:GetClass(), attacker:GetClass())
    local minMoneyValue = cfg.simpleKill.minMoney
    local maxMoneyValue = cfg.simpleKill.maxMoney

   -- print( checkWeapon(victim) )
    if checkWeapon(victim) then

        if ( victim:LastHitGroup() == HITGROUP_HEAD ) then
            print(attacker:GetName(), "got a headshot reward!")
            minMoneyValue = cfg.headshotKill.minMoney
            maxMoneyValue = cfg.headshotKill.maxMoney
        elseif ( string.find(inflictor:GetClass(), "lvs_wheeldrive", 1, true) ) then
            print(attacker:GetName(), "got a roadkill reward!")
            minMoneyValue = cfg.roadKill.minMoney
            maxMoneyValue = cfg.roadKill.maxMoney
        end

        local victim_kd = calculateKD(victim:Frags(), victim:Deaths())
        print("Victim K/D:", victim_kd)

        local reward_value = math.Rand(minMoneyValue, maxMoneyValue)
        print("Raw reward:", reward_value)

        local reward = math.Round(reward_value * victim_kd)
        print("Reward:", reward)

        attacker:AddMoney(reward)

    else print( attacker:Name().." kill unarmed player!" )
    
    end
    
end)
