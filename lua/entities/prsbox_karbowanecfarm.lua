AddCSLuaFile()

sound.Add( {
	name = "Karbowanec.LoopSound",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = {95, 110},
	sound = "^ambient/levels/labs/equipment_printer_loop1.wav"
} )

DEFINE_BASECLASS("base_anim")

local MinerDelay = CreateConVar("prsbox_miner_delay", "5", FCVAR_ARCHIVE, "Майнери))")
local MinerMoney = CreateConVar("prsbox_miner_money", "2", FCVAR_ARCHIVE, "Майнери))")
local MinerPower = CreateConVar("prsbox_miner_powerreptick", "0.25", FCVAR_ARCHIVE, "Майнери))")

ENT.PrintName = '"Karbowanec" Crypto Farm'
ENT.Information = ""
ENT.Category = "Other"
ENT.DisableDuplicator = true
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.EntHealth = 600
ENT.NextUse = CurTime()

ENT.IgnoreProperty = {
	["remove"] = true
}

ENT.NoSit = true
ENT.NoCleanup = true

--ENT.Model = "models/props_prsbox/karbowanecfarm.mdl"
ENT.Model = "addons/prostir_content/models/karbowanecfarm.mdl"
ENT.ImpactSound = "Computer.ImpactHard"
ENT.DamageSound = "Computer.BulletImpact"
ENT.BreakSound = "Canals.d1_canals_01a_metal_box_break2"
ENT.LoopSound = "Karbowanec.LoopSound"
ENT.TypeSound = "k_lab.typing_fast_2"

util.PrecacheSound( "k_lab.typing_fast_2" )

ENT.NextMine = 0
ENT.ResetProgTime = 0

ENT.ConsumeKoef = 1
ENT.MoneyKoef = 1
ENT.MineTimeKoef = 1

local PropModels = {
	"models/props_lab/reciever01d.mdl",
	"models/gibs/manhack_gib03.mdl",
	"models/gibs/manhack_gib04.mdl",
	"models/gibs/manhack_gib05.mdl",
	"models/gibs/manhack_gib06.mdl",
	"models/gibs/metal_gib1.mdl",
	"models/gibs/metal_gib2.mdl",
	"models/gibs/metal_gib3.mdl",
	"models/gibs/metal_gib4.mdl",
	"models/gibs/metal_gib5.mdl",
	"models/gibs/scanner_gib01.mdl",
	"models/gibs/scanner_gib02.mdl",
	"models/props_c17/canisterchunk01d.mdl",
	"models/props_c17/canisterchunk01b.mdl",
	"models/props_c17/canisterchunk01l.mdl",
	"models/props_c17/canisterchunk01m.mdl",
	"models/props_c17/canisterchunk02b.mdl",
	"models/props_c17/canisterchunk02c.mdl",
	"models/props_c17/canisterchunk02d.mdl",
	"models/props_c17/canisterchunk02e.mdl",
	"models/props_c17/canisterchunk02f.mdl",
	"models/props_c17/canisterchunk01a.mdl",
	"models/props_c17/canisterchunk01h.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_junk/vent001_chunk1.mdl",
	"models/props_junk/vent001_chunk2.mdl",
	"models/props_junk/vent001_chunk3.mdl",
	"models/props_junk/vent001_chunk4.mdl",
	"models/props_junk/vent001_chunk5.mdl",
	"models/props_junk/vent001_chunk6.mdl",
	"models/props_junk/vent001_chunk7.mdl",
	"models/props_junk/vent001_chunk8.mdl",
}

for i,v in ipairs(PropModels) do
	util.PrecacheModel(v)
end

function ENT:Initialize()
	self:SetModel( self.Model )
	self:SetPower( 100 )

	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if ( self.HEIGHTOFFSET ) then
		local pos = self:GetPos()
		pos.z = pos.z + self.HEIGHTOFFSET
		self:SetPos( pos )
	end

	if ( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS ) 
		if ( WireLib ) then
			self.Outputs = WireLib.CreateOutputs( self, {"Power", "Money"}, {"Amount of power left", "Amount of money"} )
		end
	end

	self.LoopSoundId = self:StartLoopingSound( self.LoopSound )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Money" )
	
	self:NetworkVar( "Float", 0, "NextMine" )
	self:NetworkVar( "Float", 1, "Power" )
	self:NetworkVar( "Float", 2, "TransferMoneyProgress" )

	self:NetworkVar( "Bool", 0, "Upgraded" )
end

