if SERVER then
    AddCSLuaFile("prsbox/infopanel/cl_infopanel.lua")
    AddCSLuaFile("prsbox/infopanel/cl_docstyles.lua")
end

if CLIENT then
    include("prsbox/infopanel/cl_docstyles.lua")
    include("prsbox/infopanel/cl_infopanel.lua")
end