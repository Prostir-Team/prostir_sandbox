if ( CLIENT ) then return end -- TODO: нахуя всі модулі йдуть на клієнт??????????

local ents_FindByClass = ents.FindByClass
local ents_FindByName = ents.FindByName
local ents_FindInPVS = ents.FindInPVS
local ents_Create = ents.Create
local IsValid = IsValid

do --				Вимкнення порталів в "нікуди" при видалені дверей

	local DoorSlaves, DoorAreaportals = {}, {}

	local function PrecacheDoorThings()
		local doorstable, areaportals = ents_FindByClass("prop_door_rotating"), ents_FindByClass("func_areaportal")
		for num, door in ipairs(doorstable) do
			local svalename = door:GetInternalVariable("slavename")
			if svalename == "" then continue end
			local svaleTable = ents_FindByName(svalename)
			local slave = svaleTable[1]
			if IsValid(slave) then
				DoorSlaves[door] = slave
			end
		end

		for num, areaportal in ipairs(areaportals) do
			if !IsValid(areaportal) then continue end
			local doorname = areaportal:GetInternalVariable("target")
			local linkeddoors = ents_FindByName(doorname)
			for _,door in ipairs(linkeddoors) do
				local slave = DoorSlaves[door]
				if slave then
					DoorAreaportals[door] = areaportal
					DoorAreaportals[slave] = areaportal
					continue
				end
				DoorAreaportals[door] = areaportal
			end
		end
	end

	local DoorClasses = {
		["func_door"] = true,
		["func_door_rotating"] = true,
		["prop_door_rotating"] = true
	}

	local CleanupingMap = false

	hook.Add("PreCleanupMap","PRSBOX.PreCleanupMap",function() CleanupingMap = true end)
	hook.Add("PostCleanupMap","PRSBOX.PostCleanupMap",function() CleanupingMap = false PrecacheDoorThings() end)

	function DoorAreaportalDisable(door)
		if (CleanupingMap) then return end
		if !DoorClasses[door:GetClass()] then return end
		local areaportal = DoorAreaportals[door]
		if !areaportal then return end
		areaportal:Fire("Open")
		areaportal:SetSaveValue("target","")
	end

	hook.Add("EntityRemoved","PRSBOX.EntityDelete",DoorAreaportalDisable) 
end

