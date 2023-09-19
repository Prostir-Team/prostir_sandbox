if( SERVER ) then 
    include("prsbox/hud/server/sv_hud.lua")
    AddCSLuaFile("prsbox/hud/client/cl_hud_config.lua")
    AddCSLuaFile("prsbox/hud/client/cl_hud.lua")
    AddCSLuaFile("prsbox/hud/client/cl_hud_elements.lua")
elseif( CLIENT ) then
    include("prsbox/hud/client/cl_hud_config.lua")
    include("prsbox/hud/client/cl_hud.lua")
    include("prsbox/hud/client/cl_hud_elements.lua")
end