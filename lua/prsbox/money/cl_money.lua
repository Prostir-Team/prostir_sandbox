local PLAYER_MONEY = 0

net.Receive("PRSBOX.Net.OnMoneyGet", function(len, ply)
    local newMoney = net.ReadInt(21) -- New player money

    PLAYER_MONEY = newMoney

    print("You have received " .. newMoney .. "!")
end)


function getLocalPlayerMoney()
    return PLAYER_MONEY
end


hook.Add("HUDPaint", "TEST.Money.Hud", function ()
    draw.DrawText(PLAYER_MONEY, "DermaLarge", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
end)