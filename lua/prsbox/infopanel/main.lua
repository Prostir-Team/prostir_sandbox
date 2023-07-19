if SERVER then
    AddCSLuaFile("prsbox/infopanel/cl_infopanel.lua")
end

if CLIENT then
    include("prsbox/infopanel/cl_infopanel.lua")
end