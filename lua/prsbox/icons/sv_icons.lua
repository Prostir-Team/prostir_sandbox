util.AddNetworkString("PRSBOX.Icons")

local PLAYER = FindMetaTable("Player")

function PLAYER:AddIcon(iconPath)    
    net.Start("PRSBOX.Icons")
        net.WriteString(self:SteamID()) -- Steam id
        net.WriteString(iconPath) -- icon
        net.WriteBool(true) -- Add an icon or remove it
    net.Broadcast()
end

function PLAYER:RemoveIcon(iconPath)
    net.Start("PRSBOX.Icons")
        net.WriteString(self:SteamID()) -- Steam id
        net.WriteString(iconPath) -- icon
        net.WriteBool(false) -- Add an icon or remove it
    net.Broadcast()
end