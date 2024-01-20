-- Той хто читає цей код, прохання вбитися об стіну. А той хто писав це може перевернути ваш гроб.
AddCSLuaFile()

ENT.Type = "anim"
ENT.Author = "Findya"
ENT.Category = "Prostir Sandbox Entities"
ENT.PrintName = "Spawn Point"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PhysgunDisabled = true
ENT.Model = "models/jmod/props/sleeping_bag.mdl"

if CLIENT then
surface.CreateFont("prsboxSpawnpointHUDLarge", {
    font = "Trebuchet42",
    size = 60
})
end

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
	if ply and ply:IsPlayer() then
		ply:ChatPrint( "Ваша точка спавна була зруйнована!" )
	end
	self:EmitSound("Wood_Box.Break")
	self:Remove()

	if !IsValid(ply) then return end
	ply.SvistoSpawndelka = nil
end

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():Distance( self:GetPos() ) > 400 then return end

	cam.Start3D2D(self:GetPos() + Vector(0, 0, 25 + math.sin(CurTime()*2)*2 ) ,Angle( 0, EyeAngles().y - 90,90), 0.1)        
            
			local IMaterial = "icon16/shield.png"
			
            

			local Text = "Спавн поінт"
			local Theme = Color(100,255,100)

			if self:GetOwner():IsPlayer() then
				Text = self:GetOwner():Name()
				Theme = (self:GetOwner():GetWeaponColor()*255)
				IMaterial = "spawnicons/".. string.Explode(".", self:GetOwner():GetModel(), false)[1] .. ".png"
				
			end

            local IconSize = 70

			surface.SetMaterial( Material(IMaterial)  )
			surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(-IconSize / 2, -IconSize / 2 + 20, IconSize, IconSize)

			surface.SetDrawColor(25, 25, 25, 175)
            surface.DrawRect(-IconSize, -IconSize / 2 - 15, IconSize*2, IconSize/3.5)

			surface.SetDrawColor( Theme:Unpack() )
			
			local HP = self:GetHP() / (400 / 130) //+ IconSize * 2
            surface.DrawRect(-IconSize + 5, -IconSize / 2 - 11.5, HP , IconSize/3.5 / 1.45)

			IconSize = 190

			local NameBlock1TextSize = surface.GetTextSize(Text)
			
			local Pos = -IconSize/2

			local Name_X_Offset = Pos+(NameBlock1TextSize) + 350

			surface.SetDrawColor( Color(25,25,25,100):Unpack() )
    		surface.DrawRect(-Name_X_Offset/2.75, 0-IconSize/2 - 25, Name_X_Offset/1.375, IconSize, 6)

			surface.SetDrawColor( Theme:Unpack() )
    		surface.DrawOutlinedRect(-Name_X_Offset/2.75, 0-IconSize/2 - 25, Name_X_Offset/1.375, IconSize, 6)
			
			draw.SimpleText(Text, "prsboxSpawnpointHUDLarge", 0, -110-4, Theme, TEXT_ALIGN_CENTER)

    cam.End3D2D()

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
