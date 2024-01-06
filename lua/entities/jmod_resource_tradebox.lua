if not JMod then return end
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Sell Resources Crate"
ENT.Author = "Isemenuk27 and Swanchick :D"
ENT.Category = "JMod - EZ Misc."
ENT.NoSitAllowed = true
ENT.Spawnable = false --false
ENT.AdminSpawnable = false --false
ENT.DisableDuplicator = true
ENT.DisablePhysgunInteract = true 

ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.DamageThreshold=120

ENT.ChildEntity = ""
ENT.MainTitleWord = "RESOURCES"
ENT.IgnoreProperty = {
	["remove"] = true
}
function ENT:Initialize()
	--self:SetModel("models/props_prsbox/sellcreate.mdl")
	--self:SetModel("addons/prostir_content/models/sellcreate.mdl")
	self:SetModel("models/Items/ammocrate_smg1.mdl")
	
	self:SetMoveType(MOVETYPE_VPHYSICS)	
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		--self:DropToFloor()
		self.EZconsumes = {}
		for k,v in pairs(JMod.EZ_RESOURCE_TYPES) do table.insert(self.EZconsumes,v) end
		self.NextLoad=0
	end
end

local tr = SERVER and { collisiongroup = COLLISION_GROUP_WORLD, output = {} }

function ENT:DropToGround()
	tr.start = self:GetPos()
	tr.endpos = tr.start - Vector( 0, 0, 300 )
	tr.start.z = tr.start.z + 6
	
	local t = util.TraceLine( tr )
	if ( not t.Hit ) then return end
	t.HitPos.z = t.HitPos.z + 32.39 * .5
	self:SetPos( t.HitPos )
end

JMODTRADESCOSTS = {
		["ent_jack_gmod_ezadvparts"] = 1.5,
		["ent_jack_gmod_ezadvtextiles"] = 1,
		["ent_jack_gmod_ezaluminum"] = .7,
		["ent_jack_gmod_ezaluminumore"] = 0.5,
		["ent_jack_gmod_ezammo"] = 0.2,
		["ent_jack_gmod_ezantimatter"] = 2,
		["ent_jack_gmod_ezbasicparts"] = 0.8,
		["ent_jack_gmod_ezbattery"] = 1,
		["ent_jack_gmod_ezceramic"] = 0.6,
		["ent_jack_gmod_ezchemicals"] = 1,
		["ent_jack_gmod_ezcloth"] = 1,
		["ent_jack_gmod_ezcoal"] = 1.2,
		["ent_jack_gmod_ezcoolant"] = 1.6,
		["ent_jack_gmod_ezcopper"] = 1.2,
		["ent_jack_gmod_ezcopperore"] = 0.9,
		["ent_jack_gmod_ezdiamond"] = 6,
		["ent_jack_gmod_ezexplosives"] = 1,
		["ent_jack_gmod_ezfissilematerial"] = 2,
		["ent_jack_gmod_ezfuel"] = .6,
		["ent_jack_gmod_ezgas"] = .6,
		["ent_jack_gmod_ezglass"] = .6,
		["ent_jack_gmod_ezgold"] = 2,
		["ent_jack_gmod_ezgoldore"] = 0.8,
		["ent_jack_gmod_ezironore"] = 0.6,
		["ent_jack_gmod_ezlead"] = 1,
		["ent_jack_gmod_ezleadore"] = 0.8,
		["ent_jack_gmod_ezmedsupplies"] = .8,
		["ent_jack_gmod_ezmunitions"] = .7,
		["ent_jack_gmod_eznutrients"] = .8,
		["ent_jack_gmod_ezoil"] = .8,
		["ent_jack_gmod_ezorganics"] = .7,
		["ent_jack_gmod_ezpaper"] = .6,
		["ent_jack_gmod_ezplastic"] = .8,
		["ent_jack_gmod_ezplatinum"] = .9,
		["ent_jack_gmod_ezplatinumore"] = 1,
		["ent_jack_gmod_ezprecparts"] = 1.5,
		["ent_jack_gmod_ezpropellant"] = .7,
		["ent_jack_gmod_ezrubber"] = 1,
		["ent_jack_gmod_ezsilver"] = 1,
		["ent_jack_gmod_ezsilverore"] = 0.8,
		["ent_jack_gmod_ezsteel"] =  .9,
		["ent_jack_gmod_eztitanium"] = .9,
		["ent_jack_gmod_eztitaniumore"] = 0.9,
		["ent_jack_gmod_eztungsten"] = 1,
		["ent_jack_gmod_eztungstenore"] = 0.8,
		["ent_jack_gmod_ezuranium"] = 1,
		["ent_jack_gmod_ezuraniumore"] = .6,
		["ent_jack_gmod_ezwater"] = 0.5,
		["ent_jack_gmod_ezwood"] = 0.65
	}

