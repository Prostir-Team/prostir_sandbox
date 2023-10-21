-- локалізація функцій
local curTime = CurTime

local cfg = {}
cfg.maxUnderwaterTime = 5 -- (max: 30, default: 5) скільки гравець може пожити під водою до того, як почне задихатись
cfg.damageInfo = DamageInfo()
cfg.damageInfoTime = 0.5 -- (default: 0.5) з яким інтервалом гравець отримує дамаг від задихання
cfg.damageInfo:SetDamage(2) -- (default: 2) скільки гравець отримує дамагу від задихання
cfg.damageInfo:SetDamageType(DMG_DROWN)

-- службові змінні
local underwater_time = 0
local was_underwater = false
local nextdrowndmg_time = 0

util.AddNetworkString("PlayerPreSuffocationMsg")

hook.Add("PlayerTick", "PRSBOX.Underwater.AirLimit", function(ply, mv)
    if (ply:WaterLevel() != 3) then
        was_underwater = false
        underwater_time = 0
        nextdrowndmg_time = 0
        return
    end

    if not was_underwater then
        underwater_time = curTime() + cfg.maxUnderwaterTime
        was_underwater = true
        net.Start("PlayerPreSuffocationMsg")
        net.WriteUInt(cfg.maxUnderwaterTime, 5)
        net.Send(ply)
    end

    if (underwater_time <= curTime()) and (nextdrowndmg_time <= curTime() and ply:Alive()) then
        nextdrowndmg_time = curTime() + cfg.damageInfoTime
        ply:TakeDamageInfo(cfg.damageInfo)
        ply:ViewPunch(Angle(1, 0, 0))
    end
end)