do --			Секс з дверима
	local BreakableDoors = CreateConVar("prsbox_breakable_doors", "1", FCVAR_ARCHIVE)
	
	local DoorsHealth = 800

	local function BreakDoor( prop, dmginfo )
		if !BreakableDoors:GetBool() then return end

		if prop:GetClass() == "prop_door_rotating" then
			if !IsValid(prop) then return false end 
			local dpos = dmginfo:GetDamagePosition()

			local handlebone = prop:LookupBone("handle")

			if ( not handlebone ) then return end

			local bpos = prop:GetBonePosition(handlebone)

			if bpos == prop:GetPos() then
				bpos = prop:GetBoneMatrix(handlebone):GetTranslation()
			end

			local dscl = 1
			if bpos:Distance(dpos) < 7 then 
				prop:EmitSound( "physics/metal/metal_sheet_impact_hard6.wav" )
				dscl = 3 
			end

			if prop:Health() < 1 then prop:SetHealth(DoorsHealth) end
			prop:SetHealth(prop:Health() - dmginfo:GetDamage() * dscl)

			if prop:Health() <= 0 && !prop.dprop then
				prop.dprop = true
				prop:SetNoDraw(true)
				prop:SetNotSolid(true)
				local ply = dmginfo:GetAttacker()

				if IsValid(ply) and ply:IsPlayer() then
					hook.Run("PRSBOX.BreakDoor", ply)
				end
				
				local dprop = ents_Create( "prop_physics" )
				dprop:SetCollisionGroup(COLLISION_GROUP_NONE)
				
				dprop:SetPos( prop:GetPos() + Vector(0, 0, 1))
				dprop:SetAngles( prop:GetAngles() ) 
				dprop:SetModel( prop:GetModel() )
				dprop:SetSkin( prop:GetSkin() ) 
				prop:Extinguish()

				local objmaterial = prop:GetPhysicsObject():GetMaterial()

				if string.find( objmaterial:lower(), "wood" ) then
					prop:EmitSound( "physics/wood/wood_crate_break3.wav" )
				elseif string.find( objmaterial:lower(), "metal" ) then
					prop:EmitSound( "physics/metal/metal_sheet_impact_hard6.wav" )
				else
					prop:EmitSound( "physics/wood/wood_crate_break2.wav" )
				end

				prop:Remove()
				dprop:Spawn()
				local physobj = dprop:GetPhysicsObject()

				physobj:SetVelocity(dmginfo:GetDamageForce() / 50)

				dprop:SetLocalAngularVelocity((dprop:GetPos()-dmginfo:GetDamagePosition()):Angle())
				dprop:SetHealth( DoorsHealth / 2 )
				dprop:SetName("BREAKABLEDOORPHYSPROP")
			end
			return true
		end
		if prop:GetClass() == "prop_physics" then
			if prop:GetName() != "BREAKABLEDOORPHYSPROP" then return false end
			prop:SetHealth(prop:Health() - dmginfo:GetDamage())
			if prop:Health() <= 0 then
				local physobj = prop:GetPhysicsObject()
				local objmaterial = physobj:GetMaterial()
				if string.find( objmaterial:lower(), "wood" ) then
					prop:EmitSound( "physics/wood/wood_crate_break3.wav" )
				elseif string.find( objmaterial:lower(), "metal" ) then
					prop:EmitSound( "physics/metal/metal_sheet_impact_hard8.wav" )
				else
					prop:EmitSound( "physics/wood/wood_crate_break2.wav" )
				end

				prop:Remove()
			end
		end
	end

	hook.Add("PostEntityTakeDamage","PRSBOX.BreakDoor.Hook", BreakDoor)

	local function ModifyDoors()
		for k,v in ipairs( ents_FindByClass("prop_door_rotating") ) do
			local defspd = v:GetInternalVariable("Speed")
			v.dprop = nil
			v.defspd = defspd
			if defspd < 200 then
				v:SetSaveValue( "Speed", 200 )
			end
			v:SetHealth(DoorsHealth)
		end
	end

	concommand.Add("g_ModifyDoors", ModifyDoors)

	hook.Add( "InitPostEntity", "PRSBOX.BreakDoorInit.Hook", ModifyDoors)

	function StealthOpenDoor( self )
	    if !self.stealthopen then
	        self.stealthopen = true
	        self.oldspeed = self:GetInternalVariable( "Speed" )
	        self:SetSaveValue( "Speed", self.oldspeed / 2 )

	        local uniqueIdent = self:EntIndex()

	        timer.Create( "resetdoorstealthval" .. uniqueIdent, 4 * ( self:GetInternalVariable( "speed" ) / ( self:GetClass() == "prop_door_rotating" && self:GetInternalVariable( "distance" ) || self:GetInternalVariable( "m_flMoveDistance" ) ) ), 1, function()
	        	if !IsValid(self) then return end

	           	local SaveTbl = self:GetSaveTable()

	           	if SaveTbl.m_eDoorState != 1 && SaveTbl.m_eDoorState != 3 then
	            	self:SetSaveValue( "Speed", self.oldspeed )
	            	self.stealthopen = false
	         	else
	                timer.Create( "checkfordoorreset" .. self:EntIndex(), 0.1, 0, function()
	                	if !IsValid( self ) then return end

	                	local SaveTbl = self:GetSaveTable()

	                    if SaveTbl.m_eDoorState != 1 && SaveTbl.m_eDoorState != 3 then
	                        self:SetSaveValue( "Speed", self.oldspeed )
	                        self.stealthopen = false
	                        timer.Remove( "checkfordoorreset" .. self:EntIndex() )
	                    end
	                end )
	            end
	        end )
	    end
	end

	local function DisableQuietDoor( door )
		if door.oldspeed == nil then return end
		door:SetSaveValue( "Speed", door.oldspeed )
		door.stealthopen = false
		local uniqueIdent = door:EntIndex()

		timer.Remove( "resetdoorstealthval" .. uniqueIdent )
		timer.Remove( "checkfordoorreset" .. door:EntIndex() )
	end

	function IsDoor( door )
		local class = door:GetClass() 
	    return class == "prop_door_rotating" || class == "func_door_rotating"
	end

	hook.Add( "AcceptInput", "PRSBOX.StealthDoors", function( ent, inp, act, ply, val )
		if inp == "Use" then
			if !IsDoor(ent) then return end
		    if ply:Crouching() || ply:KeyDown(IN_WALK) then
		        StealthOpenDoor(ent)
		        if ent:GetInternalVariable( "slavename" ) then
		            for k,v in ipairs( ents_FindByName( ent:GetInternalVariable( "slavename" ) ) ) do
		                StealthOpenDoor(v)
		            end
		        end
		    else
		    	DisableQuietDoor(ent)
		    	if ent:GetInternalVariable( "slavename" ) then
		            for k,v in ipairs( ents_FindByName( ent:GetInternalVariable( "slavename" ) ) ) do
		                DisableQuietDoor(v)
		            end
		        end
		    end
		end
	end )

	hook.Add( "EntityEmitSound", "PRSBOX.SuppressDoorSound", function( t )
		local ent = t.Entity
		if IsDoor(ent) && ent.stealthopen then
	        t.Volume = t.Volume * 0.3
	        return true
		end  
	end )
end