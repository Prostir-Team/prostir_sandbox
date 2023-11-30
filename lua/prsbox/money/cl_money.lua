PLAYER_MONEY = 0

surface.CreateFont("prsboxMoneyHUDLarge", {
    font = "Roboto",
    size = 40
})

local mat_dollar_icon = Material("hud/money2.png")

net.Receive("PRSBOX.Net.OnMoneyGet", function(len, ply)
    local newMoney = net.ReadInt(21) -- New player money

    PLAYER_MONEY = newMoney

    print("You have received " .. newMoney .. "!")
end)


function getLocalPlayerMoney()
    return PLAYER_MONEY
end

local function drawHud()
    surface.SetFont("prsboxMoneyHUDLarge")
    --local pw, ph = surface.GetTextSize(PLAYER_MONEY)
    --print(pw)

    local posx = ScrW() * 0.885
    local posy = ScrH() * 0.02

    draw.RoundedBox(4, posx, posy, 48 + 118, 48, Color(0,0,0,105))
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(posx + 8, posy + 9, 32, 32)
    --draw.DrawText("€$", "eurodollarIcon", posx + 8, posy + 9, COLOR_WHITE, TEXT_ALIGN_LEFT)
    draw.DrawText(PLAYER_MONEY, "prsboxMoneyHUDLarge", posx + 158, posy + 4, COLOR_WHITE, TEXT_ALIGN_RIGHT)
end

local hudvar = GetConVar("cl_drawhud"):GetBool() --По хорошому треба окремий хук, який не викликається без цього квара

cvars.AddChangeCallback( "cl_drawhud", function( name, old, new )
    hudvar = tonumber( new ) > 0

    if ( hudvar ) then
        hook.Add("HUDPaint", "PRSBOX.Money.Hud", drawHud)
    else
        hook.Remove("HUDPaint", "PRSBOX.Money.Hud" )
    end
end )

if ( hudvar ) then
    hook.Add("HUDPaint", "PRSBOX.Money.Hud", drawHud)
end