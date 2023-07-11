util.AddNetworkString("PRSBOX.Module.Send")
util.AddNetworkString("PRSBOX.Module.ReverseStatus")

concommand.Add("prsbox_module_menu_open", function (ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end

    local modules = getAllModules()

    net.Start("PRSBOX.Module.Send")
        net.WriteTable(modules)
    net.Send(ply)
end)

net.Receive("PRSBOX.Module.ReverseStatus", function (len, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local name = net.ReadString()

    reverseModuleState(name)
end)