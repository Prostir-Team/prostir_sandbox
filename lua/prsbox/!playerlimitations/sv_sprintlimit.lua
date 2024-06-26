-- локалізація функцій
local curTime = CurTime

local cfg = {}
cfg.maxStamina = 300 -- максимальний рівень стаміни у гравця
cfg.drainTime = 0.15 -- по суті тікрейт стаміни, в секундах
cfg.slowdownLvl = 25 -- на якому рівні стаміни гравець почне сповільнюватись

cfg.regenValue = 4 -- скільки повинно відновлюватись стаміни за інтервал
cfg.sprintPenalty = 2 -- скільки повинно знімати стаміни за інтервал.
cfg.jumpPenalty = 20 -- скільки повинно знімати за стрибок

-- util.AddNetworkString("PRSBOX.Net.StaminaSend")

do
    local ply_meta = FindMetaTable("Player")

    function ply_meta:GetStamina()
        return self.stamina
    end

    function ply_meta:SetStamina(newStamina)
        self.stamina = math.Clamp(newStamina, 0, cfg.maxStamina)
        -- net.Start("PRSBOX.Net.StaminaSend", true)
        -- net.WriteUInt(self.stamina, 8)
        -- net.Send(self)
        self:SetNWInt("prsbox.sprint_stamina", self.stamina)
    end
    
    function ply_meta:GetStaminaTick()
        return self.staminaTick
    end

    function ply_meta:SetStaminaTick(staminaTickValue)
        self.staminaTick = curTime() + staminaTickValue
    end

    function ply_meta:GetMaxRunSpeed()
        return self.maxRunSpeed
    end

    function ply_meta:SetMaxRunSpeed()
        self.maxRunSpeed = self:GetRunSpeed()
    end

    function ply_meta:SetupStaminaSystem()
        self:SetStamina(cfg.maxStamina)
        self:SetStaminaTick(cfg.drainTime)
        self:SetMaxRunSpeed()
        self:SetNWInt("prsbox.sprint_stamina_max", cfg.maxStamina)
    end
end


hook.Add("PlayerSpawn", "PRSBOX.Playerlimits.Stamina", function(ply, tr)
    ply:SetupStaminaSystem()
end)

hook.Add("PlayerTick", "PRSBOX.Playerlimits.Stamina", function(ply, mv)
    if !ply:Alive() then return end

    local ply_stamina = ply:GetStamina()

    if not (ply:GetStaminaTick() <= curTime()) then return end
    ply:SetStaminaTick(cfg.drainTime)

    local regenMult = 1
    local vel = mv:GetVelocity()
    if (vel.x == 0 and vel.y == 0) then
        regenMult = 2
    end

    if (ply_stamina <= cfg.slowdownLvl) then
        ply:SetRunSpeed(math.Clamp(ply:GetRunSpeed() - 5, ply:GetWalkSpeed(), ply:GetMaxRunSpeed()))
        ply:SetJumpPower(math.Clamp(ply:GetJumpPower() - 5, ply:GetMaxJumpPower()*.5, ply:GetMaxJumpPower()))
    else
        ply:SetRunSpeed(math.Clamp(ply:GetRunSpeed() + 5, ply:GetWalkSpeed(), ply:GetMaxRunSpeed()))
        ply:SetJumpPower(math.Clamp(ply:GetJumpPower() + 5, ply:GetMaxJumpPower()*.5, ply:GetMaxJumpPower()))
    end
    
    if (ply:IsSprinting() and (vel.x ~= 0 or vel.y ~= 0)) then
        ply:SetStamina(ply:GetStamina() - cfg.sprintPenalty)
    else
        ply:SetStamina(ply:GetStamina() + cfg.regenValue * regenMult)
    end
end)

hook.Add("OnPlayerJump", "PRSBOX.Playerlimits.Stamina", function(ply, spd)
    ply:SetStamina(ply:GetStamina() - cfg.jumpPenalty)
end)