---
--- Local variables
---

local DEFAULT_MODEL = "models/player/kleiner.mdl"

---
--- Meta class
---

local PLAYER = FindMetaTable("Player")

if SERVER then
    function PLAYER:SetProstirModel(modelPath)
        
        if not modelPath or modelPath == "" then
            modelPath = DEFAULT_MODEL
        end
        
        local modelName = GetModelByModelPath(playerModel)

        if not modelName or modelName == "" then
            modelPath = DEFAULT_MODEL
        end

        if not PlayerHasModel(self, modelName) then 
            modelPath = DEFAULT_MODEL
        end
        
        self:SetModel(modelPath)
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

    function PLAYER:GetMaxJumpPower()
        return 150
    end
    
    function PLAYER:MovementSetup()
        -- HL2 Speeds
        self:SetWalkSpeed(190)
        self:SetRunSpeed(320)
        self:SetSlowWalkSpeed(150)
        self:SetCrouchedWalkSpeed(0.3333)
        self:SetJumpPower(150)
    end

    function PLAYER:WeaponSetup()
        self:Give("gmod_tool")
        self:Give("weapon_physgun")
        self:Give("weapon_fists")

	    self:SwitchToDefaultWeapon()
    end

    function PLAYER:GiveAllAmmos()
        self:GiveAmmo( 256,	"Pistol", 		true )
		self:GiveAmmo( 256,	"SMG1", 		true )
		self:GiveAmmo( 5,	"grenade", 		true )
		self:GiveAmmo( 64,	"Buckshot", 	true )
		self:GiveAmmo( 32,	"357", 			true )
		self:GiveAmmo( 32,	"XBowBolt", 	true )
		self:GiveAmmo( 6,	"AR2AltFire", 	true )
		self:GiveAmmo( 100,	"AR2", 			true )
    end
end
