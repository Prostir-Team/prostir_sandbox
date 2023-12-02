util.AddNetworkString("PRSBOX.Net.BuildMode")

local IsValid = IsValid
local PLAYERS_IN_BUILDMODE = {}

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

local GetCreator = ENTITY.GetCreator
local GetClass = ENTITY.GetClass

---
--- Local functions
---
local player_class = "player"

local function IsPlayer( ent )
    if ( not IsValid( ent ) ) then return false end
    return GetClass( ent ) == player_class
end

local function playerInBuildmode(ply)
    if not IsValid(ply) then return false end
    if not ply:IsValid() then return false end

    local steamid = ply:SteamID()

    -- TODO: викоритовувати хеш таблицю з обєктами гравців

    return table.HasValue(PLAYERS_IN_BUILDMODE, steamid)
end

local function enterBuildMode(ply)
    if ( not IsValid(ply) ) then return end
    --if not ply:IsValid() then return end --Викликає Entity:IsValid(), корисно лише при перевірці чи ця ентіті не worldspawn
    
    local steamid = ply:SteamID()

    if playerInBuildmode(ply) then return end

    ply:AddIcon("icon16/wrench.png")
    ply:GodEnable()

    table.insert(PLAYERS_IN_BUILDMODE, steamid)

    net.Start("PRSBOX.Net.BuildMode")
        net.WriteBool(true) -- State of build mode
    net.Send(ply)
end

local function enterPvpMode(ply)
    if not IsValid(ply) then return end
    if not ply:IsValid() then return end
    
    local steamid = ply:SteamID()

    if not playerInBuildmode(ply) then return end

    ply:RemoveIcon("icon16/wrench.png")
    ply:GodDisable()

    table.RemoveByValue(PLAYERS_IN_BUILDMODE, steamid) -- TODO: це робить цикл через всю таблицю, використовуйте хеш таблицю

    ply:KillSilent()
    ply:Spawn()

    net.Start("PRSBOX.Net.BuildMode") -- TODO: використовуйте біт операцї для передачі модів гравці ( афк, білд, тд )
        net.WriteBool(false) -- State of build mode
    net.Send(ply)
end

---
--- Player meta
---

function PLAYER:BuildMode()
    return playerInBuildmode(self)
end

function ENTITY:GetBuildMode()
    local r

    if IsPlayer( self ) then
        r = playerInBuildmode( self )
    else
        r = playerInBuildmode( GetCreator( self ) )
    end

    return r
end

---
--- hooks
---

hook.Add("EntityTakeDamage", "PRSBOX.Build.Damage", function (target, dmg)
    local attacker = dmg:GetAttacker()
    
    if ( IsValid( attacker ) and IsPlayer( attacker ) and attacker:BuildMode() ) then
        return true
    end -- TODO: що буде якщо демаг буде на проп/ентіті білдера

    if ( IsValid( target ) and IsPlayer( target ) and target:BuildMode() ) then
        return true
    end
end)

hook.Add("PlayerNoClip", "PRSBOX.Build.Noclip", function (ply, disabled)
    if ply:BuildMode() or not disabled then return true end
end)

hook.Add("PRSBOX.EnterBuildMode", "PRSBOX.Override.EnterBuildMode", enterBuildMode)
hook.Add("PRSBOX.EnterPvpMode", "PRSBOX.Override.EnterPvpMode", enterPvpMode)