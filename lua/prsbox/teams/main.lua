if SERVER then
    include("prsbox/teams/sv_teams.lua")

    AddCSLuaFile("prsbox/teams/cl_teams.lua")
end

if CLIENT then
    include("prsbox/teams/cl_teams.lua")
end