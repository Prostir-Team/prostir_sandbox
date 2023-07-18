-- ToDo
-- 1. Menu

net.Receive("PRSBOX.Module.Send", function (len, ply)
    local modules = net.ReadTable()
    
    local panel = vgui.Create("DFrame")
    panel:SetSize(800, 600)
    panel:Center()
    panel:MakePopup()

    for k, m in ipairs(modules) do
        if m[1] == "" then return end
        
        local button = vgui.Create("DButton", panel)
        local moduleName = m[1]

        
        button:Dock(TOP)
        button.State = m[2]
        button:SetText(moduleName .. " = " .. button.State)

        button.DoClick = function ()
            net.Start("PRSBOX.Module.ReverseStatus")
                net.WriteString(moduleName)
            net.SendToServer()
            
            button.State = bool_to_number(not tobool(button.State))

            button:SetText(moduleName .. " = " .. button.State)

            chat.AddText(Color(103 , 253, 103), moduleName, Color(255, 255, 255), " has been", tobool(button.State) and Color(103 , 253, 103) or Color(255, 82, 82), tobool(button.State) and " enabled." or " disabled.")
        end
    end
end)