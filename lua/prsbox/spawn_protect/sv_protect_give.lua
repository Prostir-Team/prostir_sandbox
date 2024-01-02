-- Once again, this code was written by Expression 2

CreateConVar(   "advsp_enabled", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Controls spawn protection, if it's enabled or not")
CreateConVar(   "advsp_time", "10", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Controls spawn protection, if it's enabled or not")
CreateConVar(   "advsp_revoke_on_weapon", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Revokes spawn protection when you change weapon to something other that is not friendly, pew pew")

local FriendlyWeapons = {"weapon_physgun","gmod_tool","gmod_camera","weapon_bugbait","weapon_fists"}


hook.Add( "PlayerSpawn", "ADVSP.shieldApply", function(ply)
    if not GetConVar("advsp_enabled"):GetBool() then return end

    local DefaultTime = GetConVar("advsp_time"):GetInt()

    ply:SetNWBool("SpawnProtected", true)
    ply:SetNWFloat("SpawnProtectionEndTime", CurTime() + DefaultTime)

    ply:EmitSound( "common/wpn_select.wav" )

    local timerName = "advsp_" .. ply:UserID()

    timer.Create(timerName, DefaultTime, 1, function()
        if IsValid(ply) and ply:GetNWBool( "SpawnProtected", false ) then
            ply:SetNWBool( "SpawnProtected", false )
            ply:EmitSound( "hl1/fvox/hiss.wav" )
        end
    end)

end)


hook.Add("PlayerSwitchWeapon", "ADVSP.ShieldRemoveWeapon", function(ply, prevWep, curWep)
    local Revoke = true
    for _, weapon in ipairs( FriendlyWeapons ) do
        if weapon == curWep:GetClass() then
            Revoke = false
        end
    end

    if Revoke and ply:GetNWBool( "SpawnProtected" ) and GetConVar("advsp_revoke_on_weapon"):GetBool() then
        ply:SetNWBool( "SpawnProtected", false )
        ply:EmitSound( "buttons/combine_button7.wav" )
        ply:SetNWFloat("SpawnProtectionEndTime", 0)
    end
end)

hook.Add("EntityTakeDamage", "ADVSP.DisableDamage", function(target, dmginfo)
    if target:GetNWBool( "SpawnProtected" ) or dmginfo:GetAttacker():GetNWBool( "SpawnProtected" ) then //  or not dmginfo:GetAttacker():IsWorld() and not dmginfo:GetAttacker():IsNPC()  and 
        dmginfo:SetDamage(0)
        target:EmitSound("resource/warning.wav")
        return true
    end
end)

hook.Add( "PlayerDeath", "ADVSP.ResetDeath", function(ply)
    ply:SetNWBool( "SpawnProtected", false )

    local timerName = "advsp_" .. ply:UserID()

    timer.Remove(timerName)
end)
