if SERVER then
    include("prsbox/!lobby/sv_lobby.lua")
    
    AddCSLuaFile("prsbox/!lobby/cl_enums.lua")
    AddCSLuaFile("prsbox/!lobby/cl_lobby.lua")
    AddCSLuaFile("prsbox/!lobby/elements/cl_tabmenu.lua")
    AddCSLuaFile("prsbox/!lobby/elements/cl_button.lua")
    AddCSLuaFile("prsbox/!lobby/elements/cl_checkbox.lua")
    AddCSLuaFile("prsbox/!lobby/elements/cl_window.lua")
end

if CLIENT then
    include("prsbox/!lobby/cl_enums.lua")
    include("prsbox/!lobby/cl_lobby.lua")
    include("prsbox/!lobby/elements/cl_button.lua")
    include("prsbox/!lobby/elements/cl_tabmenu.lua")
    include("prsbox/!lobby/elements/cl_checkbox.lua")
    include("prsbox/!lobby/elements/cl_window.lua")
end

local PLAYER = FindMetaTable("Player")

if SERVER then
    function PLAYER:StartLobby()
        self:Freeze(true)
        self:SetActiveWeapon(NULL)
        self:GodEnable()
        net.Start("PRSBOX.Lobby.StartMenu")
        net.Send(self)
    end

    function PLAYER:EndLobby()
        self:Freeze(false)
        self:GodDisable()
    end

    function PLAYER:OpenWindow(windowName, windowTitle, closeButton, wide, tall, open, data)
        net.Start("PRSBOX.Lobby.OpenWindow")
            net.WriteString(windowName)
            net.WriteString(windowTitle)
            net.WriteBool(closeButton or true)
            net.WriteInt(wide or 200, 11)
            net.WriteInt(tall or 100, 11)
            net.WriteBool(open or false)
            net.WriteTable(data or {})
        net.Send(self)
    end
    
    function PLAYER:CloseWindow(windowName)
        net.Start("PRSBOX.Lobby.CloseWindow")
            net.WriteString(windowName)
        net.Send(self)
    end

    function CloseWindow(windowName)
        net.Start("PRSBOX.Lobby.CloseWindow")
            net.WriteString(windowName)
        net.Broadcast()
    end

    function OpenWindow(windowName, windowTitle, closeButton, wide, tall, open, data)
        net.Start("PRSBOX.Lobby.OpenWindow")
            net.WriteString(windowName)
            net.WriteString(windowTitle)
            net.WriteBool(closeButton)
            net.WriteInt(wide or 200, 11)
            net.WriteInt(tall or 100, 11)
            net.WriteBool(open or false)
            net.WriteTable(data or {})
        net.Broadcast()
    end
end