if SERVER then
    include("prsbox/mapvote/sv_vote.lua")

    AddCSLuaFile("prsbox/mapvote/cl_vote.lua")
    AddCSLuaFile("prsbox/mapvote/cl_blacklist.lua")
end

if CLIENT then
    include("prsbox/mapvote/cl_blacklist.lua")
    include("prsbox/mapvote/cl_vote.lua")
end