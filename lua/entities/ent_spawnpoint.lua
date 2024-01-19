-- Той хто читає цей код, прохання вбитися об стіну. А той хто писав це може перевернути ваш гроб.
AddCSLuaFile()

ENT.Type = "anim"
ENT.Author = "Findya"
ENT.Category = "Other"
ENT.PrintName = "Spawn Point"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PhysgunDisabled = true
ENT.Model = "models/jmod/props/sleeping_bag.mdl"



function ENT:Initialize()
	
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHP(400)
	self:EmitSound("Wood.ImpactHard")
	
end




function ENT:PizdaRulyam()
	local pos = self:GetPos()

	local svistoPerdelka = EffectData()
	svistoPerdelka:SetStart( pos+ Vector(0, 0, 25) )
	svistoPerdelka:SetOrigin( pos+ Vector(0, 0, 25) )
	svistoPerdelka:SetRadius( 50 )
	svistoPerdelka:SetAngles( Angle(0,0,0) )
	util.Effect("AntlionGib", svistoPerdelka, true, true)

	local ply = self:GetPlayer()

	
	self:EmitSound("Wood_Box.Break")
	self:Remove()

	if !IsValid(ply) then return end
	ply.SvistoSpawndelka = nil
end



function ENT:kys() -- Ета када гравец ліває (туда), то спец еффект да імба ааааааааааааааааааааа
	local pos = self:GetPos()

	local svistoPerdelka = EffectData()
	svistoPerdelka:SetStart( pos+ Vector(0, 0, 5) )
	svistoPerdelka:SetOrigin( pos+ Vector(0, 0, 5) )
	svistoPerdelka:SetRadius( 50 )
	svistoPerdelka:SetAngles( Angle(0,0,0) )
	util.Effect("cball_explode", svistoPerdelka, true, true)

	local ply = self:GetPlayer()

	
	self:EmitSound("Weapon_AR2.NPC_Double")
	self:Remove()

	if !IsValid(ply) then return end
	ply.SvistoSpawndelka = nil
end



function ENT:OnTakeDamage( ThatsDohuyaDamage ) -- спіздив код чуть чуть з семенюка. Якщо він буде щось пиздіти про мій код, то знайте що він сам на себе розпиздячив.
	
	self:TakePhysicsDamage(ThatsDohuyaDamage)
	self:EmitSound("Wood_Plank.BulletImpact")
	
	local Shiza = self:GetHP()

	if Shiza <= 0 then return end

	local NewShiza = Shiza - ThatsDohuyaDamage:GetDamage()

	self:SetHP( NewShiza )

	if NewShiza > 0 then return end

	self:PizdaRulyam()
end

hook.Add( "PlayerDisconnected", "FindyasSpawn.Ragequit", function(player)
	if !IsValid(player.SvistoSpawndelka) then return end
	player.SvistoSpawndelka:kys()
end)

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "HP" )
	self:NetworkVar( "Entity", 0, "Player" )
end
