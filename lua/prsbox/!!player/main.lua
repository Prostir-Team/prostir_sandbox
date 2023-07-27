if SERVER then
    include("prsbox/!!player/sv_player.lua")
    include("prsbox/!!player/sh_player.lua")
    
    AddCSLuaFile("prsbox/!!player/cl_player.lua")
    AddCSLuaFile("prsbox/!!player/sh_player.lua")
end

if CLIENT then
    include("prsbox/!!player/cl_player.lua")
    include("prsbox/!!player/sh_player.lua")
end