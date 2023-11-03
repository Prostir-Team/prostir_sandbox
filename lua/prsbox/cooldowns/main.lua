--[[  			03.11.2023  			Isemenuk27
	Категорії вписуєте першими, після термінатора записуєте класи
]]--

PRSBOX.Cooldowns = {
	["JMod - EZ Misc."] = 60,
	["[LVS]"] = 50,
	["[LVS] - Helicopters"] = 10,
	["[LVS] - Planes"] = 10,
	["simfphys"] = 50, --Заправні станції

	["lvs_vehicle_repair"] = 20
}

PRSBOX.SharedCooldowns = { --Коли трігерять один з цих кулдаунів то трігеряться і інші
	{ "[LVS]", "[LVS] - Helicopters", "[LVS] - Planes" }
}

if ( CLIENT ) then
	include("prsbox/cooldowns/client.lua")
else
	AddCSLuaFile("prsbox/cooldowns/client.lua")
	include("prsbox/cooldowns/server.lua")
end