if SERVER then
    AddCSLuaFile("prsbox/scoreboard/cl_scoreboard.lua")
end

if CLIENT then
    include("prsbox/scoreboard/cl_scoreboard.lua")
end