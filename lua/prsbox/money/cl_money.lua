PLAYER_MONEY = 0

surface.CreateFont("prsboxMoneyHUDLarge", {
    font = "Roboto",
    size = 35 // Sigma resize
})

local mat_dollar_icon = Material("hud/money.png")

local Notifications = {} // пихати тільки string інакше я твої яйця відірву...

local OldMoney = 0

function RemoveNotification()
    table.remove(Notifications, 1)
end

net.Receive("PRSBOX.Net.OnMoneyGet", function(len, ply)
    local newMoney = net.ReadInt(21) -- New player money

    local MoneyReceived = newMoney - PLAYER_MONEY

    if MoneyReceived == newMoney then
        MoneyReceived = 70 -- факе, і я це знаю тому що не знаю як дістати точне число :)
    end

    table.insert( Notifications, 1, "Отримано грошей: ".. MoneyReceived .." $" ) -- 
    timer.Simple(5, RemoveNotification)
    PLAYER_MONEY = newMoney
    
    Theme_color = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())
    
    
    
    print("You have received " .. newMoney .. "!")
end)


function getLocalPlayerMoney()
    return PLAYER_MONEY
end

local function drawHud()
    surface.SetFont("prsboxMoneyHUDLarge")

    Theme_color = Color(PRSBOX_HUD_COLOR_R:GetInt(), PRSBOX_HUD_COLOR_G:GetInt(), PRSBOX_HUD_COLOR_B:GetInt(), PRSBOX_HUD_ALPHA:GetInt())

    local posx = ScrW() - 175
    local posy = ScrH() * 0.06

    for i,v in pairs(Notifications) do
        local String = v
        
        draw.DrawText(string.Explode("$", String, false)[1], "prsboxMoneyHUDLarge", ScrW()/2,70 + i * 30 , Color(50,255,50,255), TEXT_ALIGN_CENTER)
        
        if string.EndsWith(String,"$") then
            surface.SetMaterial(mat_dollar_icon)
            surface.SetDrawColor( Color(50,255,50,255):Unpack() )
            
            surface.DrawTexturedRect( ScrW()/2 + surface.GetTextSize(tostring(String))/2-10, 75 + i * 30, 35/1.2, 35/1.2)
        end

        
    end

    local MoneyBlock1TextSize = surface.GetTextSize(tostring(PLAYER_MONEY))
    local Money_X_Offset = (MoneyBlock1TextSize)

    draw.RoundedBox(4, 40, posy, 50+Money_X_Offset, 48/1.25, Color(0,0,0,105))
    surface.SetDrawColor(Theme_color)
    surface.DrawOutlinedRect(40, posy+1, 50+Money_X_Offset, 48/1.25, 3)

    surface.SetMaterial(mat_dollar_icon)
    surface.DrawTexturedRect(45, posy + 5, 35/1.2, 35/1.2)
    --draw.DrawText("€$", "eurodollarIcon", posx + 8, posy + 9, COLOR_WHITE, TEXT_ALIGN_LEFT) // 👈🏿 huita ibana iconca
    draw.DrawText(PLAYER_MONEY, "prsboxMoneyHUDLarge", 80, posy+1 , Theme_color, TEXT_ALIGN_LEFT)
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