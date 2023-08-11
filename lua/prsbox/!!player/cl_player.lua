print("player start")

surface.CreateFont("PRSBOX.HUD.Player", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(8),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PRSBOX.HUD.PlayerLittle", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(6),
    ["extended"] = true,
    ["weight"] = 700
})

CreateConVar("prsbox_playermodel", "", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "")

CreateClientConVar("prsbox_hud_x", "0", FCVAR_ARCHIVE, false, "", -50, 50)
CreateClientConVar("prsbox_hud_y", "5", FCVAR_ARCHIVE, false, "", -50, 50)

local scrW, scrH = ScrW(), ScrH()
local lastPlayer = NULL

local alphaTo = 0
local currentAlpha = 0


local function drawTextShadow(text, font, x, y, color, align)
    draw.DrawText(text, font, x + 2, y + 2, Color(0, 0, 0, color.a), align)
    draw.DrawText(text, font, x, y, color, align)
end

hook.Add("HUDDrawTargetID", "PRSBOX.ID", function()
    currentAlpha = Lerp(FrameTime() * 5, currentAlpha, alphaTo)

    if IsValid(lastPlayer) and lastPlayer:IsPlayer() then
        local x, y = GetConVar("prsbox_hud_x"):GetInt() * 2, GetConVar("prsbox_hud_y"):GetInt() * 2

        drawTextShadow(lastPlayer:Nick(), "PRSBOX.HUD.Player", scrW / 2 + x, scrH / 2 + y, Color(255, 255, 255, currentAlpha), TEXT_ALIGN_CENTER)
        drawTextShadow(math.Clamp(lastPlayer:Health(), 0, 110) .. "%", "PRSBOX.HUD.PlayerLittle", scrW / 2 + x, scrH / 2 + y + ScreenScale(8), Color(255, 255, 255, currentAlpha), TEXT_ALIGN_CENTER)
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

    alphaTo = 1000

    return false
end)