local PLAYER = FindMetaTable("Player")

if SERVER then
    function PLAYER:SetProstirModel(modelName)
        self:SetModel(modelName)
        self:SetupHands()
    end

    function PLAYER:IsAFK()
        return false 
    end
end
