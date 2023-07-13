if SERVER then
    AddCSLuaFile("prsbox/!!!utils/cl_utils.lua")
end

if CLIENT then
    include("prsbox/!!!utils/cl_utils.lua")
end