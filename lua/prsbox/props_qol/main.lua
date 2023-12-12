--[[-------------------------------------------------------------------------
	Проп пуш, проп флай, гоустинг пропів, заборона білдерам піднімати речі\тикати кнопки
---------------------------------------------------------------------------]]

if ( CLIENT ) then return end -- TODO: нахуя всі модулі йдуть на клієнт??????????

local fib, CurTime, ipairs, IsValid, next = ents.FindInBox, CurTime, ipairs, IsValid, next

local VECTOR = FindMetaTable("Vector")
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

local GetClass = ENTITY.GetClass
local Alive = PLAYER.Alive
local InVehicle = PLAYER.InVehicle
local GetObserverMode = PLAYER.GetObserverMode
local GetPos = ENTITY.GetPos
local WorldSpaceAABB = ENTITY.WorldSpaceAABB

local OBBMins, OBBMaxs = ENTITY.OBBMins, ENTITY.OBBMaxs
local GetMoveType = ENTITY.GetMoveType

local IsSolid = ENTITY.IsSolid
local SetCollisionGroup = ENTITY.SetCollisionGroup
local GetCollisionGroup = ENTITY.GetCollisionGroup

local SetRenderMode = ENTITY.SetRenderMode
local GetRenderMode = ENTITY.GetRenderMode
local GetCreator = ENTITY.GetCreator
local SetCreator = ENTITY.SetCreator
local GetColor = ENTITY.GetColor
local SetColor = ENTITY.SetColor
local GetMaterial = ENTITY.GetMaterial
local SetMaterial = ENTITY.SetMaterial
local GetPhysicsObject = ENTITY.GetPhysicsObject
local GetChildren = ENTITY.GetChildren
local EntIndex = ENTITY.EntIndex
local CreatedByMap = ENTITY.CreatedByMap
local IsWorld = ENTITY.IsWorld
local IsNPC = ENTITY.IsNPC

local VecSet = VECTOR.Set
local VecAdd = VECTOR.Add
local VecSub = VECTOR.Sub
local VecMul = VECTOR.Mul
local LengthSqr = VECTOR.LengthSqr

local SetUnpacked = VECTOR.SetUnpacked

local entsFindInBox = ents.FindInBox
local entsFindByClass = ents.FindByClass

local utilTraceHull = util.TraceHull
local playerIterator, playerCount = player.Iterator or player.GetAll, player.GetCount
local coroutine_yield, coroutine_resume, coroutine_create = coroutine.yield, coroutine.resume, coroutine.create
local timerCreate, timerSimple, timerRemove = timer.Create, timer.Simple, timer.Remove

local player_class = "player"

local function IsPlayer( ent )
	if ( not IsValid( ent ) ) then return false end
	return GetClass( ent ) == player_class
end

do
	--[[local timetable = {}

	local function notifyplayer(ply)
		timetable[ply] = timetable[ply] or 0
		if timetable[ply] > CurTime() then return end
		timetable[ply] = CurTime() + 5
		net.Start("PRSBOX.NOTIFYGHOST")
		net.Send(ply)
	end]]--

	-- TODO: релізувати це для

	function ENTITY:Ghost()
		if ( IsPlayer( self ) ) then return end
		if ( self:IsGhosted() ) then return end
		--if ( self.LVS ) then return end

		self.GHOSTDATA = {}

		self.GHOSTDATA.CollisionGroup = GetCollisionGroup( self )

		local PropColor = GetColor( self ) 

		self.GHOSTDATA.OldAlpha = PropColor.a
		self.GHOSTDATA.Owner = GetCreator( self )
		self.GHOSTDATA.RenderMode = self:GetRenderMode()

		SetCollisionGroup( self, COLLISION_GROUP_WORLD )

		PropColor.a = 50

		SetRenderMode( self, RENDERMODE_TRANSCOLOR )

		SetColor( self, PropColor )

		--notifyplayer( self.GHOSTDATA.Owner )

		if ( IsValid( GetPhysicsObject( self ) ) and self:IsPlayerHolding() or self:IsVehicle() ) then
			GetPhysicsObject( self ):EnableMotion( false )
		end
	end

	function ENTITY:UnGhost( nobase )
		local GHOSTDATA = self.GHOSTDATA
		if ( GHOSTDATA == nil ) then return end
		if ( IsPlayer( self ) ) then return end

		if ( self.GetBaseEnt and not nobase ) then 
			self:GetBaseEnt():UnGhost() 
		end

		local childs = GetChildren( self )

		for _, e in ipairs( childs ) do
			e:UnGhost()
		end

		if ( self.Wheels ) then
			for _,w in ipairs( self.Wheels ) do
				w:UnGhost( true )
			end
		end

		if ( GHOSTDATA == nil ) then return end

		SetCollisionGroup( self, GHOSTDATA.CollisionGroup )

		local c = GetColor( self )
		c.a = GHOSTDATA.OldAlpha

		SetRenderMode( self, GHOSTDATA.RenderMode )

		if ( GHOSTDATA.OldMat ) then
			SetMaterial( self, GHOSTDATA.OldMat)
		end

		SetColor( self, c )

		SetCollisionGroup( self, GHOSTDATA.CollisionGroup )

		self.GHOSTDATA = nil
	end

	function ENTITY:IsGhosted()
		return self.GHOSTDATA ~= nil
	end
