if SERVER then
    AddCSLuaFile("prsbox/!chat/chat.lua")
    AddCSLuaFile("prsbox/!chat/cl_chatfilter.lua")
    include("prsbox/!chat/sv_chatfilter.lua")
end

if CLIENT then
    include("prsbox/!chat/chat.lua")
    include("prsbox/!chat/cl_chatfilter.lua")
end