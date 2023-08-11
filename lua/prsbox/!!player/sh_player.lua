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
end
