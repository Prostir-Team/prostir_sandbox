if SERVER then
    AddCSLuaFile("prsbox/notify/cl_notify.lua")
end

if CLIENT then
    include("prsbox/notify/cl_notify.lua")
end