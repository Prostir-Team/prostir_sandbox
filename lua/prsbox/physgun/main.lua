local banclass = {
	["prop_door_rotating"] = true,
	["prop_dynamic"] = true,
	["prop_door"] = true,
	["func_button"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true,
	["func_tracktrain"] = true,
	["func_movelinear"] = true,
	["func_brush"] = true,
	["func_breakable"] = true,
	["func_breakable_surf"] = true,

	["simfphys_antitankmine"] = true,
	["npc_tripmine"] = true,
	["lvs_bomb"] = true,
	["lvs_helicopter_combine_bomb"] = true,

	["ent_jack_aidbox"] = true,
	["func_lod"] 		= true,

	["npc_manned_emplacement"] = true
}

local bantimes = {}

function PRSBOX:AddPhysgunPickupBan(ent, time)
	bantimes[ent] = CurTime() + time
end

local function BanClassPickup( ply, ent )
	if ply:InVehicle() then return false end

	if bantimes[ent] then
		if bantimes[ent] <= CurTime() then
			bantimes[ent] = nil
		else
			return false
		end
	end

	local BaseEnt = ent.GetBaseEnt and ent:GetBaseEnt() 

	if ( IsValid( BaseEnt ) ) then
		if BaseEnt.DisablePhysgunInteract or BaseEnt.bParachuted then return false end
	end

	if ent.DisablePhysgunInteract or ent.bParachuted then return false end

	local c = ent:GetClass()

	local f = banclass[c]
	if f then
		if isfunction(f) then
			if f( ent, ply ) then 
				return false 
			end 
		else
			return false 
		end 
	end 
end

hook.Add( "PhysgunPickup", "PRSBOX.BanClassPickup", BanClassPickup )