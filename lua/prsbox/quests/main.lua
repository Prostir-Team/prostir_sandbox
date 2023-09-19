if( SERVER ) then
    include("prsbox/quests/sv_quests.lua")
    AddCSLuaFile("prsbox/quests/cl_quests.lua")
elseif( CLIENT ) then
    include("prsbox/quests/cl_quests.lua")
end