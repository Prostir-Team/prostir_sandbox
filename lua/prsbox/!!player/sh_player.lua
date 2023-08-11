---
--- Local variables
---

local DEFAULT_MODEL = "models/player/kleiner.mdl"

---
--- Meta class
---

local PLAYER = FindMetaTable("Player")

if SERVER then
    function PLAYER:SetProstirModel(modelName)
        if not modelName or modelName == "" then
            modelName = DEFAULT_MODEL
        end
        
        if not PlayerHasModel(self, modelName) then 
            modelName = DEFAULT_MODEL
        end
        
        
        self:SetModel(modelName)
        self:SetupHands()
    end

    function PLAYER:IsAFK()
        return false 
    end

    function PLAYER:ColorSetup()
        local col = self:GetInfo("cl_playercolor")
        self:SetPlayerColor(Vector(col))

        local col = Vector(self:GetInfo("cl_weaponcolor"))
        if (col:Length() < 0.001) then
            col = Vector(0.001, 0.001, 0.001)
        end

        self:SetWeaponColor(col)
    end 
    
    function PLAYER:MovementSetup()
        self:SetWalkSpeed(300)
        
        self:SetRunSpeed(400)
    end

    function PLAYER:WeaponSetup()
        self:Give("gmod_tool")
        self:Give("weapon_physgun")
        self:Give("weapon_fists")

	    self:SwitchToDefaultWeapon()
    end
end
