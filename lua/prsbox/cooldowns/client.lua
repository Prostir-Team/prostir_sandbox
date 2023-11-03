--  			03.11.2023  			Isemenuk27
local Cooldowns = PRSBOX.Cooldowns
local SharedCooldowns = PRSBOX.SharedCooldowns
local DrawRect = nil--surface.DrawRect(number x, number y, number width, number height)
local DrawText = draw.Text
local _CDowns, _CDShared, _CDCaters = {}, {}, {}
local curtime, format = CurTime, string.format

local TextTable = {
	text = "",
	font = "DermaLarge",
	pos = { 0, 0 },
	xalign = TEXT_ALIGN_CENTER,
	yalign = TEXT_ALIGN_CENTER,
	color = color_white
}

local _Categorized = {}

local function PaintIcon( panel, w, h )
	local classname = panel:GetSpawnName()

	local TimeLeft

	if ( _Categorized[panel] ) then
		if ( !_CDowns[_Categorized[panel]] ) then return end
		TimeLeft = _CDowns[_Categorized[panel]] - curtime()

		if ( TimeLeft <= 0 ) then
			_CDowns[_Categorized[panel]] = nil
			return
		end
	else
		if ( !_CDowns[classname] ) then return end
		TimeLeft = _CDowns[classname] - curtime()

		if ( TimeLeft <= 0 ) then
			_CDowns[classname] = nil
			return
		end
	end

	TextTable.text = format("%02i", TimeLeft)
	TextTable.pos[1] = w * 0.5
	TextTable.pos[2] = h * 0.4
	DrawText( TextTable )
end

hook.Add( "PRSBOX.ContentIcon.Paint", "PRSBOX.COOLDOWN", PaintIcon )

local function UpdateCooldown()
	local Id = net.ReadString()
	local Time = net.ReadUInt( 10 )
	local IsCategory = net.ReadBool()
	local time = math.floor( curtime() + Time )

	if ( IsCategory ) then
		if ( _CDShared[Id] ) then
			for _, v in ipairs(_CDShared[Id]) do
				_CDowns[v] = time
			end
		end
	end

	_CDowns[Id] = time
end

hook.Add("PRSBOX.ContentIcon.Init", "PRSBOX.COOLDOWN", function( panel )
	local tab = scripted_ents.GetStored( panel:GetSpawnName() )
	if ( !tab ) then return end
	local t = tab.t
	if ( !t ) then return end
	_Categorized[panel] = t.Category
	--panel.Category = t.Category
end )

net.Receive("PRSBOX.CooldownUpdate", UpdateCooldown)

local insert = table.insert

for _, t in ipairs( SharedCooldowns ) do
	for _, v in ipairs( t ) do
		_CDShared[v] = t
	end
end

for c, _ in pairs( Cooldowns ) do
	_CDCaters[c] = true
end