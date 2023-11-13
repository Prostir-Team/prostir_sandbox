-- локалізація функцій
local curTime = CurTime

local cfg = {}
cfg.maxUnderwaterTime = 10 -- скільки гравець може пожити під водою до того, як почне задихатись
cfg.damageInfoTime = 1 -- з яким інтервалом гравець отримує дамаг від задихання

-- скільки гравець отримує дамагу від задихання
cfg.minDamage = 2
cfg.maxDamage = 10

-- TODO: переписати даний булшіт
-- службові змінні
local dmgInfo = DamageInfo()
local underwater_time = 0
local was_underwater = false
local nextdrowndmg_time = 0

hook.Add("PlayerTick", "PRSBOX.Playerlimits.AirLimit", function(ply, mv)
    if (ply:WaterLevel() != 3 or !ply:Alive()) then
        was_underwater = false
        underwater_time = 0
        nextdrowndmg_time = 0
        dmgInfo = DamageInfo()
        return
    end

    if not was_underwater then
        underwater_time = curTime() + cfg.maxUnderwaterTime
        was_underwater = true
    end

    if (underwater_time <= curTime()) and (nextdrowndmg_time <= curTime() and ply:Alive()) then
        nextdrowndmg_time = curTime() + cfg.damageInfoTime
        dmgInfo:SetDamage(math.Round(math.Rand(cfg.minDamage, cfg.maxDamage)))
        dmgInfo:SetDamageType(DMG_DROWN)
        ply:TakeDamageInfo(dmgInfo)
        ply:ViewPunch(Angle(1, 0, 0))
    end
end)