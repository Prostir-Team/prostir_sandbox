print("Icons cl")

local PLAYERS_ICONS = {}

local testIcon = Material("icon16/wrench.png")

local function ExistPlayerTable(steamid)
    return table.HasValue(table.GetKeys(PLAYERS_ICONS), steamid)
end 

local function ExistPlayerIcon(steamid, iconPath)    
    local icon = string.Split(iconPath, ".")[1]
    local icons = table.Copy(PLAYERS_ICONS[steamid])

    if not table.HasValue(table.GetKeys(PLAYERS_ICONS), steamid) then return false end

    for k, v in ipairs(icons) do
        if isnumber(v) then continue end
        
        if v:GetName() == icon then
            return true
        end
    end

    return false
end

local function AddPlayerIcon(steamid, iconPath)
    local icon = string.Split(iconPath, ".")[1]
    
    if not table.HasValue(table.GetKeys(PLAYERS_ICONS), steamid) then
        PLAYERS_ICONS[steamid] = {}
    end

    if ExistPlayerIcon(steamid, iconPath) then return end

    local iconMaterial = Material(iconPath)
    table.insert(PLAYERS_ICONS[steamid], iconMaterial)
end 

local function RemovePlayerIcon(steamid, iconPath)
    local icon = string.Split(iconPath, ".")[1]
    local icons = table.Copy(PLAYERS_ICONS[steamid])

    if not ExistPlayerIcon(steamid, iconPath) then return end

    for k, v in ipairs(icons) do
        if isnumber(v) then continue end

        if v:GetName() == icon then
            table.RemoveByValue(PLAYERS_ICONS[steamid], v)

            break
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "PRSBOX.Icon.Draw", function ()
    if not IsValid(LocalPlayer()) then return end
    
    local players = player.GetAll()

    for _, ply in ipairs(players) do
        if not IsValid(ply) then continue end
        if not ply:Alive() then continue end

        local steamid = ply:SteamID()
        if not ExistPlayerTable(steamid) then continue end
        

        local bone = ply:LookupBone('ValveBiped.Bip01_Head1')
        local pos = bone and ply:GetBonePosition(bone) or ply:LocalToWorld(Vector(0,0,55))
        local icon_length = #PLAYERS_ICONS[steamid] * 10


        local angle = Angle(
            0,
            LocalPlayer():EyeAngles().y,
            LocalPlayer():EyeAngles().z
        )

        cam.Start3D2D(pos + Vector(0, 0, 40), angle + Angle(0, -90, 90), 1)
            local pad = 13

            surface.SetDrawColor(255, 255, 255, 200)
            
            local i = 0

            for k, icon in ipairs(PLAYERS_ICONS[steamid]) do
                if isnumber(icon) then continue end
                if icon:IsError() then continue end

                surface.SetMaterial(icon)
                surface.DrawTexturedRect(-(icon_length / 2) + (i * pad), 15, pad, pad)

                i = i + 1
            end
            
        cam.End3D2D()
    end
end)

net.Receive("PRSBOX.Icons", function (len, ply)
    local steamid = net.ReadString()
    local materialIcon = net.ReadString()

    local addremove = net.ReadBool()

    print("Icon ping")

    if addremove then
        AddPlayerIcon(steamid, materialIcon) -- Add an icon
    else
        RemovePlayerIcon(steamid, materialIcon) -- Remove an icon
    end
end)