if SERVER then
    include("prsbox/money/sv_money.lua")
    AddCSLuaFile("prsbox/money/cl_money.lua")
end

if CLIENT then
    include("prsbox/money/cl_money.lua")
end