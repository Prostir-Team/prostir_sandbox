LOCAL_PRICE = LOCAL_PRICE or {}

surface.CreateFont("prsboxMoneyHUDMedium", {
    font = "Roboto",
    size = 20
})

local mat_dollar_icon = Material("hud/money2.png")

net.Receive("PRSBOX.Net.SendPrices", function (len)
    LOCAL_PRICE = net.ReadTable()
end)

hook.Add("PRSBOX.ContentIcon.Paint", "PRSBOX.ShowPrices", function (panel, w, h)
    local classname = panel:GetSpawnName()

    if not table.HasValue(table.GetKeys(LOCAL_PRICE), classname) then return end

    local price = tostring(LOCAL_PRICE[classname])

    surface.SetFont("prsboxMoneyHUDMedium")
    --local pw, ph = surface.GetTextSize(price)

    local iconcolor = Color(255, 255, 255)
    local textcolor = Color(255, 255, 255)
    if tonumber(PLAYER_MONEY) > tonumber(price) then
        iconcolor = Color(100, 255, 100)
        textcolor = Color(60, 255, 60)
    else
        iconcolor = Color(255, 100, 100)
        textcolor = Color(255, 60, 60)
    end
    
    --draw.RoundedBox(4, 7, 7, 32 + pw, 28, Color(0,0,0,120))
    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(11, 13, 20, 20)
    draw.DrawText(price, "prsboxMoneyHUDMedium", 34, 12, COLOR_BLACK, TEXT_ALIGN_LEFT)
    surface.SetDrawColor(iconcolor)
    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(10, 12, 20, 20)
    draw.DrawText(price, "prsboxMoneyHUDMedium", 33, 11, textcolor, TEXT_ALIGN_LEFT)
end)