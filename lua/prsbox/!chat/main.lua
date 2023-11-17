if SERVER then
    AddCSLuaFile("prsbox/!chat/chat.lua")
end

if CLIENT then
    include("prsbox/!chat/chat.lua")
end