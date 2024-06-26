if SERVER then
    -- Money main files
    
    include("prsbox/money/sv_money.lua")
    AddCSLuaFile("prsbox/money/cl_money.lua")

    AddCSLuaFile("prsbox/money/cl_money_menu.lua")

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
        local result = ( money - quantity )

        if result >= 0 then
            self:SetMoney(money - quantity)
        else self:SetMoney(0)
        end
    end
end

if CLIENT then
    include("prsbox/money/cl_money_menu.lua")
end