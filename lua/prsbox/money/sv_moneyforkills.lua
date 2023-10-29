local cfg = {}
cfg.simpleKill = {}
cfg.simpleKill.minMoney = 60
cfg.simpleKill.maxMoney = 80
cfg.headshotKill = {}
cfg.headshotKill.minMoney = 110
cfg.headshotKill.maxMoney = 170

hook.Add("PlayerDeath", "PRSBOX.MoneyForKill", function(victim, inflictor, attacker)
    if victim:LastHitGroup(HITGROUP_HEAD) then
        attacker:AddMoney(math.Round(math.Rand(cfg.headshotKill.minMoney, cfg.headshotKill.maxMoney)))
        return
    end

    attacker:AddMoney(math.Round(math.Rand(cfg.simpleKill.minMoney, cfg.simpleKill.maxMoney)))
end)