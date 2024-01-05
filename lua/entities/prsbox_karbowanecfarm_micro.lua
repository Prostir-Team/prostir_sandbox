AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "prsbox_karbowanecfarm"
ENT.PrintName = '"Karbowanec" Micro Crypto Farm'
ENT.Category = "Other"
ENT.Author = "Isemenuk27"

ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DisableDuplicator = true

--ENT.Model = "models/props_prsbox/karbowanec_micro.mdl"
ENT.Model = "models/karbowanec_micro.mdl"
ENT.ConsumeKoef = 1.5
ENT.MoneyKoef = 1
ENT.MineTimeKoef = 2.68

ENT.HEIGHTOFFSET = 16

if ( CLIENT ) then
	ENT.SCROFFSET = Vector( -1.1, 15, 12 )
	ENT.ScrAng = Angle( 0, -180, 87 )
	ENT.ScreenScale = .098
end