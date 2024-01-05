------------------------------ Ban ------------------------------
function ulx.ban( calling_ply, target_ply, minutes, reason )
	if target_ply:IsListenServerHost() or target_ply:IsBot() then
		ULib.tsayError( calling_ply, "This player is immune to banning", true )
		return
	end

	target_ply.GONNABAN = true

	local time = "for #s"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
	ULib.queueFunctionCall( ULib.kickban, target_ply, minutes, reason, calling_ply )
end
local ban = ulx.command( CATEGORY_NAME, "ulx ban", ulx.ban, "!ban", false, false, true )
ban:addParam{ type=ULib.cmds.PlayerArg }
ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
ban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
ban:defaultAccess( ULib.ACCESS_ADMIN )
ban:help( "Bans target." )

------------------------------ BanID ------------------------------
function ulx.banid( calling_ply, steamid, minutes, reason )
	steamid = steamid:upper()
	if not ULib.isValidSteamID( steamid ) then
		ULib.tsayError( calling_ply, "Invalid steamid." )
		return
	end

	local name, target_ply
	local plys = player.GetAll()
	for i=1, #plys do
		if plys[ i ]:SteamID() == steamid then
			target_ply = plys[ i ]
			name = target_ply:Nick()
			break
		end
	end

	if target_ply and (target_ply:IsListenServerHost() or target_ply:IsBot()) then
		ULib.tsayError( calling_ply, "This player is immune to banning", true )
		return
	end

	if ( target_ply ) then
		target_ply.GONNABAN = true
	end

	local time = "for #s"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned steamid #s "
	displayid = steamid
	if name then
		displayid = displayid .. "(" .. name .. ") "
	end
	str = str .. time
	if reason and reason ~= "" then str = str .. " (#4s)" end
	ulx.fancyLogAdmin( calling_ply, str, displayid, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
	ULib.queueFunctionCall( ULib.addBan, steamid, minutes, reason, name, calling_ply )
end
local banid = ulx.command( CATEGORY_NAME, "ulx banid", ulx.banid, "!banid", false, false, true )
banid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
banid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
banid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
banid:defaultAccess( ULib.ACCESS_SUPERADMIN )
banid:help( "Bans steamid." )


------------------------------ Jail ------------------------------
local doJail
local jailableArea
function ulx.jail( calling_ply, target_plys, seconds, should_unjail )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]

		if not should_unjail then
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif not jailableArea( v:GetPos() ) then
				ULib.tsayError( calling_ply, v:Nick() .. " is not in an area where a jail can be placed!", true )
			else
				doJail( v, seconds )

				table.insert( affected_plys, v )
			end
		elseif v.jail then
			v.jail.unjail()
			v.jail = nil
			table.insert( affected_plys, v )
		end
	end

	if not should_unjail then
		local str = "#A jailed #T"
		if seconds > 0 then
			str = str .. " for #i seconds"
		end
		ulx.fancyLogAdmin( calling_ply, str, affected_plys, seconds )
	else
		ulx.fancyLogAdmin( calling_ply, "#A unjailed #T", affected_plys )
	end
end

local jail = ulx.command( CATEGORY_NAME, "ulx jail", ulx.jail, "!jail" )
jail:addParam{ type=ULib.cmds.PlayersArg }
jail:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="seconds, 0 is forever", ULib.cmds.round, ULib.cmds.optional }
jail:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jail:defaultAccess( ULib.ACCESS_ADMIN )
jail:help( "Jails target(s)." )
jail:setOpposite( "ulx unjail", {_, _, _, true}, "!unjail" )

