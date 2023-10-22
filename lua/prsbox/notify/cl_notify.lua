Notifications = Notifications or {}

do
    local PANEL = {}

    function PANEL:Init()
        
    end

    function PANEL:SetNotify(text, type, length)
        self.Text = text
        self.Type = type
        self.Length = length
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(Color(255, 0, 0))
        surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Notify", PANEL, "EditablePanel")
end

for k, notify in ipairs(Notifications) do
    if IsValid(notify) then
        notify:Remove()
    end
end

function notification.AddLegacy(text, type, length)
    print("Text " .. text)
    print("Type " .. type)
    print("Length " .. length)
end


concommand.Add("test_notify", function (ply, cmd, args)
    notification.AddLegacy("Test notification", NOTIFY_GENERIC, 10)
end)