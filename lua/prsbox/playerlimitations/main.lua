if SERVER then
    AddCSLuaFile("prsbox/playerlimitations/cl_sprintlimit.lua")
    include("prsbox/playerlimitations/sv_airlimit.lua")
    include("prsbox/playerlimitations/sv_sprintlimit.lua")
else
    include("prsbox/playerlimitations/cl_sprintlimit.lua")
end