end

do --Проп флай
	local tracehull_output = {}

	local tracehull = {
		start = true,
		endpos = Vector(),
		mins = Vector(-16,-16,0),
		maxs = Vector(16,16,72),
		output = tracehull_output
	}

	local function FindPlayersInBox( vCorner1, vCorner2, ent )
		local tEntities = fib( vCorner1, vCorner2 )
		local iPlayers = 0
		
		for _, ply in ipairs( tEntities ) do
			if ( not IsPlayer( ply ) ) then continue end
			if ( ply:GetBuildMode() ) then continue end
			if ( not Alive( ply ) ) then continue end
			if ( InVehicle( ply ) ) then continue end
			if ( GetObserverMode( ply ) > 0 ) then continue end

			tracehull.start = GetPos( ply )
			VecSet( tracehull.endpos, tracehull.start )
			tracehull.endpos.z = tracehull.endpos.z - 72

			tracehull.filter = ply

			utilTraceHull( tracehull )

			if ( not tracehull_output.Hit ) then continue end
			if ( tracehull_output.Entity ~= ent ) then continue end

			iPlayers = iPlayers + 1
		end
		
		return iPlayers
	end

	local lt = CurTime()

	local v1, v2 = Vector(), Vector()

	local function PickenUp(ply, ent)
		if ( GetCollisionGroup( ent ) == COLLISION_GROUP_WORLD ) then return end

		local mi2, ma2 = WorldSpaceAABB( ent )

		SetUnpacked( v1, mi2.x, mi2.y, mi2.z )
		SetUnpacked( v2, ma2.x, ma2.y, ma2.z + 86 )

		local ptbl = FindPlayersInBox(v1, v2, ent)

		if ( ptbl > 0 ) then
			if ( lt <= CurTime() ) then
				ply:ChatPrint("Prop fly заборонений у pvp режимі.")
				lt = CurTime() + 3
			end

			return false 
		end
	end

	hook.Add( "PhysgunPickup", "PRSBOX.PhysgunPickup", PickenUp )
end

