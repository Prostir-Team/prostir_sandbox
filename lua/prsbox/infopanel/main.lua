-- local infopanel_docs = {
--     "main",
--     "rules"
-- }

if SERVER then
    -- for _, doc in ipairs(infopanel_docs) do
    --     resource.AddSingleFile("data/infopanel_docs/" .. doc .. ".md")
    -- end
    AddCSLuaFile("prsbox/infopanel/cl_infopanel.lua")
    AddCSLuaFile("prsbox/infopanel/cl_docstyles.lua")
    include("prsbox/infopanel/sv_infopanel.lua")
end

if CLIENT then
    include("prsbox/infopanel/cl_docstyles.lua")
    include("prsbox/infopanel/cl_infopanel.lua")
end