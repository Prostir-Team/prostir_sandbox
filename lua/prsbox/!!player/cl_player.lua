print("player start")

surface.CreateFont("PRSBOX.HUD.Player", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(8),
    ["extended"] = true,
    ["weight"] = 700
})

CreateConVar("prsbox_playermodel", "", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "")

CreateClientConVar("prsbox_hud_x", "0", FCVAR_ARCHIVE, false, "", -100, 100)
CreateClientConVar("prsbox_hud_y", "25", FCVAR_ARCHIVE, false, "", -100, 100)

local scrW, scrH = ScrW(), ScrH()
local lastPlayer = NULL

local alphaTo = 0
local currentAlpha = 0


hook.Add("HUDDrawTargetID", "PRSBOX.ID", function()
    currentAlpha = Lerp(FrameTime() * 5, currentAlpha, alphaTo)

    if IsValid(lastPlayer) then
        local x, y = GetConVar("prsbox_hud_x"):GetInt(), GetConVar("prsbox_hud_y"):GetInt()

        draw.DrawText(lastPlayer:Nick(), "PRSBOX.HUD.Player", scrW / 2 + x +2, scrH / 2 + y + 2, Color(0, 0, 0, currentAlpha), TEXT_ALIGN_CENTER)
        draw.DrawText(lastPlayer:Nick(), "PRSBOX.HUD.Player", scrW / 2 + x, scrH / 2 + y, Color(200, 200, 200, currentAlpha), TEXT_ALIGN_CENTER)
    end
    
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    local otherPlayer = trace.Entity

    if not IsValid(otherPlayer) and not otherPlayer:IsPlayer() then 
        alphaTo = 0

        return 
    end
    lastPlayer = otherPlayer

    alphaTo = 255

    return false
end)