do -- не дає хуйнею страждати
	local BanNames = nil

	local banClass = { -- TODO додати обєкти зброї з мв бази?
		-- Сюди йдуть класи які білдерам заборонено використовувати (+use)
		["cw_dropped_weapon"] = true
	}

	local function AddToBlackList()
		local CurMap = game.GetMap()

		if CurMap == "gm_lacour_islands_fog" then --Поки зробив так, коли буде їх більше то зробимо конфіг
			BanNames = {
				["shelter_button"] = true,
				["shelter_button_outside"] = true,
				["island2_button"] = true,
				["rifle_trigger"] = true,
				["generator_1button"] = true,
				["und_keyboard"] = true,
				["generator_2button"] = true,
				["church_btn"] = true,
				["obs_button"] = true
			}
		end

		if ( not BanNames ) then hook.Remove( "PlayerUse", "PRSBOX.BuildUse") return end

		for i, name in ipairs(BanNames) do
			BanNames[name] = true
			BanNames[i] = nil
		end
	end

	hook.Add( "InitPostEntity", "PRSBOX.BuildUse", AddToBlackList )

	hook.Add( "PlayerUse", "PRSBOX.BuildUse", function( ply, ent )
		if ply:GetBuildMode() then
			if banClass[ GetClass( ent ) ] then print("BLOCKED", ent ) return false end
			local name = ent:GetName()
			if BanNames and BanNames[ name ] then print("BLOCKED", name ) return false end
		end
	end )

	hook.Add( "PlayerCanPickupWeapon", "PRSBOX.BuildPickUp", function( ply, weapon )
	    if ( not ply:GetBuildMode() ) then return end

    	local Creator = weapon:GetCreator()

    	if ( IsValid(Creator) and Creator != ply ) then
    		return false
    	end
	end )

	hook.Add( "GravGunPickupAllowed", "PRSBOX.GravGunPickup", function( ply, ent )
		if ( ply:GetBuildMode() ) then return false end
	end )

	hook.Add( "AllowPlayerPickup", "PRSBOX.GravGunPunt", function( ply, ent )
	    if ( ply:GetBuildMode() and GetClass( ent ) ~= "prop_physics" ) then return false end
	end )
end

do -- Анти стак
	local Noclip = MOVETYPE_NOCLIP

	local Offset1, Offset2 = Vector(1,1,1), Vector(6,6,6)

	local function AntistuckThink()
		while true do
			if ( playerCount() < 1 ) then
				coroutine_yield()
			else
				for _, v in ipairs( playerIterator() ) do
					coroutine_yield()

					if ( not IsValid( v ) ) then continue end
					if ( not Alive( v ) ) then continue end
					if ( GetMoveType( v ) ~= MOVETYPE_WALK ) then continue end

					if InVehicle( v ) then 
						v:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE ) 
						continue 
					end

					local Stuck = nil

					local Offset

					if ( v.Stuck ) then 
						Offset = Offset1 
					else 
						Offset = Offset2 
					end

					local pos = GetPos(v)

					local vmin = OBBMins(v)

					VecAdd( vmin, pos )
					VecAdd( vmin, Offset )

					local vmax = OBBMaxs(v)

					VecAdd( vmax, pos )
					VecSub( vmax, Offset )

					local tbl = entsFindInBox( vmin, vmax )

					for k, ent in ipairs( tbl ) do
						if ( ent == v ) then continue end

						if ( GetCollisionGroup(ent) == COLLISION_GROUP_WORLD ) then continue end

						if ( not IsPlayer( ent ) ) then continue end
						if ( not Alive( ent ) ) then continue end

						SetCollisionGroup( v, COLLISION_GROUP_DEBRIS )

						local entpos = GetPos( ent )
						local v1, v2 = -(entpos - pos), -(pos - entpos)

						v1.z = 0 
						v2.z = 0

						v:SetVelocity( v1 ) 
						ent:SetVelocity( v2 )

						Stuck = true 
						v.Stuck = true
					end

					if ( not Stuck ) then 
						v.Stuck = false
						SetCollisionGroup( v, COLLISION_GROUP_PLAYER )
					end
				end
			end
		end
	end

	local co

	hook.Add( "Think", "PRSBOX.AntiStuckThink", function() --Перевірка колізії буде відбуватися лише на одного гравця за тік
		if ( ( not co ) or ( not coroutine_resume( co ) ) ) then
			co = coroutine_create( AntistuckThink )
			coroutine_resume( co )
		end
	end )
end