function ENT:TransferMoney( ply )
	local CM = self:GetMoney()
	if CM < 1 or ply:GetBuildMode() then return end

	--ply:AddMoney( CM )
	local plyMoney = getPlayerMoney( ply:SteamID64() )
	setPlayerMoney( ply:SteamID64(), plyMoney + CM )

	ply:EmitSound("buttons/button4.wav")

	self:SetMoney(0)


	if ( WireLib ) then
		WireLib.TriggerOutput( self, "Money", 0 )
	end

	--ply:SendKillNotf( CM, "надруковано" )
end

function ENT:Use( activator )
	if self.NextUse > CurTime() or self:GetPower() <= 0 then return end

	if ( activator:IsPlayer() && activator:Alive() ) then 
		if self:GetMoney() < 1 then return end

		if activator:KeyPressed(IN_USE) then
			self:SetTransferMoneyProgress(1)
			EmitSound( self.TypeSound, activator:GetPos(), 1, CHAN_AUTO, 1, 40, 0, 100 )
		end

		local CM = self:GetTransferMoneyProgress()
		if activator:KeyDown(IN_USE) and CM > 0 then
			local newnum = CM + FrameTime() * 50

			if ( newnum < 1 ) then newnum = 1 end

			self:SetTransferMoneyProgress( newnum )
			local timern = self:EntIndex() .. "KarbowanecTimer"

			if CM + 1 >= 100 then
				self:TransferMoney( activator )
				self:SetTransferMoneyProgress(0)
				self.NextUse = CurTime() + 1
				self.ResetProgTime = 0
				return
			end
			self.ResetProgTime = CurTime() + 0.1
		end
	end
end

function ENT:Think()
	if CLIENT then return end
	if self.ResetProgTime < CurTime() and self.ResetProgTime != 0 then
		self:SetTransferMoneyProgress(0)
	end
	if self:GetNextMine() > CurTime() or self:GetPower() <= 0 then return end
	local mult = self:GetUpgraded() and 2 or 1

	local Money = self:GetMoney() + ( MinerMoney:GetInt() * mult ) * self.MoneyKoef

	self:SetMoney( Money )

	local Power = math.max(self:GetPower() - MinerPower:GetFloat() * self.ConsumeKoef, 0)

	self:SetPower( Power )

	if ( WireLib ) then
		WireLib.TriggerOutput( self, "Money", Money )
		WireLib.TriggerOutput( self, "Power", Power )
	end

	if self:GetPower() <= 0 then self:StopLoopingSound( self.LoopSoundId ) end

	self:SetNextMine( CurTime() + ( MinerDelay:GetFloat() * self.MineTimeKoef ) )
end

