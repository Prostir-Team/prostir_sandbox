if SERVER then
    AddCSLuaFile("prsbox/settings/cl_settingsmenu.lua")
end

if CLIENT then
    include("prsbox/settings/cl_settingsmenu.lua")
end