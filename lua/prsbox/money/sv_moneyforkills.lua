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
cfg.roadKill.minMoney = 60
cfg.roadKill.maxMoney = 100

local function calculateKD(kills, deaths)
    if (kills <= 0) then
        return cfg.rewardMultiplier.min
    end

    if (deaths <= 0) then -- якщо жертва ще не вмирала, ділити вбивства на 1
        return math.Clamp(kills / 1, cfg.rewardMultiplier.min, cfg.rewardMultiplier.max)
    end

    return math.Clamp(kills / deaths, cfg.rewardMultiplier.min, cfg.rewardMultiplier.max)
end

hook.Add("PlayerDeath", "PRSBOX.MoneyForKill", function(victim, inflictor, attacker)
    if (attacker == victim) then return end
    if not (attacker:IsPlayer() or victim:IsPlayer() or inflictor:IsValid()) then return end
    print(victim:GetClass(), inflictor:GetClass(), attacker:GetClass())
    local minMoneyValue = cfg.simpleKill.minMoney
    local maxMoneyValue = cfg.simpleKill.maxMoney
    
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
end)