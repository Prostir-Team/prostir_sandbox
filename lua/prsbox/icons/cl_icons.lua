print("Icons cl")

local PLAYERS_ICONS = {
    ["BOT"] = {
        Material("icon16/wrench.png"),
    }
}

local testIcon = Material("icon16/wrench.png")

local function ExistPlayerIcon(ply, iconPath)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    
    local steamid = ply:SteamID()
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

local function AddPlayerIcon(ply, iconPath)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local steamid = ply:SteamID()
    local icon = string.Split(iconPath, ".")[1]
    
    if not table.HasValue(table.GetKeys(PLAYERS_ICONS), steamid) then
        PLAYERS_ICONS[steamid] = {}
    end

    if ExistPlayerIcon(ply, iconPath) then return end

    local iconMaterial = Material(iconPath)
    table.insert(PLAYERS_ICONS[steamid], iconMaterial)
end 

local function RemovePlayerIcon(ply, iconPath)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    
    local steamid = ply:SteamID()
    local icon = string.Split(iconPath, ".")[1]
    local icons = table.Copy(PLAYERS_ICONS[steamid])

    if not ExistPlayerIcon(ply, iconPath) then return end

    for k, v in ipairs(icons) do
        if isnumber(v) then continue end

        if v:GetName() == icon then
            table.RemoveByValue(PLAYERS_ICONS[steamid], v)

            break
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "PRSBOX.Icon.Draw", function ()
    if not localPlayer then
        localPlayer = LocalPlayer()
        
        return
    end
    
    local players = player.GetAll()

    for _, ply in ipairs(players) do
        if not IsValid(ply) then return end
        if not ply:IsBot() then continue end

        local bone = ply:LookupBone('ValveBiped.Bip01_Head1')
        local pos = bone and ply:GetBonePosition(bone) or ply:LocalToWorld(Vector(0,0,55))
        local steamid = ply:SteamID()
        local icon_length = #PLAYERS_ICONS[steamid] * 10


        local angle = Angle(
            0,
            localPlayer:EyeAngles().y,
            localPlayer:EyeAngles().z
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


concommand.Add("icon_remove", function (ply)
    print("Removing icons")

    local icon = "icon16/controller.png"

    for k, v in ipairs(player.GetAll()) do
        if not v:IsBot() then continue end

        RemovePlayerIcon(v, icon)

        print(ExistPlayerIcon(v, icon))
    end
    
end)

concommand.Add("icon_add", function (ply)
    local icons = PLAYERS_ICONS["BOT"]

    local icon = "icon16/controller.png"

    for k, v in ipairs(player.GetAll()) do
        if not v:IsBot() then continue end

        AddPlayerIcon(v, icon)
    end
end)