do -- Захист від блокування спавнів\телепортів на мапі
	local HullVMin, HullVMax = Vector(-16, -16, 0), Vector(16, 16, 72)

	local SecureEnts, SecureEntsClasses = {}, {
		"info_player_start",
		"info_player_terrorist",
		"info_player_counterterrorist",
		"info_teleport_destination",
		--"sent_spawnpoint",
		--"trigger_teleport" TODO
	}

	local function UpdateEnts()
		local i = 1
		SecureEnts = {}

		for _,class in ipairs( SecureEntsClasses ) do
			for __,ent in ipairs( entsFindByClass( class ) ) do
				SecureEnts[i] = ent
				i = i + 1
			end
		end
	end

	local function displayer()
		while true do
			if ( not next( SecureEnts ) ) 
				then coroutine_yield() 
			else
				for _, ent in ipairs( SecureEnts ) do
					coroutine_yield()

					if ( IsValid( ent ) ) then
						local Pos = GetPos( ent )
						local FoundEnts = entsFindInBox( Pos + HullVMin, Pos + HullVMax )

						for _, entity in ipairs( FoundEnts ) do
							if ( IsPlayer( entity ) or IsNPC( entity ) ) then continue end
							if ( CreatedByMap( entity ) ) then continue end
							entity:Ghost()
						end
						--debugoverlay.Cross( Pos, 15, 2, nil, true )
						--debugoverlay.Box( Pos, HullVMin, HullVMax, 2, Color( 255, 255, 255 ) )
					end
				end
			end
		end
	end

	hook.Add( "InitPostEntity", "PRSBOX.AntiBlocker", UpdateEnts )
	hook.Add( "PostCleanupMap", "PRSBOX.AntiBlocker", UpdateEnts )

	if ( IsValid( Entity( 1 ) ) ) then
		UpdateEnts()
	end

	--[[local function AddToSecur( ent )
		if ( not IsValid( ent ) ) then return end
		local class = GetClass( ent )
		if ( not SecureEntsClasses[class] ) then return end

		SecureEnts[#SecureEnts+1] = ent
	end

	hook.Add( "OnEntityCreated", "PRSBOX.AntiBlocker", AddToSecur )]]--

	local NextThinkT = 0
	local co

	hook.Add( "Think", "PRSBOX.AntiBlocker", function()
		if ( NextThinkT > CurTime() ) then return end
		if ( ( not co ) or ( not coroutine_resume( co ) ) ) then
			co = coroutine_create( displayer )
			coroutine_resume( co )
		end
		NextThinkT = 0.2 + CurTime()
	end )
end

do -- Логіка захиту від проппшу
	local ghostIdString = "UNGHOSTTIMER"
	local PhysicsCollideCallback = "PhysicsCollide"

	local function PhysicsCollide( ent, data )
		print( ent )
		if ( not IsValid( data.HitEntity ) ) then return end
		if ( IsWorld( data.HitEntity ) or CreatedByMap( data.HitEntity ) or not data.HitObject:IsMotionEnabled() ) then return end


		if ( ( LengthSqr( data.TheirNewVelocity ) - LengthSqr( data.TheirOldVelocity ) ) > ( 600 * 600 ) ) then
			VecMul( data.TheirOldVelocity, 0.01 )
			data.HitObject:SetVelocity( data.TheirOldVelocity )
			timerSimple( 0, function()
				if ( not IsValid( ent ) ) then return end
				ent:Ghost()
			end )
		end
	end

	local function RemovePhysCallback( ent )
		if ( not IsValid( ent ) ) then return end

		if ( ent.PPPHYSCOLLCBACK ) then
			ent:RemoveCallback( PhysicsCollideCallback, ent.PPPHYSCOLLCBACK )
			ent.PPPHYSCOLLCBACK = false
		end

		ent:UnGhost()
	end

	hook.Add("OnPhysgunPickup", "PRSBOX.PropPush", function(ply, ent)
		if ( IsPlayer( ent ) or IsNPC( ent ) ) then return end

		local entid = EntIndex( ent )

		if ( not ent.PPPHYSCOLLCBACK ) then
			ent.PPPHYSCOLLCBACK = ent:AddCallback( PhysicsCollideCallback, PhysicsCollide)
		else
			timerRemove( entid .. ghostIdString )
		end	
	end )

	hook.Add("PhysgunDrop", "PRSBOX.PropPush", function(ply, ent)
		if ( IsPlayer( ent ) or IsNPC( ent ) ) then return end

		local entid = EntIndex( ent )

		timerCreate( entid .. ghostIdString, 3, 1, function() RemovePhysCallback( ent ) end )
	end )
end