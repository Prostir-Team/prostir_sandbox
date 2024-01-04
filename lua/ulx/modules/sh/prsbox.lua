local CATEGORY_NAME = "Prostir"

------------------------------ Set ------------------------------
function ulx.setbuild( calling_ply, target_plys, amount )
	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:GetBanBuild() then continue end
		v:SetBuildMode()
		table.insert( affected_plys, v )
	end

	ulx.fancyLogAdmin( calling_ply, "#A Enabled build mode for #T", affected_plys, amount )
end

local setbuild = ulx.command( CATEGORY_NAME, "ulx setbuild", ulx.setbuild, "!setbuild" )
setbuild:addParam{ type=ULib.cmds.PlayersArg }
setbuild:defaultAccess( ULib.ACCESS_ADMIN  )
setbuild:help( "Виставляє режим гри будівельника." )

function ulx.setpvp( calling_ply, target_plys, amount )
	local affected_plys = {}

	for i = 1, #target_plys do
		local v = target_plys[ i ]
		if !v:GetBuildMode() then continue end
		v:SetMoveType(MOVETYPE_WALK)
		v:SetPvpMode()
		table.insert( affected_plys, v )
	end

	ulx.fancyLogAdmin( calling_ply, "#A Disabled build mode for #T", affected_plys, amount )
end

local setpvp = ulx.command( CATEGORY_NAME, "ulx setpvp", ulx.setpvp, "!setpvp" )
setpvp:addParam{ type=ULib.cmds.PlayersArg }
setpvp:defaultAccess( ULib.ACCESS_ADMIN  )
setpvp:help( "Виставляє режим гри ПВП." )

function ulx.revive( calling_ply, target_plys, amount )
	local affected_plys = {}

	for i = 1, #target_plys do
		local v = target_plys[ i ]
		if ( v:Alive() ) then continue end
		v:Spawn()
		table.insert( affected_plys, v )
	end

	ulx.fancyLogAdmin( calling_ply, "#A Revived #T", affected_plys, amount )
end

local revive = ulx.command( CATEGORY_NAME, "ulx revive", ulx.revive, "!revive" )
revive:addParam{ type=ULib.cmds.PlayersArg }
revive:defaultAccess( ULib.ACCESS_ADMIN  )
revive:help( "Змушує гравця заспавнитись." )

function ulx.banbuild( calling_ply, target_plys, amount, unban )

	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ( unban ) then
			v:UnbanBuildMode()
		else
			v:BanBuildMode( ( amount > 0 ) and ( amount * 60 ) )
		end

		table.insert( affected_plys, v )
	end

	if ( unban ) then
		ulx.fancyLogAdmin( calling_ply, "#A Unrestricted build mode for #T.", affected_plys )
	elseif ( amount > 0 ) then
		ulx.fancyLogAdmin( calling_ply, "#A Restricted build mode for #T for #i Minutes", affected_plys, amount )
	else
		ulx.fancyLogAdmin( calling_ply, "#A Restricted build mode for #T", affected_plys )
	end
end

local banbuild = ulx.command( CATEGORY_NAME, "ulx banbuild", ulx.banbuild, "!banbuild" )
banbuild:addParam{ type=ULib.cmds.PlayersArg }
banbuild:addParam{ type=ULib.cmds.NumArg, min = 0, default=10, hint = "Minutes", ULib.cmds.round, ULib.cmds.optional }
banbuild:addParam{ type=ULib.cmds.BoolArg, invisible = true }
banbuild:defaultAccess( ULib.ACCESS_ADMIN  )
banbuild:help( "Забирає можливість гравцю заходити в білд." )
banbuild:setOpposite( "ulx unbanbuild", { _, _, _, true }, "!unbanbuild" )
