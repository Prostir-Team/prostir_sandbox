util.AddNetworkString("PRSBOX_HUD_DamageNotify")

hook.Add( "EntityTakeDamage", "Prsbox_Hud_".."EntityTakeDamage", function( target, dmginfo )
	if( target:IsPlayer() ) then
		net.Start( "PRSBOX_HUD_DamageNotify" )

		net.WriteUInt( dmginfo:GetDamageType(), 8 )
		net.WriteUInt( dmginfo:GetDamage(), 32 )
		net.WriteEntity( dmginfo:GetAttacker() )

		net.Send( target )
	end
end )