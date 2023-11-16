local PLAYER_MONEY = 0

surface.CreateFont("prsboxMoneyHUDLarge", {
    font = "Roboto",
    size = 30
})

local mat_dollar_icon = Material("icon16/money_dollar.png")

net.Receive("PRSBOX.Net.OnMoneyGet", function(len, ply)
    local newMoney = net.ReadInt(21) -- New player money

    PLAYER_MONEY = newMoney

    print("You have received " .. newMoney .. "!")
end)


function getLocalPlayerMoney()
    return PLAYER_MONEY
end

local function drawHud()
    if not GetConVar("cl_drawhud"):GetBool() then return end

    surface.SetFont("prsboxMoneyHUDLarge")
    local pw, ph = surface.GetTextSize(PLAYER_MONEY)

    draw.RoundedBox(4, ScrW() * 0.01, ScrH() * 0.02, 40 + pw, 36, Color(0,0,0,105))
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(ScrW() * 0.01 + 8, ScrH() * 0.02 + 8, 20, 20)
    draw.DrawText(PLAYER_MONEY, "prsboxMoneyHUDLarge", ScrW() * 0.01 + 32, ScrH() * 0.02 + 3, COLOR_WHITE, TEXT_ALIGN_LEFT)
end

hook.Add("HUDPaint", "PRSBOX.Money.Hud", drawHud)
