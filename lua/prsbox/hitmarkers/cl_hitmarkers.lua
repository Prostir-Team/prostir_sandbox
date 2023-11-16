util.PrecacheSound("prsbox/hitmarker.mp3")
local hitcolor = Color(255, 255, 255, 0)
local speed = 800

-- cl convars
local cvarbl = CreateConVar("prsbox_hitmarkers", "0", FCVAR_ARCHIVE, "Enable hitmarkers?", 0, 1)
local scalecvar = CreateConVar("prsbox_hitmarkers_scale", "1", FCVAR_ARCHIVE, "Hitmarker scale", 1, 16)
local farpointcvar = CreateConVar("prsbox_hitmarkers_farpoint", "8", FCVAR_ARCHIVE, "Element far point", 1, 64)
local closepointcvar = CreateConVar("prsbox_hitmarkers_closepoint", "2", FCVAR_ARCHIVE, "Element close point", 1, 64)
local thicknesscvar = CreateConVar("prsbox_hitmarkers_thickness", "2", FCVAR_ARCHIVE, "Element thickness", 1, 8)

local cx, cy = ScrW() * .5, ScrH() * .5 -- center x, center y
local scale = scalecvar:GetFloat()
local farp, closep, th = math.max(farpointcvar:GetFloat()), math.max(closepointcvar:GetFloat()), math.max(thicknesscvar:GetFloat()) -- far point, close point, thickness

local hitmarkerVertices = {}

-- fucking vertex tables kys
local function rebuildHitmarker()
    hitmarkerVertices[1] = {
        {x = cx - farp * scale, y = cy - farp * scale},
        {x = cx - (farp - th) * scale, y = cy - farp * scale},
        {x = cx - closep * scale, y = cy - (closep + th) * scale},
        {x = cx - closep * scale, y = cy - closep * scale},
        {x = cx - (closep + th) * scale, y = cy - closep * scale},
        {x = cx - farp * scale, y = cy - (farp - th) * scale},
    }
    hitmarkerVertices[2] = {
        {x = cx + farp * scale, y = cy - farp * scale},
        {x = cx + farp * scale, y = cy - (farp - th) * scale},
        {x = cx + (closep + th) * scale, y = cy - closep * scale},
        {x = cx + closep * scale, y = cy - closep * scale},
        {x = cx + closep * scale, y = cy - (closep + th) * scale},
        {x = cx + (farp - th) * scale, y = cy - farp * scale},
    }
    hitmarkerVertices[3] = {
        {x = cx + farp * scale, y = cy + farp * scale},
        {x = cx + (farp - th) * scale, y = cy + farp * scale},
        {x = cx + closep * scale, y = cy + (closep + th) * scale},
        {x = cx + closep * scale, y = cy + closep * scale},
        {x = cx + (closep + th) * scale, y = cy + closep * scale},
        {x = cx + farp * scale, y = cy + (farp - th) * scale},
    }
    hitmarkerVertices[4] = {
        {x = cx - farp * scale, y = cy + farp * scale},
        {x = cx - farp * scale, y = cy + (farp - th) * scale},
        {x = cx - (closep + th) * scale, y = cy + closep * scale},
        {x = cx - closep * scale, y = cy + closep * scale},
        {x = cx - closep * scale, y = cy + (closep + th) * scale},
        {x = cx - (farp - th) * scale, y = cy + farp * scale},
    }
end
rebuildHitmarker()

hook.Add( "OnScreenSizeChanged", "PRSBOX.Hitmarkers.SCR", function()
    cx, cy = ScrW() * .5, ScrH() * .5
end)

local function DrawHitMarkers()
    if hitcolor.a > 0 then
        hitcolor.a = math.max(hitcolor.a - (FrameTime() * speed),0)
        surface.SetDrawColor(hitcolor)
        draw.NoTexture()
        -- for _, group in ipairs(hitmarkerVertices) do
        --     for _, poly in ipairs(group) do
        --         surface.DrawPoly(poly)
        --     end
        -- end
        for _, group in ipairs(hitmarkerVertices) do
            surface.DrawPoly(group)
        end
        return
    end
    hook.Remove("HUDPaint", "PRSBOX.Hitmarkers.ClientDraw")
end

local HitMEnabled = cvarbl:GetBool()

local function NetReceived()
    if !HitMEnabled then return end
    local hitmarkerType = net.ReadUInt(2)
    hitcolor.r = 255
    hitcolor.g = 255
    hitcolor.b = 255
    if (hitmarkerType == 1) then
        hitcolor.g = 40
        hitcolor.b = 40
    elseif (hitmarkerType == 2) then
        hitcolor.r = 40
        hitcolor.b = 40
    end
    hitcolor.a = 255
    hook.Add( "HUDPaint", "PRSBOX.Hitmarkers.ClientDraw", DrawHitMarkers )
    surface.PlaySound("prsbox/hitmarker.mp3")
end

cvars.AddChangeCallback("prsbox_hitmarkers", function(convar_name, value_old, value_new)
    HitMEnabled = tobool(value_new)
end)

cvars.AddChangeCallback("prsbox_hitmarkers_scale", function(convar_name, value_old, value_new)
    scale = tonumber(value_new)
    rebuildHitmarker()
end)

cvars.AddChangeCallback("prsbox_hitmarkers_farpoint", function(convar_name, value_old, value_new)
    farp = math.max(tonumber(value_new))
    rebuildHitmarker()
end)

cvars.AddChangeCallback("prsbox_hitmarkers_closepoint", function(convar_name, value_old, value_new)
    closep = math.max(tonumber(value_new))
    rebuildHitmarker()
end)

cvars.AddChangeCallback("prsbox_hitmarkers_thickness", function(convar_name, value_old, value_new)
    th = math.max(tonumber(value_new))
    rebuildHitmarker()
end)

net.Receive("PRSBOX.Hitmarkers.Netcode", NetReceived)