------------------------------ Jail TP ------------------------------
function ulx.jailtp( calling_ply, target_ply, seconds )
	local t = {}
	t.start = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
	t.filter = target_ply
	if target_ply ~= calling_ply then
		t.filter = { target_ply, calling_ply }
	end
	local tr = util.TraceEntity( t, target_ply )

	local pos = tr.HitPos

	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	elseif not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )
		target_ply:Spawn()
		return
	elseif not jailableArea( pos ) then
		ULib.tsayError( calling_ply, "That is not an area where a jail can be placed!", true )
		return
	else
		target_ply.ulx_prevpos = target_ply:GetPos()
		target_ply.ulx_prevang = target_ply:EyeAngles()

		if target_ply:InVehicle() then
			target_ply:ExitVehicle()
		end

		target_ply:SetPos( pos )
		target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

		doJail( target_ply, seconds )
	end

	local str = "#A teleported and jailed #T"
	if seconds > 0 then
		str = str .. " for #i seconds"
	end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, seconds )
end
local jailtp = ulx.command( CATEGORY_NAME, "ulx jailtp", ulx.jailtp, "!jailtp" )
jailtp:addParam{ type=ULib.cmds.PlayerArg }
jailtp:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="seconds, 0 is forever", ULib.cmds.round, ULib.cmds.optional }
jailtp:defaultAccess( ULib.ACCESS_ADMIN )
jailtp:help( "Teleports, then jails target(s)." )


local function jailCheck()
	local remove_timer = true
	local players = player.GetAll()
	for i=1, #players do
		local ply = players[ i ]
		if ply.jail then
			remove_timer = false
		end
		if ply.jail and (ply.jail.pos-ply:GetPos()):LengthSqr() >= 6500 then
			ply:SetPos( ply.jail.pos )
			if ply.jail.jail_until then
				doJail( ply, ply.jail.jail_until - CurTime() )
			else
				doJail( ply, 0 )
			end
		end
	end

	if remove_timer then
		timer.Remove( "ULXJail" )
	end
end

jailableArea = function( pos )
	entList = ents.FindInBox( pos - Vector( 35, 35, 5 ), pos + Vector( 35, 35, 110 ) )
	for i=1, #entList do
		if entList[ i ]:GetClass() == "trigger_remove" then
			return false
		end
	end

	return true
end

