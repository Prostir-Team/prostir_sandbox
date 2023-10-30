local cfg = {}

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

    local reward = math.Round(math.Rand(minMoneyValue, maxMoneyValue))
    print("Reward:", reward)
    
    attacker:AddMoney(reward)
end)