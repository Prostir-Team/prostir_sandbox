if SERVER then
    include("prsbox/!lobby/sv_lobby.lua")
    
    AddCSLuaFile("prsbox/!lobby/cl_lobby.lua")
end

if CLIENT then
    include("prsbox/!lobby/cl_lobby.lua")
end