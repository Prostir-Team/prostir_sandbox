AddCSLuaFile()

--ENT.Type = "anim"
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Upgrade Module"
ENT.Category = "Other"
ENT.Author = "Isemenuk27"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DisableDuplicator = true

ENT.Model = "models/props_lab/reciever01b.mdl"
ENT.Text = "Модуль\nПокращення"
ENT.TextScale = .2

ENT.NoSit = true
ENT.NoCleanup = true
ENT.IgnoreProperty = {
	["remove"] = true
}
function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
	    self:PhysicsInit(SOLID_VPHYSICS)
	    self:SetUseType(SIMPLE_USE)
	    local physObj = self:GetPhysicsObject()
	    if not physObj:IsValid() then return end
	    physObj:Wake()
	end
end

function ENT:Use(activator, caller, useType, value )
	if IsValid(activator) and activator:IsPlayer() then
		activator:PickupObject(self)
	end
end

local TxtCol = color_white
local maxdist = 42000

function ENT:Draw()
	local Ang, Pos = self:GetAngles(), self:GetPos()
	local Dist = EyePos():DistToSqr(Pos) 

	self:DrawModel()

	if Dist > maxdist then return end

	local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()

	local vmin, vmax = self:GetModelBounds()

	local maxz = vmax.z + 0.2

	Ang:RotateAroundAxis(Up, 90)

	local CamPos = Pos + (Up * maxz) 

	cam.Start3D2D( CamPos, Ang, self.TextScale )
		draw.DrawText( self.Text, "Default", 0, -20, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end