if CLIENT then
	local ColorGreen, ColorGreen2 = Color(50,200,50,225), Color(50,150,50,225)
	local ColorGold, ColorGold2 = Color(200,200,10,225), Color(200,150,10,225)

	local TxtCol, TxtCol2 = ColorGreen, ColorGreen2
	local ColorRed = Color(200,50,50,225)
	local maxdist = 200000

	ENT.SCROFFSET = Vector( -24, 3.75, 93 )
	ENT.ScrAng = Angle( 0, -180, 100 )
	ENT.ScreenScale = .21

	function ENT:Draw()
		local Dist = EyePos():DistToSqr( self:GetPos() ) 
		self:DrawModel()

		if Dist > maxdist then return end

		local f = math.min(2 -((Dist * 2 / maxdist)), 1)

		local CamPos = self:LocalToWorld( self.SCROFFSET )
		local Ang = self:LocalToWorldAngles( self.ScrAng )

		local CMP = math.Truncate( self:GetTransferMoneyProgress(), 1 )
		local CM = self:GetNextMine()

		local CNMP = self:GetNextMine() - CurTime()
		local pb = math.Truncate( math.Remap(CNMP, MinerDelay:GetFloat() * self.MineTimeKoef, 0, 0, 10), 1 )

		local e = self:GetPower()
		local energy = math.Truncate( e, 1 ) .. "%"

		local Upgraded = self:GetUpgraded()

		cam.Start3D2D( CamPos, Ang, self.ScreenScale )

			if e <= 0 then
				TxtCol = ColorRed
				TxtCol2 = ColorRed
			elseif !Upgraded then
				TxtCol = ColorGreen
				TxtCol2 = ColorGreen2
			else
				TxtCol = ColorGold
				TxtCol2 = ColorGold2
			end
		   
			TxtCol.a = TimedSin(50, 150 * f, 255 * f, 0)
			TxtCol2.a = TxtCol.a
			draw.SimpleText( "karbowanec.exe 			         	" .. energy ,"KarbowanecS", 5,-5,TxtCol2,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)

			draw.SimpleText( self:GetMoney() .. "₴" ,"KarbowanecF",0,6,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)

			if e <= 0 then
				draw.SimpleText( "Insufficient power.","KarbowanecF",0,26,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				cam.End3D2D()
				return 
			end

			if CMP > 0 then
				local completed = math.ceil( CMP * 0.1 )
  				local remaining = 10 - completed

				local progressBar = string.rep( "#", completed) .. string.rep("_", remaining)
 
				draw.SimpleText( string.format( "[%s] %02i", progressBar, CMP ) .. "%","KarbowanecF", 0,80,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			else
				draw.SimpleText( "Hold <".. (input.LookupBinding( "+use" ) || "WTF?") ..">","KarbowanecF", 0,80,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
			
			local completed = math.ceil( pb )
			local remaining = 10 - completed

			local progressBar = string.rep( "#", completed) .. string.rep("_", remaining)

			draw.SimpleText( string.format( "%02i", pb * 10 ) .. "%","KarbowanecF", 0, 28,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText( string.format( "[%s]", progressBar ), "KarbowanecF", 0, 52, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		cam.End3D2D()
	end
end

if SERVER then
	util.AddNetworkString("Karbowanec.CreateFlingProp")
	resource.AddSingleFile("materials/entities/prsbox_karbowanecfarm.png")
else
	surface.CreateFont( "KarbowanecF", {
		font 		= "Arial",
		size 		= 24,
		weight 		= 10,
		scanlines 	= 2,
		antialias 	= true
	} )
	surface.CreateFont( "KarbowanecS", {
		font 		= "Arial",
		size 		= 14,
		weight 		= 4,
		antialias 	= false,
		scanlines 	= 2
	} )
	local function createBrokenProp(pos)
		local mdl = PropModels[math.random(1, #PropModels)]
		local Prop = ents.CreateClientProp(mdl)
		Prop:SetPos(pos)
		Prop:SetAngles(VectorRand():Angle())
		Prop:Spawn()
		Prop:SetAbsVelocity(( VectorRand() + Vector(0,0,1) ):GetNormalized() * math.Rand(100,200))
		SafeRemoveEntityDelayed(Prop, math.Rand(5,10) )
	end

	local gibsam = GetConVar("func_break_max_pieces")

	net.Receive("Karbowanec.CreateFlingProp", function()
		local pos = net.ReadVector()
		local obbcenter = net.ReadVector()
		local Size = net.ReadFloat()
		for i=1, gibsam:GetInt() do
			local fpos = (pos + obbcenter) + VectorRand() * math.random(1,Size/2)
			createBrokenProp(fpos)
		end
	end)
end

function ENT:FlingProp()
	net.Start("Karbowanec.CreateFlingProp")
		net.WriteVector(self:GetPos())
		net.WriteVector(self:OBBCenter())
		net.WriteFloat( (self:OBBMaxs() - self:OBBMins()):Length() )
	net.SendPVS(self:GetPos())
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )	
	self.EntHealth = self.EntHealth - dmginfo:GetDamage() 
	self:EmitSound( self.DamageSound )
	if self.EntHealth > 1 then return end
	self:FlingProp()
	self:EmitSound( self.BreakSound )
	self:Remove()
end

function ENT:OnRemove()
	if self.LoopSoundId then
		self:StopLoopingSound( self.LoopSoundId )
	end
end

local GradeClass = "prsbox_farmupgrade"

function ENT:PhysicsCollide( data, phys )
	if ( data.Speed > 50 ) then self:EmitSound( self.ImpactSound ) end
	if self:GetUpgraded() then return end
	local ent = data.HitEntity
	if !IsValid(ent) then return end
	if ent:GetClass() != GradeClass then return end
	if ( ent._USED ) then return end
	ent._USED = true
	ent:Remove()
	self:SetUpgraded(true)
end

ENT.EZconsumes = {JMod.EZ_RESOURCE_TYPES.POWER}
ENT.NextRefillTime = 0
ENT.BatteryLimit = 100

function ENT:TryLoadResource(typ, amt)
	if(amt <= 0)then return 0 end
	local Time = CurTime()
	if self.NextRefillTime > Time then return 0 end
	for k,v in pairs(self.EZconsumes)do
		if(typ == v)then
			local Accepted = 0
			if(typ == JMod.EZ_RESOURCE_TYPES.POWER)then
				local Powa = self:GetPower()
				local Missing = self.BatteryLimit - Powa
				if(Missing <= 0)then return 0 end
				Accepted = math.min(Missing, amt)
				self:SetPower(Powa + Accepted)
				if Powa <= 0 then self.LoopSoundId = self:StartLoopingSound( self.LoopSound ) end
				self:EmitSound("snd_jack_turretbatteryload.wav", 65, math.random(90, 110))
			end
			if self.ResourceLoaded then self:ResourceLoaded(typ, Accepted) end
			self.NextRefillTime = Time + 2
			return math.ceil(Accepted)
		end
	end
	return 0
end