if SERVER then
    AddCSLuaFile('prsbox/spawn_protect/cl_protect_hud.lua')
	include("prsbox/spawn_protect/sv_protect_give.lua")
else
	include("prsbox/spawn_protect/cl_protect_hud.lua")
end