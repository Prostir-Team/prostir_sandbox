--  			03.11.2023  			Isemenuk27
util.AddNetworkString( "PRSBOX.CooldownUpdate" )

local Cooldowns = PRSBOX.Cooldowns
local SharedCooldowns = PRSBOX.SharedCooldowns

local _CDown, _CDShared, _CDCaters = {}, {}, {} --Технічні таблиці

local HookName = "PRSBOX.COOLDOWN"
local hookadd, curtime = hook.Add, CurTime

local function AddHook( id, func ) 
	hookadd( id, HookName, func )
end

local function IsInCooldown( ply, id )
	if ( !_CDown[ply] ) then return false end
	if ( !_CDown[ply][id] ) then return false end
	return _CDown[ply][id] > curtime()
end

local function IsCategoryInCooldown( ply, id )
	if ( !_CDCaters[ id ] ) then return false end
	return IsInCooldown( ply, id )
end

local function IsClassInCooldown( ply, id )
	--if ( _CDCaters[ id ] ) then return false end
	return IsInCooldown( ply, id )
end

local function ApplyCooldown( ply, id )
	if ( not _CDown[ply] ) then
		_CDown[ply] = {}
	end

	local time = math.ceil( curtime() + Cooldowns[id] )

	if ( _CDShared[id] ) then
		for _, v in ipairs(_CDShared[id]) do
			_CDown[ply][v] = time
		end
	end

	net.Start( "PRSBOX.CooldownUpdate" )
		net.WriteString( id )
		net.WriteUInt( Cooldowns[id], 10 )
		net.WriteBool( _CDCaters[ id ] != nil )
	net.Send( ply )

	_CDown[ply][id] = time
end

local function DoCooldown( ply, class, Category )
	--print( IsCategoryInCooldown( ply, Category ) )
	if ( Cooldowns[ class ] ) then
		if ( IsClassInCooldown( ply, class ) ) then
			return false
		end

		ApplyCooldown( ply, class )
	elseif ( Cooldowns[ Category ] ) then
		if ( IsCategoryInCooldown( ply, Category ) ) then
			return false
		end

		ApplyCooldown( ply, Category )
	end

	return
end

local function SentSpawn( ply, class )
	local entTable = scripted_ents.GetStored( class )
	local t = entTable.t
	local Category = t.Category

	--PrintTable( t )

	return DoCooldown( ply, class, Category )
end

AddHook( "PlayerSpawnSENT", SentSpawn ) 

local function ClearTable( ply )
	_CDown[ply] = nil
end

AddHook( "PlayerDisconnected", ClearTable ) 

local insert = table.insert

for _, t in ipairs( SharedCooldowns ) do
	for _, v in ipairs( t ) do
		_CDShared[v] = t
	end
end

for c, _ in pairs( Cooldowns ) do
	_CDCaters[c] = true
end
