print("Hello World")

local PLAYERS_IN_BUILDMODE = {}

---
--- Local functions
---

local function playerInBuildmode(ply)
    if not IsValid(ply) then return false end
    if not ply:IsValid() then return false end

    local steamid = ply:SteamID()

    return table.HasValue(PLAYERS_IN_BUILDMODE, steamid)
end

local function enterBuildMode(ply)
    if not IsValid(ply) then return end
    if not ply:IsValid() then return end
    
    local steamid = ply:SteamID()

    if playerInBuildmode(ply) then return end

    ply:AddIcon("icon16/wrench.png")
    ply:GodEnable()

    table.insert(PLAYERS_IN_BUILDMODE, steamid)
end

local function enterPvpMode(ply)
    if not IsValid(ply) then return end
    if not ply:IsValid() then return end
    
    local steamid = ply:SteamID()

    if not playerInBuildmode(ply) then return end

    ply:RemoveIcon("icon16/wrench.png")
    ply:GodDisable()

    table.RemoveByValue(PLAYERS_IN_BUILDMODE, steamid)
end

---
--- Player meta
---

local PLAYER = FindMetaTable("Player")

function PLAYER:BuildMode()
    return playerInBuildmode(self)
end

---
--- hooks
---

hook.Add("EntityTakeDamage", "PRSBOX.Build.Damage", function (target, dmg)
    local attacker = dmg:GetAttacker()
    
    if (IsValid(attacker) and attacker:IsPlayer() and attacker:BuildMode()) then
        return true
    end

    if (IsValid(target) and target:IsPlayer() and target:BuildMode()) then
        return true
    end
end)

hook.Add("PlayerNoClip", "PRSBOX.Build.Noclip", function (ply, disabled)
    if ply:BuildMode() or not disabled then return true end
end)

hook.Add("PRSBOX.EnterBuildMode", "PRSBOX.Override.EnterBuildMode", enterBuildMode)
hook.Add("PRSBOX.EnterPvpMode", "PRSBOX.Override.EnterPvpMode", enterPvpMode)