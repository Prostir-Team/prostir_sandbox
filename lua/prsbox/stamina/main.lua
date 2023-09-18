if( SERVER ) then 
    AddCSLuaFile("prsbox/stamina/sv_stamina.lua")
    AddCSLuaFile("prsbox/stamina/cl_stamina.lua")
elseif( CLIENT ) then
    include("prsbox/stamina/sv_stamina.lua")
    include("prsbox/stamina/cl_stamina.lua")
end