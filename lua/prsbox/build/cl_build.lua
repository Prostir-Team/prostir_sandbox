print("hello world")



net.Receive("PRSBOX.Net.BuildMode", function(len, ply)
    local state = net.ReadBool()

    if state then
        hook.Add("PRSBOX.HUD.HealthString", "PRSBOX.Build.String", function ()
            return "∞ "
        end)

        hook.Add("PRSBOX.HUD.HealthColor", "PRSBOX.Build.Color", function ()
            return Color(98, 192, 255)
        end)
    else 
        hook.Remove("PRSBOX.HUD.HealthString", "PRSBOX.Build.String")
        hook.Remove("PRSBOX.HUD.HealthColor", "PRSBOX.Build.Color")
    end
end)