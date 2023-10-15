AddCSLuaFile()

if ( SERVER ) then
	local npc_grenade_bugbait = "npc_grenade_bugbait"
	local shitradius = 50
	local shitradsqr = shitradius * shitradius
	local ShitColor = Color( 102, 51, 0, 240 )

	local CTakeDamageInfo
	local function CreateTakeDamage( owner, ent, pos )
		if ( CTakeDamageInfo ) then return CTakeDamageInfo end
		CTakeDamageInfo = DamageInfo()
		CTakeDamageInfo:SetAttacker( owner )
		CTakeDamageInfo:SetInflictor( ent )
		CTakeDamageInfo:SetDamage( 5 + math.random(1, 6) )
		CTakeDamageInfo:SetReportedPosition( pos )
		CTakeDamageInfo:SetDamageType( DMG_GENERIC )
		return CTakeDamageInfo
	end

	local function ExplodeShit( ent )
		if ( not IsValid( ent ) ) then return end
		local owner = ent:GetOwner()
		if ( not IsValid( owner ) ) then return end
		local pos = ent:GetPos()
		pos.z = pos.z + 4

		CTakeDamageInfo = nil

		for i, ply in ipairs( player.GetAll() ) do
			local plyPos = ply:GetPos()
			local dist = math.min( plyPos:DistToSqr(pos), ply:GetShootPos():DistToSqr(pos) )

			if ( dist > shitradsqr ) then
				plyPos.z = plyPos.z + 42
				if ( plyPos:DistToSqr(pos) > shitradsqr ) then continue end
			end

			ply:TakeDamageInfo( CreateTakeDamage( owner, ent, pos ) )
			ply:ScreenFade( SCREENFADE.IN, ShitColor, .5, .9 )
		end
	end

	local function EntityCreated( ent )
		local class = ent:GetClass()
		if ( class != npc_grenade_bugbait ) then return end

		ent:CallOnRemove( npc_grenade_bugbait, ExplodeShit, ent )
	end

	hook.Add( "OnEntityCreated", "PRSBOX.SHITREPLACER", EntityCreated )
else
	language.Add( "npc_grenade_bugbait", "Гівно" )
	killicon.Add( "npc_grenade_bugbait", "HUD/killicons/bugbait", Color( 255, 255, 255, 255 ) )
end