local mdl1 = Model( "models/props_building_details/Storefront_Template001a_Bars.mdl" )
local jail = {
	{ pos = Vector( 0, 0, -5 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 0, 0, 97 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, -31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, -31, 46), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
}
doJail = function( v, seconds )
	if v.jail then -- They're already jailed
		v.jail.unjail()
	end

	if v:InVehicle() then
		local vehicle = v:GetParent()
		v:ExitVehicle()
		vehicle:Remove()
	end

	-- Force other players to let go of this player
	if v.physgunned_by then
		for ply, v in pairs( v.physgunned_by ) do
			if ply:IsValid() and ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == "weapon_physgun" then
				ply:ConCommand( "-attack" )
			end
		end
	end

	if v:GetMoveType() == MOVETYPE_NOCLIP then -- Take them out of noclip
		v:SetMoveType( MOVETYPE_WALK )
	end

	local pos = v:GetPos()

	local walls = {}
	for _, info in ipairs( jail ) do
		local ent = ents.Create( "prop_physics" )
		ent:SetModel( info.mdl )
		ent:SetPos( pos + info.pos )
		ent:SetAngles( info.ang )
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion( false )
		ent:SetMoveType( MOVETYPE_NONE )
		ent.jailWall = true
		ent:SetNWString( "Owner", "World" )
		table.insert( walls, ent )
	end

	local key = {}
	local function unjail()
		if not v:IsValid() or not v.jail or v.jail.key ~= key then -- Nope
			return
		end

		for _, ent in ipairs( walls ) do
			if ent:IsValid() then
				ent:DisallowDeleting( false )
				ent:Remove()
			end
		end
		if not v:IsValid() then return end -- Make sure they're still connected

		v:DisallowNoclip( false )
		v:DisallowMoving( false )
		v:DisallowSpawning( false )
		v:DisallowVehicles( false )

		ulx.clearExclusive( v )
		ulx.setNoDie( v, false )

		v.jail = nil
	end
	if seconds > 0 then
		timer.Simple( seconds, unjail )
	end

	local function newWall( old, new )
		table.insert( walls, new )
	end

	for _, ent in ipairs( walls ) do
		ent:DisallowDeleting( true, newWall )
		ent:DisallowMoving( true )
	end
	v:DisallowNoclip( true )
	v:DisallowMoving( true )
	v:DisallowSpawning( true )
	v:DisallowVehicles( true )
	v.jail = { pos = pos, unjail = unjail, key = key }
	if seconds > 0 then
		v.jail.jail_until = CurTime() + seconds
	end
	ulx.setExclusive( v, "in jail" )
	ulx.setNoDie( v, true )

	timer.Create( "ULXJail", 1, 0, jailCheck )
end

local function jailDisconnectedCheck( ply )
    if ( ply.jail ) then
        local timeleft = ply.jail.jail_until and ( ply.jail.jail_until - CurTime() ) or 0
        ply.jail.unjail()
        if ( ply.GONNABAN ) then return end
        ulx.ban( nil, ply, ( timeleft + 700 ) / 60, "Лів з джайлу" )
    end
end

hook.Add( "PlayerDisconnected", "ULXJailDisconnectedCheck", jailDisconnectedCheck, HOOK_MONITOR_HIGH )


----------------------------------------------------------------------------------------------------------------

function ulx.banip(calling_ply,adress,should_unban)
	if should_unban then
		ULib.consoleCommand( "removeip ".. adress .. "\n" )
		ulx.fancyLogAdmin(calling_ply,true,"#A unbanned IP #s",adress)
	else
		for _,ply in ipairs(player.GetAll()) do
		    if string.Explode(":",ply:IPAddress())[1] == adress then
        		ply:SendLua([[
        			cam.End3D()
        		]])
    	    end
	    end
		ULib.consoleCommand( "addip 0 ".. adress .. "\n" )
		ulx.fancyLogAdmin(calling_ply,true,"#A banned IP #s",adress)
	end
end

local banip = ulx.command("Extended","ulx banip",ulx.banip,"!banip")
banip:addParam{ type=ULib.cmds.StringArg, hint="IP Adress", ULib.cmds.takeRestOfLine }
banip:addParam{ type=ULib.cmds.BoolArg, invisible=true }
banip:defaultAccess( ULib.ACCESS_ADMIN  )
banip:help( "Ban IP" )
banip:setOpposite( "ulx unbanip", {_,_, true}, "!unbanip" )

function ulx.crash(calling_ply, target_ply)
        target_ply:SendLua([[
			while true do end
		]])
		ulx.fancyLogAdmin( calling_ply, true,  "#T was crashed by #A", target_ply)
end

local crash = ulx.command("Extended", "ulx crash", ulx.crash)
crash:addParam{ type=ULib.cmds.PlayerArg }
crash:defaultAccess( ULib.ACCESS_ADMIN )

function ulx.give(calling_ply,wep,target_ply)
	if not target_ply then target_ply = calling_ply end
	local isvalid = IsValid(target_ply:Give(wep))
	if isvalid then
		ulx.fancyLogAdmin( calling_ply, "#A gave #s to #T", wep, target_ply )
	else
		ULib.tsayError(calling_ply, wep.." is not a valid entity", true)
	end	
end

local give = ulx.command("Extended", "ulx give", ulx.give, "!give", true)
give:defaultAccess( ULib.ACCESS_ADMIN )
give:addParam{ type=ULib.cmds.StringArg, hint="weapon", ULib.cmds.optional }
give:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }

function ulx.cleardecals(calling_ply)
	ulx.fancyLogAdmin(calling_ply,"#A cleared all decals")
    for _, v in ipairs( player.GetAll() ) do
         v:ConCommand( "r_cleardecals" )
    end
end

local cleardecals = ulx.command("Extended", "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clear all decals." )

