--[[-------------------------------------------------------------------------
	Це панелька на фізгані з інфой про обєкт
---------------------------------------------------------------------------]]
AddCSLuaFile()

local HookName = "PRSBOX.INFOPANEl"
local Physgun = "weapon_physgun"

local ENTITY = FindMetaTable("Entity")
local GetClass = ENTITY.GetClass

local GetPos = ENTITY.GetPos
local GetAngles = ENTITY.GetAngles
local GetVelocity = ENTITY.GetVelocity

local VECTOR = FindMetaTable("Vector")
local Distance = VECTOR.Distance
local Length = VECTOR.Length

local ANGLE = FindMetaTable("Angle")
local Forward = ANGLE.Forward
local Right	  = ANGLE.Right
local Up	  = ANGLE.Up
local RotateAroundAxis = ANGLE.RotateAroundAxis

local IsValid = IsValid

local function IsPhysgun( ent )
	return IsValid( ent ) and ( GetClass( ent ) == Physgun )
end

if SERVER then
	util.AddNetworkString("PRSBOX.INFPNL.Enable")
	util.AddNetworkString("PRSBOX.INFPNL.Data")
	util.AddNetworkString("PRSBOX.INFPNL.Clear")
	util.AddNetworkString("PRSBOX.INFPNL.Request")

	local function DontWantRecieve( ply )
		return ply:GetInfo( "prsbox_infopnl_enable" ) == "0"
	end

	hook.Add( "PlayerSwitchWeapon", HookName, function( ply, oldWeapon, newWeapon )
		if ( DontWantRecieve( ply ) ) then return end
		local bEnable

		if ( IsPhysgun( newWeapon ) ) then
			bEnable = true
		elseif ( IsPhysgun( oldWeapon ) ) then
			bEnable = false
		end

		if ( bEnable == nil ) then return end

		net.Start("PRSBOX.INFPNL.Enable")
			net.WriteBool( bEnable )
		net.Send( ply )
	end )

	local function SendData( ply, ent )
		if ( DontWantRecieve( ply ) ) then return end
		local phys = ent:GetPhysicsObject()
		local mass
		if IsValid( phys ) then
			mass = phys:GetMass()
		else
			mass = 0
		end
		net.Start("PRSBOX.INFPNL.Data")
			net.WriteEntity( ent )
			net.WriteFloat( mass )
		net.Send( ply )
	end

	hook.Add( "OnPhysgunPickup", HookName, SendData)

	net.Receive("PRSBOX.INFPNL.Request", function( len, ply )
		local sendply = net.ReadBool()
		local ent = (sendply and ply) or ply:GetEyeTrace().Entity or game.GetWorld()
		SendData( ply, ent )
	end)

	hook.Add( "OnPhysgunReload", HookName, function( wep, ply )
		if ( DontWantRecieve( ply ) ) then return end
		net.Start("PRSBOX.INFPNL.Clear")
		net.Send( ply )
	end)