if SERVER then
	resource.AddSingleFile("materials/entities/jmod_resource_tradebox.png")

	local playerGetAll = player.GetAll
	local mul = CreateConVar("prsbox_jmod_trade_mult", "1", FCVAR_ARCHIVE)
	function ENT:PhysicsCollide(data,physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self:EmitSound("MetalGrate.ImpactSoft")
				self:EmitSound("EpicMetal.ImpactHard")
			end
		end

		local ent = data.HitEntity

		if not ent:IsScripted() then return end

		if not IsValid(ent) then return end

		local entClass = ent:GetClass()
		local ply = GetPlayerHolder(ent)

		if not IsValid(ply) then return end

		if ply:GetBuildMode() then return end

		local basecost = JMODTRADESCOSTS[entClass]
		if basecost then
			local res = ent:GetResource()
			local m = basecost * res * mul:GetFloat()

			local CurMoney = getPlayerMoney( ply:SteamID64() )
			--ply:AddMoney( m )
			setPlayerMoney( ply:SteamID64(), (m + CurMoney) )

			self:EmitSound('NPC_Alyx.Vend_Coin')
			ent:Remove()
			self:EmitSound("AmmoCrate.Close")
		end
	end

	function ENT:TryLoadResource()
		return 0
	end

	function GetPlayerHolder( ent )
		if !ent:IsPlayerHolding() then return end
		return ent.PlayerHolding or nil
	end

	hook.Add("OnPlayerPhysicsPickup", "PRSBOX.GetPLayerHeldObj", function(ply, ent)
		ent.PlayerHolding = ply or nil
	end)

	function ENT:OnTakeDamage(dmginfo)
		if ( self.FUCKFUCK ) then return end

		self:TakePhysicsDamage(dmginfo)

		if ( dmginfo:GetDamage() > self.DamageThreshold ) then
			self.FUCKFUCK = true

			local Pos = self:GetPos()

			sound.Play("Wood_Crate.Break",Pos)
			sound.Play("Wood_Box.Break",Pos)

			local ply = dmginfo:GetAttacker()

			if ( IsValid(ply) and ply:IsPlayer() ) then
				ply:SendKillNotf( 200, "отримано" )
			end

			self:Remove()
		end
	end

	function ENT:Think() end
	function ENT:OnRemove() end

end

if CLIENT then
	local TxtCol = Color(200,200,200,220)
	local Text, Font = "Sell Resources", "JMod-Stencil"
	local SimpleText = draw.SimpleText
	local Start3D2D, End3D2D = cam.Start3D2D, cam.End3D2D

	function ENT:Draw()
		local Ang,Pos = self:GetAngles(), self:GetPos()
		local Closeness = EyePos():DistToSqr( Pos ) * ( LocalPlayer():GetFOV() / 110 )
		local DetailDraw = Closeness <= 300000
		self:DrawModel()

		if ( not DetailDraw ) then return end

		TxtCol.a = math.Remap( Closeness, 200000, 300000, 255, 0 )

		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		Ang:RotateAroundAxis(Ang:Right(),90)
		Ang:RotateAroundAxis(Ang:Up(),-90)

		Start3D2D(Pos + Up * .8 - Forward * 16 + Right, Ang, .10)
			SimpleText( Text, Font,0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		End3D2D()

		Ang:RotateAroundAxis(Ang:Right(),180)

		Start3D2D( Pos + Up * .8 + Forward * 16 - Right, Ang, .10)
			SimpleText( Text, Font,0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		End3D2D()

		local ang2 = self:GetAngles()
		ang2:RotateAroundAxis( Ang:Right(), -90 )

		Start3D2D( Pos + Up * 16 + Forward * -4.5, ang2, .10 )
			SimpleText( Text, Font,0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		End3D2D()
	end

	language.Add("jmod_resource_tradebox","Sell Crate")
end
