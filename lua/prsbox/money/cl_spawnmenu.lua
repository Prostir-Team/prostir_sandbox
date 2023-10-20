print("Hello World")

LOCAL_PRICE = LOCAL_PRICE or {}

net.Receive("PRSBOX.Net.SendPrices", function (len)
    LOCAL_PRICE = net.ReadTable()
end)

hook.Add("PRSBOX.ContentIcon.Paint", "PRSBOX.ShowPrices", function (panel, w, h)
    local classname = panel:GetSpawnName()

    if not table.HasValue(table.GetKeys(LOCAL_PRICE), classname) then return end

    local price = LOCAL_PRICE[classname]

    draw.DrawText(price, "DermaLarge", 10, 10, COLOR_WHITE, TEXT_ALIGN_LEFT)
end)