else
	CreateConVar( "prsbox_infopnl_enable", "1", FCVAR_USERINFO )
	local ModelCvar = CreateConVar("prsbox_infopnl_model", "1", FCVAR_ARCHIVE )
	local XShiftCvar = CreateConVar("prsbox_infopnl_shift", "0", FCVAR_ARCHIVE, nil, -5, 5 )

	local TOptions = {
		[1] = {
			model = "models/props_wasteland/controlroom_monitor001b.mdl",
			pos = Vector(0, -1, -8.6),
			ang = Angle( 0, 90, -45 ),
			scrang = Angle( 90, 180 + 55, 90 + 45 ),
			scroff = Vector( 2.45, .15, .3 ),
			sizescale = .019,
			size = .231,
			SCRW = 256,
			SCRH = 210
		},
		[2] = {
			model = "models/kobilica/wiremonitorrtbig.mdl",
			pos = Vector(0, -1, -8.6),
			ang = Angle( 0, 90, -45 ),
			scrang = Angle( 90, 180 + 45, 90 + 45 ),
			scroff = Vector( 2.25, .3, 4.8 ), --Vector( 2.35, .4, 5.2 ),
			sizescale = .017,
			size = .231,
			SCRW = 256,
			SCRH = 250
		}
	}

	for index, tab in pairs(TOptions) do
		util.PrecacheModel( tab.model )
	end

	local SCRW, SCRH = 256, 210
	local HSCRW, HSCRH = SCRW * .5, SCRH * .5

	local eTarget = NULL
	local HitPos, HitStart
	local TargetIsPlayer, TargetIsWorld
	local eModel = game.GetMap()
	local eMass, eClass, eId
	local LastTrace = 0

	local function ResetEntity()
		eTarget = NULL
		NoiseAlpha = 255
	end

	local function RequestData( ply, self )
		net.Start("PRSBOX.INFPNL.Request")
			net.WriteBool( self or false )
		net.SendToServer()
	end

	local CEntModel, CEntPos, CEntAng, SCROff, SCRAng = nil, Vector(0,0,0), Angle(0,0,0), Vector(0,0,0), Angle(0,0,0)
	local CEntSize, ScrScale, CEntBone, XShift = .5, .1, "Base", XShiftCvar:GetFloat()
	local ParentBone

	if IsValid(CEnt) then CEnt:Remove() end

	local Noise = Material( "hud/nvg_noise" )

	local Font = "INFOPANEL"

	surface.CreateFont( Font, {
		font 		= "Arial",
		size 		= 24,
		weight 		= 10,
		scanlines 	= 3,
		antialias 	= false
	} )

	local uvend = SCRW / SCRH
	local NoiseAlpha = 0

	local idtext = "ID: %s"
	local postext = "Pos: %s, %s, %s"
	local angtext = "Ang: %s, %s, %s"
	local veltext = "Vel: %s, %s, %s"
	local masstext = "Mass: %s"
	local speedtext = "Speed: %s"
	local disttext = "Dist: %s"
	local format, floor = string.format, math.floor
	local SetDrawColor = surface.SetDrawColor
	local SetMaterial = surface.SetMaterial
	local DrawRect, DrawTexturedRectUV = surface.DrawRect, surface.DrawTexturedRectUV
	local DrawText = draw.DrawText
	local sub = string.sub
	local xspace = 10
	local yspace = 26

	local ClassLen, ClassLong
	local FormatedClass

	local LastPos = Vector(0,0,0)
	local LastAng = Angle(0,0,0)

	local function DrawVGUI()
		NoiseAlpha = math.Approach( NoiseAlpha, 70, RealFrameTime() * 60 )
		SetDrawColor( 50, 50, 50, 255 )
		DrawRect( 0, 0, SCRW, SCRH )
		SetDrawColor( 255, 255, 255, NoiseAlpha )
		SetMaterial( Noise )
		DrawTexturedRectUV( 0, 0, SCRW, SCRH, 0, 0, 1, uvend )

		if ( not IsValid( eTarget ) and (not TargetIsWorld) ) then ResetEntity() return end
		
		DrawText( eModel, Font, HSCRW, 0, color_white, TEXT_ALIGN_CENTER )

		local pos

		if ( not TargetIsWorld) then

			if ( ClassLong ) then
				local shift = ( (CurTime() - LastTrace) * 10) % ClassLen
				DrawText( sub( FormatedClass, 1 + shift, 24 + shift), Font, HSCRW, yspace, color_white, TEXT_ALIGN_CENTER )
			else
				DrawText( eClass, Font, HSCRW, yspace, color_white, TEXT_ALIGN_CENTER )
			end

			DrawText( format( idtext, eId ), Font, xspace, yspace * 2, color_white, TEXT_ALIGN_LEFT )

			pos = GetPos( eTarget )
			local posx, posy, posz = floor( pos.x ), floor( pos.y ), floor( pos.z )
			DrawText( format( postext, posx, posy, posz ), Font, xspace, yspace * 3, color_white, TEXT_ALIGN_LEFT )

			local ang = GetAngles( eTarget )
			local angx, angy, angz = floor( ang.x ), floor( ang.y ), floor( ang.z )
			DrawText( format( angtext, angx, angy, angz ), Font, xspace, yspace * 4, color_white, TEXT_ALIGN_LEFT )

			local vel = GetVelocity( eTarget )
			local velx, vely, velz = floor( vel.x ), floor( vel.y ), floor( vel.z )
			DrawText( format( veltext, velx, vely, velz ), Font, xspace, yspace * 5, color_white, TEXT_ALIGN_LEFT )

			DrawText( format( masstext, eMass ), Font, xspace, yspace * 6, color_white, TEXT_ALIGN_LEFT )
			DrawText( format( speedtext, floor( Length( vel ) ) ), Font, HSCRW + xspace, yspace * 6, color_white, TEXT_ALIGN_LEFT )
		end

		if ( HitPos or pos ) then
			local dist = math.Truncate( Distance( (HitPos or pos), HitStart ), 2 )
			DrawText( format( disttext, dist ), Font, xspace, yspace * ( TargetIsWorld and 2 or 7 ), color_white, TEXT_ALIGN_LEFT )
			if ( (TargetIsPlayer and eTarget ~= LocalPlayer()) and (dist > 2000) ) then
				ResetEntity()
			end
		end
	end

	local Start3D2D = cam.Start3D2D
	local End3D2D = cam.End3D2D

	local function CreateCEnt( vm )
		CEnt = ents.CreateClientProp()
		CEnt:SetModel( CEntModel or TOptions[1].model )
		CEnt:SetModelScale( CEntSize )
		CEnt:SetParent( vm )
		CEnt:Spawn()
		CEnt:SetNoDraw( true )

		CEnt.Draw = function( self, ScrPos, ScrAng, ScrScale )
			self:DrawModel()

			Start3D2D( ScrPos, ScrAng, ScrScale )
				DrawVGUI()
			End3D2D()
		end
	end

	local function Switch( index )
		index = math.Clamp( math.floor(index), 1, 2 )
		CEntModel = TOptions[index].model
		CEntPos:Set( TOptions[index].pos )
		CEntAng:Set( TOptions[index].ang )
		CEntSize = TOptions[index].size
		SCRAng = TOptions[index].scrang
		SCROff = TOptions[index].scroff
		ScrScale = TOptions[index].sizescale or .1
		SCRW, SCRH = TOptions[index].SCRW, TOptions[index].SCRH
		HSCRW, HSCRH = SCRW * .5, SCRH * .5
		if IsValid(CEnt) then CEnt:SetModel( CEntModel ) CEnt:SetModelScale( CEntSize ) end
	end

	Switch( ModelCvar:GetInt() )

	cvars.AddChangeCallback("prsbox_infopnl_model", function( name, old, new )
		Switch( tonumber( new ) )
	end)

	cvars.AddChangeCallback("prsbox_infopnl_shift", function(name, old, new)
		XShift = math.Clamp( tonumber(new) or 0, -5, 5  )
	end)

	concommand.Add("prsbox_infopnl_flushmodel", function()
		if IsValid(CEnt) then CEnt:Remove() end
		CEnt = nil
	end)

	local function DrawViewModel( vm, ply, weapon )
		local bHide

		if ( IsPhysgun( weapon ) ) then
			bHide = false
		else
			bHide = true
		end

		if ( bHide ) then return end

		if ( not IsValid( CEnt ) ) then
			CreateCEnt( vm )
		end

		if ( not ParentBone ) then
			ParentBone = vm:LookupBone( CEntBone )
		end

		local MBone = vm:GetBoneMatrix( ParentBone )

		local BPos
		local BAng

		if ( MBone ) then
			BPos = MBone:GetTranslation()
			BAng = MBone:GetAngles()
		else

			BPos = LastPos
			BAng = LastAng
		end

		LastPos:Set( BPos )
		LastAng:Set( BAng )

		local VForward 	= Forward( BAng )
		local VRight 	= Right( BAng )
		local VUp 		= Up( BAng )

		local Pos = BPos + VForward * CEntPos.x + VRight * CEntPos.y + VUp * CEntPos.z 

		Pos:Add( -vm:GetRight() * XShift )

		CEnt:SetPos( Pos )

		if ( CEntAng.y != 0 ) then
			RotateAroundAxis( BAng, VUp, 	CEntAng.y )
		end

		if ( CEntAng.p != 0 ) then
			RotateAroundAxis( BAng, VRight, 	CEntAng.p )
		end

		if ( CEntAng.r != 0 ) then
			RotateAroundAxis( BAng, VForward, CEntAng.r )
		end

		CEnt:SetAngles( BAng )

		local EForward = Forward( BAng )
		EForward:Mul( 4.01 )
		Pos:Add( EForward )

		if ( SCRAng.r != 0 ) then
			RotateAroundAxis( BAng, VForward, SCRAng.r )
		end

		if ( SCRAng.y != 0 ) then
			RotateAroundAxis( BAng, VUp, 	SCRAng.y )
		end

		if ( SCRAng.p != 0 ) then
			RotateAroundAxis( BAng, VRight, 	SCRAng.p )
		end

		Pos:Add( VForward * SCROff.x + VRight * SCROff.y + VUp * SCROff.z  )

		CEnt:Draw( Pos, BAng, ScrScale )
	end

	local hookname = "PreDrawViewModel"
	local lastReq = -1

	local function Tick()
		local ply = LocalPlayer()
		if ( ply:KeyPressed( IN_RELOAD ) and lastReq < CurTime() ) then
			if IsValid( eTarget ) then
				ResetEntity()
				lastReq = CurTime() + .2
			else
				lastReq = CurTime() + .7
				RequestData( ply, true )
			end
		elseif ( ply:KeyPressed( IN_ATTACK2 ) ) then
			RequestData( ply )
		end
	end

	cvars.AddChangeCallback("prsbox_infopnl_enable", function( name, old, new )
		if (new != "0") then 
			hook.Add( hookname, HookName, DrawViewModel)
			hook.Add( "Tick", HookName, Tick )
			NoiseAlpha = 0		
			return 
		end
		hook.Remove( hookname, HookName )
		hook.Remove( "Tick", HookName )
		if IsValid(CEnt) then CEnt:Remove() end
	end)

	local function InfoPanelFunc()
		local bEnable = net.ReadBool()
		if ( bEnable ) then
			hook.Add( hookname, HookName, DrawViewModel)
			hook.Add( "Tick", HookName, Tick )
			NoiseAlpha = 0
			return
		end
		hook.Remove( hookname, HookName )
		hook.Remove( "Tick", HookName )
	end

	net.Receive("PRSBOX.INFPNL.Enable", InfoPanelFunc)

	local function InfoPanelPick()
		local ent = net.ReadEntity()
		eMass = math.Truncate( net.ReadFloat(), 3 )

		if ent.AttachedEntity then ent = ent.AttachedEntity end
		TargetIsWorld = ent == game.GetWorld()

		if ( not IsValid( ent ) and not TargetIsWorld ) then return end

		if ( (not TargetIsWorld) and ent == eTarget ) then return end

		TargetIsPlayer = ent:IsPlayer()
		
		eClass = ( TargetIsPlayer and ent:GetName() ) or GetClass( ent )

		ClassLen = #eClass
		ClassLong = ClassLen > 24
		if ( ClassLong ) then
			FormatedClass = eClass .. " " .. eClass
		end

		NoiseAlpha = 255
		LastTrace = CurTime()
		eTarget = ent
		eId = ent:EntIndex()

		HitPos = ( TargetIsWorld and LocalPlayer():GetEyeTrace().HitPos ) or nil
		HitStart = LocalPlayer():GetShootPos()

		eModel = ( TargetIsWorld and game.GetMap() ) or string.GetFileFromFilename( string.StripExtension( ent:GetModel() ) )
	end

	net.Receive("PRSBOX.INFPNL.Data", InfoPanelPick)

	net.Receive("PRSBOX.INFPNL.Clear", ResetEntity)
end