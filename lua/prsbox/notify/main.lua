if SERVER then
    AddCSLuaFile("prsbox/notify/cl_notify.lua")
end

if CLIENT then
    include("prsbox/notify/cl_notify.lua")
end

if SERVER then
    util.AddNetworkString("PRSBOX.NotifySend")
    
    function MakeNotify(text, type, length)
        net.Start("PRSBOX.NotifySend")
            net.WriteString(text)
            net.WriteInt(type, 6)
            net.WriteInt(length, 10)
        net.Broadcast()
    end
end