function ulx.freezeprops(calling_ply,should_unfreeze)
	if not should_unfreeze then
		for k, v in ipairs( ents.FindByClass("prop_physics") ) do
			if v:IsValid() and v:IsInWorld()  then
				print(v:GetClass())
				v:GetPhysicsObject():EnableMotion(false)
			end
		end
	else
	for k, v in ipairs( ents.FindByClass("prop_physics") ) do
		if v:IsValid() and v:IsInWorld() then
			v:GetPhysicsObject():EnableMotion(true)
		end
	end
	end

	if not should_unfreeze then
		ulx.fancyLogAdmin(calling_ply,"#A froze all props")
	else
		ulx.fancyLogAdmin( calling_ply,"#A unfroze all props")
	end
end

local freezeprops = ulx.command("Extended", "ulx freezeprops", ulx.freezeprops, "!freezeprops")
freezeprops:defaultAccess( ULib.ACCESS_ADMIN )
freezeprops:addParam{ type=ULib.cmds.BoolArg, invisible=true }
freezeprops:help( "Enable freezeprops." )
freezeprops:setOpposite( "ulx unfreezeprops", {_, true}, "!unfreezeprops" )

function ulx.copyid(calling_ply, target_ply)
        calling_ply:SendLua([[SetClipboardText( "]] .. target_ply:SteamID() .. [[" )
        chat.AddText( Color(151, 211, 255), "SteamID: '", Color(0, 255, 0), "]] .. target_ply:SteamID() .. [[" , Color(151, 211, 255), "' successfully copied!")
	]])
end

local copyid = ulx.command("Extended", "ulx copyid", ulx.copyid, "!id",true)
copyid:addParam{ type=ULib.cmds.PlayerArg }
copyid:defaultAccess( ULib.ACCESS_ALL )

function ulx.copyip(calling_ply, target_ply)
        calling_ply:SendLua([[SetClipboardText( "]] .. target_ply:IPAddress() .. [[" )
        chat.AddText( Color(151, 211, 255), "IP: '", Color(0, 255, 0), "]] .. target_ply:IPAddress() .. [[" , Color(151, 211, 255), "' successfully copied!")
	]])
end

local copyip = ulx.command("Extended", "ulx copyip", ulx.copyip, "!ip",true)
copyip:addParam{ type=ULib.cmds.PlayerArg }
copyip:defaultAccess( ULib.ACCESS_ADMIN )
copyip:help( "Quickly copy an IP address." )

function ulx.freeze_ply_props(calling_ply, target_ply)
	for k, v in ipairs( ents.GetAll() ) do
		if IsValid( v ) and v.GetCreator and v:GetCreator() == target_ply then
			local phys = v:GetPhysicsObject()
			if !phys then continue end
			phys:EnableMotion(false)
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A Заморозив пропи #T", target_ply )
end

local freeze_ply_props = ulx.command("Extended", "ulx freeze_ply_props", ulx.freeze_ply_props, "!freezeplyprops",true)
freeze_ply_props:addParam{ type=ULib.cmds.PlayerArg }
freeze_ply_props:defaultAccess( ULib.ACCESS_ADMIN )
freeze_ply_props:help( "Заморозити пропи гравця." )

hook.Add("InitPostEntity", "UlxMOTDOverload", function() 
	function ulx.motd(calling_ply)
		if !IsValid(calling_ply) then return end
		calling_ply:ConCommand( "prsbox_motd" )
	end

	local motd = ulx.command("Extended", "ulx motd", ulx.motd, "!motd")
	motd:defaultAccess(ULib.ACCESS_ALL)
	motd:help("Відкрити MOTD.")
end)

if SERVER then
	local formattext = "%s<%s> used tool %s on %s"

	local function LogTools( ply, tr, toolname, tool, button )
		ulx.logSpawn( string.format( formattext, ply:Nick(), ply:SteamID(), toolname, tostring( tr.Entity ) ) )
	end

	hook.Add( "CanTool", "CanToolULXLog", LogTools)
end
