if SERVER then
    include("prsbox/rashisttest/sv_rashist.lua")
    
    AddCSLuaFile("prsbox/rashisttest/cl_rashist.lua")
end

if CLIENT then
    include("prsbox/rashisttest/cl_rashist.lua")
end