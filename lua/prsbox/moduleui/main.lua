if SERVER then
    include("prsbox/moduleui/sv_menu.lua")
    AddCSLuaFile("prsbox/moduleui/cl_menu.lua")
end

if CLIENT then
    include("prsbox/moduleui/cl_menu.lua")
end