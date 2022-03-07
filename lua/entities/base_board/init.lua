AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Page" )
end

function ENT:OnRemove()
    timer.Destroy(self.PrintName)
end

function ENT:Initialize()
    self:SetPage(1)
    self:SetModel("models/hunter/plates/plate2x3.mdl")
    self:SetColor( Color(0, 0, 0))
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if (phys:IsValid()) then

        phys:Wake()

    end
end