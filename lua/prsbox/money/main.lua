if SERVER then
    -- Money main files
    
    include("prsbox/money/sv_money.lua")
    AddCSLuaFile("prsbox/money/cl_money.lua")

    -- Connect money to spawn menu

    include("prsbox/money/sv_spawnmenu.lua")
    AddCSLuaFile("prsbox/money/cl_spawnmenu.lua")

    include("prsbox/money/sv_moneyforkills.lua")
end

if CLIENT then
    include("prsbox/money/cl_money.lua")
    
    include("prsbox/money/cl_spawnmenu.lua")
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMoney()
    if CLIENT then
        return getLocalPlayerMoney()
    end
    
    if SERVER then
        local money = getPlayerMoney(self:SteamID64())
        return money
    end
end

if SERVER then
    function PLAYER:SetMoney(quantity)
        local steamid = self:SteamID64()
        
        setPlayerMoney(steamid, quantity)
    end

    function PLAYER:AddMoney(quantity)
        local money = self:GetMoney()
        
        self:SetMoney(money + quantity)
    end

    function PLAYER:SubtractMoney(quantity)
        local money = self:GetMoney()

        self:SetMoney(money - quantity)
    end

    concommand.Add("money_add", function (ply, cmd, args)
        if not IsValid(ply) then return end

        local money = args[1]

        ply:AddMoney(money)
    end)
end