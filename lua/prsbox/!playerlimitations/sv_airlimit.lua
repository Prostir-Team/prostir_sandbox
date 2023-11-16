-- локалізація функцій
local curTime = CurTime

local cfg = {}
cfg.airLimitValue = 50 -- максимальний рівень "повітряної стаміни"
cfg.damageInfoTime = 1 -- тікрейт системи дихання

cfg.underwaterPenalty = 2 -- скільки стаміни знімається під водою
cfg.regenValue = 4 -- скільки стаміни відновлюється не у воді

-- скільки гравець отримує дамагу від задихання
cfg.minDamage = 2
cfg.maxDamage = 10

-- util.AddNetworkString("PRSBOX.Net.AirlimitSend")

do
    local ply_meta = FindMetaTable("Player")

    function ply_meta:GetBreathingAmount()
        return self.breathingAmount
    end

    function ply_meta:SetBreathingAmount(newValue)
        self.breathingAmount = math.Clamp(newValue, 0, cfg.airLimitValue)
        -- net.Start("PRSBOX.Net.AirlimitSend", true)
        -- net.WriteUInt(self.breathingAmount, 8)
        -- net.Send(self)
        self:SetNWInt("prsbox.air_stamina", self.breathingAmount)
    end
    
    function ply_meta:GetBreathingTick()
        return self.breathingTick
    end

    function ply_meta:SetBreathingTick(breathingTickValue)
        self.breathingTick = curTime() + breathingTickValue
    end

    function ply_meta:SetupBreathingSystem()
        self:SetBreathingAmount(cfg.airLimitValue)
        self:SetBreathingTick(cfg.damageInfoTime)
        self:SetNWInt("prsbox.air_stamina_max", cfg.airLimitValue)
    end
end

hook.Add("PlayerSpawn", "PRSBOX.Playerlimits.AirLimit", function(ply, tr)
    ply:SetupBreathingSystem()
end)

hook.Add("PlayerTick", "PRSBOX.Playerlimits.AirLimit", function(ply, mv)
    if !ply:Alive() then return end

    local ply_air = ply:GetBreathingAmount()

    if (ply:GetBreathingTick() >= curTime()) then return end
    ply:SetBreathingTick(cfg.damageInfoTime)

    if (ply_air <= 0) then
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(math.Round(math.Rand(cfg.minDamage, cfg.maxDamage)))
        dmgInfo:SetDamageType(DMG_DROWN)
        ply:TakeDamageInfo(dmgInfo)
        ply:ViewPunch(Angle(1, 0, 0))
    end

    if (ply:WaterLevel() == 3) then
        ply:SetBreathingAmount(ply_air - cfg.underwaterPenalty)
        return
    end

    ply:SetBreathingAmount(ply_air + cfg.underwaterPenalty)
end)

-- hook.Add("PlayerTick", "PRSBOX.Playerlimits.AirLimit", function(ply, mv)
--     if (ply:WaterLevel() != 3 or !ply:Alive()) then
--         was_underwater = false
--         underwater_time = 0
--         nextdrowndmg_time = 0
--         dmgInfo = DamageInfo()
--         return
--     end

--     if not was_underwater then
--         underwater_time = curTime() + cfg.maxUnderwaterTime
--         was_underwater = true
--     end

--     if (underwater_time <= curTime()) and (nextdrowndmg_time <= curTime() and ply:Alive()) then
--         nextdrowndmg_time = curTime() + cfg.damageInfoTime
--         dmgInfo:SetDamage(math.Round(math.Rand(cfg.minDamage, cfg.maxDamage)))
--         dmgInfo:SetDamageType(DMG_DROWN)
--         ply:TakeDamageInfo(dmgInfo)
--         ply:ViewPunch(Angle(1, 0, 0))
--     end
-- end)