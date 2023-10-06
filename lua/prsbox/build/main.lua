if SERVER then
    include("prsbox/build/sv_build.lua")

    AddCSLuaFile("prsbox/build/cl_build.lua")
end

if CLIENT then
    include("prsbox/build/cl_build.lua")
end