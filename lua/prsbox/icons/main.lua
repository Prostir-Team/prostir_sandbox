if SERVER then
    include("prsbox/icons/sv_icons.lua") 
    AddCSLuaFile("prsbox/icons/cl_icons.lua")
end

if CLIENT then
    include("prsbox/icons/cl_icons.lua")
end