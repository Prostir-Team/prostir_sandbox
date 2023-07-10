if SERVER then
    AddCSLuaFile("prsbox/moduleui/cl_menu.lua")
end

if CLIENT then
    include("prsbox/moduleui/cl_menu.lua")
end