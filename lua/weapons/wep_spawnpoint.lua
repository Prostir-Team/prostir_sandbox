AddCSLuaFile() -- за всратий код нехай плачте ще більше.

SWEP.Author = "Findya"
SWEP.Instructions = "Не маленькі, розберетеся."
SWEP.PrintName	= "Точка Відродження"		
SWEP.Category = "Prostir Sandbox"		

SWEP.UseHands = true
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel	= "models/weapons/w_medkit.mdl"
SWEP.ViewModelFOV = 60

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Delay = 0

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom	= false	
SWEP.Slot = 5
SWEP.SlotPos = 15
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Material = "models/jmod/props/sleeping_jag"
SWEP.IMAT = CLIENT and Material( SWEP.Material ) or nil

local Reload = 0

function SWEP:Initialize()
	if self then
		// self:SetHoldType("slam")
		Reload = 0
		self:SetSubMaterial( nil, "models/jmod/props/sleeping_jag")
	end
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
	if Reload < 6 then
		render.MaterialOverride( Material("Models/effects/comball_tape") )
	else
		render.MaterialOverride( self.IMAT )
	end
	
end

function SWEP:ViewModelDrawn( vm, weapon, ply )
	render.MaterialOverride( nil )
end




function SWEP:TrackProblems()
	local Owner = self:GetOwner()
	


	// if  then // я в душі не їбу як тут зробити режим будівельника що би його читали, так що маєте цей кусок.
	// 	return "Ви в режимі будівельника"
	// end

	if Owner:GetNWBool("SpawnProtected") then
		return "Ви під захистом"
	end

	if Owner:GetVelocity():Length() > 2 then
		return "Ви повинні стояти на місці"
	end

	if Reload <= 2 or CLIENT and Reload < 6 then
		return "Перезарядка"
	end

	local trace = util.TraceHull( { 
        start = Owner:GetPos(),
        endpos = Owner:GetPos() + Vector(0, 0, 0),
        filter = Owner,
        mins = Vector( -10, -10, -15 ),
        maxs = Vector( 10, 10, 10 ),
        mask = MASK_SHOT_HULL
    } )
    
    if !trace.Hit then
        return "Хибне місце розташування"
    end


	return "   "

end

function SWEP:PrimaryAttack()
	if CLIENT then return end

	self:SetNextPrimaryFire(CurTime() + 0.2)

	local Owner = self:GetOwner()
	


	
	if self:TrackProblems() ~= "   " then Owner:EmitSound("buttons/button16.wav") return end

	
	local ent = ents.Create("ent_spawnpoint")
	local pos = Owner:GetPos() 

	if IsValid(Owner.SvistoSpawndelka) then Owner.SvistoSpawndelka:kys() end
	self:SetNextSecondaryFire(CurTime() + 0.3)

	
	self:Remove()
	local wps = Owner:GetWeapons()

	if IsValid(wps[1]) then
		Owner:SelectWeapon( wps[1] )
	end

    
	ent:SetPos( pos )
	
	ent:Spawn()
	
	ent:SetColor( Color( Owner:GetWeaponColor()[1]*200,Owner:GetWeaponColor()[2]*200,Owner:GetWeaponColor()[3]*200,255 ) )
	ent:SetOwner(Owner)
	ent:SetCreator(Owner)
	ent:SetPlayer(Owner)
	

	Owner:SetPos(Owner:GetPos() + Vector(0, 0, 16))
	Owner.SvistoSpawndelka = ent
	
	
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local Owner = self:GetOwner()
	
		if IsValid(Owner.SvistoSpawndelka) then
			Owner.SvistoSpawndelka:kys() 
			Owner:EmitSound("buttons/button14.wav") 
			self:Remove()
			local wps = Owner:GetWeapons()

			if IsValid(wps[1]) then
				Owner:SelectWeapon( wps[1] )
			end

		else Owner:EmitSound("buttons/button11.wav") end
	
	self:SetNextSecondaryFire(CurTime() + 0.3)
	
end

function SWEP:Think()

	if Reload < 6 then
		Reload = math.Clamp(Reload + 0.015, 0, 6) 
		self:SetHoldType("normal")
	else
		self:SetHoldType("slam")
	end

	local Owner = self:GetOwner()

	if Owner:GetNWBool("SpawnProtected") then
		Reload = 0
	end
end

local Instruction = {
	"ПКМ - Прибрати особисту точку спавна",
	"ЛКМ - Розташувати нову точку спавна"
}

function SWEP:DrawHUD() -- ця вся хуня з низу, так це інструкція, відчувайте блять вільно її скопіювати.
	if !CLIENT then return end

	
	local Xbox = ScrW() / 2
	local Ybox =  ScrH() / 1.05 / 1.05

	local Owner = self:GetOwner()

	local RemoveColor = math.sin(CurTime()*3.5)*50

	local Colored = Color(200+RemoveColor, 255, 200+RemoveColor, 120)

	

	// draw.RoundedBox( 5, Xbox/1.25, Ybox-100, Xbox/2.5 , 54, Color( 0, 0, 0, 150) )
	draw.RoundedBox( 5, Xbox - 384/2, Ybox-100,384 , 54, Color( 0, 0, 0, 150) )
	
	surface.SetDrawColor(Colored)
	// surface.DrawOutlinedRect(Xbox /1.25 , Ybox-100, Xbox/2.5 , 55, 3) 
	surface.DrawOutlinedRect(Xbox - 384/2 , Ybox-100, 384 , 55, 3) 
	

		draw.RoundedBox( 5, Xbox-185, Ybox-120, Ybox/35 + 25 , Ybox/150*2, Color( 0, 0, 0, 150) )

		surface.SetDrawColor(Colored)
		surface.DrawOutlinedRect(Xbox-185 , Ybox-120, Ybox/35 + 25 , Ybox/65, 2) 
		
	
		surface.SetMaterial( Material("icon16/flag_green.png") )
		surface.DrawRect( Xbox-185+4, Ybox-120+4, Reload * 13.6 / 1.85, Ybox/150 ) //Ybox/45 + 25 - 2
	
		draw.SimpleText(math.floor(Reload*16.7) .."%"  , "Trebuchet24", Xbox-185+27, Ybox-120-25, Colored, TEXT_ALIGN_CENTER)

	draw.SimpleText(self.PrintName, "Trebuchet24", Xbox, Ybox-140, Colored, TEXT_ALIGN_CENTER)

	draw.SimpleText(Instruction[1], "Trebuchet24", Xbox, Ybox-75, Colored , TEXT_ALIGN_CENTER)
	draw.SimpleText(Instruction[2], "Trebuchet24", Xbox, Ybox-100, Colored, TEXT_ALIGN_CENTER)
	
	draw.SimpleText(self:TrackProblems() , "Trebuchet24", Xbox, Ybox-175, Color(255, 100+RemoveColor*2, 100+RemoveColor*2, 120), TEXT_ALIGN_CENTER)

end