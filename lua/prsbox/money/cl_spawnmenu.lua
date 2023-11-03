LOCAL_PRICE = LOCAL_PRICE or {}

surface.CreateFont("DermaMedium", {
    font = "Roboto",
    size = 20
})

local mat_dollar_icon = Material("icon16/money_dollar.png")

net.Receive("PRSBOX.Net.SendPrices", function (len)
    LOCAL_PRICE = net.ReadTable()
end)

hook.Add("PRSBOX.ContentIcon.Paint", "PRSBOX.ShowPrices", function (panel, w, h)
    local classname = panel:GetSpawnName()

    if not table.HasValue(table.GetKeys(LOCAL_PRICE), classname) then return end

    local price = tostring(LOCAL_PRICE[classname])

    local pw, ph = surface.GetTextSize(price)
    
    draw.RoundedBox(4, 7, 7, 32 + pw, 28, Color(0,0,0,220))
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(10, 10, 20, 20)
    draw.DrawText(price, "DermaMedium", 30, 10, COLOR_WHITE, TEXT_ALIGN_LEFT)
end)