if( SERVER ) then 
    AddCSLuaFile("prsbox/stamina/cl_stamina.lua")
    include("prsbox/stamina/sv_stamina.lua")
elseif( CLIENT ) then
    include("prsbox/stamina/cl_stamina.lua")
end