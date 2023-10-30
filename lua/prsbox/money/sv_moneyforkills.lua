local cfg = {}

cfg.defaultRewardMultiplier = 0.2

cfg.simpleKill = {}
cfg.simpleKill.minMoney = 60
cfg.simpleKill.maxMoney = 80

cfg.headshotKill = {}
cfg.headshotKill.minMoney = 110
cfg.headshotKill.maxMoney = 170

cfg.roadKill = {}
cfg.roadKill.minMoney = 60
cfg.roadKill.maxMoney = 100

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

    local victim_kd = victim:Frags() / victim:Deaths()
    print("Victim K/D:", victim_kd)
    if victim_kd == 0 then -- якщо у жертви нема вбивств, то урізати нагороду
        victim_kd = cfg.defaultRewardMultiplier
    end
    
    local reward_value = math.Rand(minMoneyValue, maxMoneyValue)
    print("Raw reward:", reward_value)

    local reward = math.Round(reward_value * victim_kd)
    print("Reward:", reward)
    
    attacker:AddMoney(reward)
end)