-- відправляє клієнту код для висирання повідомлення в чат.
function ulx.discord(calling_ply)
	calling_ply:SendLua([[chat.AddText(Color(135,221,255), "Наш діскорд: ", Color(221,180,255), "https://discord.gg/stV4JswQ9Q")]])
end

local discord = ulx.command("Prostir", "ulx discord", ulx.discord, "!discord")
discord:defaultAccess(ULib.ACCESS_ALL)
discord:help("Дає посилання на діскорд сервер Простору.")