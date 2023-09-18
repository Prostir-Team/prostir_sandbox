if SERVER then
    include("prsbox/avatar/sv_avatar.lua")
    AddCSLuaFile("prsbox/avatar/cl_avatar.lua")
end

if CLIENT then
    include("prsbox/avatar/cl_avatar.lua")
end