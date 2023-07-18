if SERVER then
    include("prsbox/!lobby/sv_lobby.lua")
    
    AddCSLuaFile("prsbox/!lobby/cl_enums.lua")
    AddCSLuaFile("prsbox/!lobby/cl_lobby.lua")
    AddCSLuaFile("prsbox/!lobby/elements/cl_button.lua")
end

if CLIENT then
    include("prsbox/!lobby/cl_enums.lua")
    include("prsbox/!lobby/cl_lobby.lua")
    include("prsbox/!lobby/elements/cl_button.lua")
end