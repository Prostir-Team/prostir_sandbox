CreateClientConVar("prsbox_test", "10", true, false, "", 0, 100)
CreateClientConVar("prsbox_test2", "10", true, false, "", 0, 100)

---
--- Setting types
---

SETTINGS_BUTTON = 1 
SETTINGS_BOOL = 2
SETTINGS_INT = 3

---
--- Global functions
---

SETTINGS = {}

SETTINGS.Settings = {}

function SETTINGS:AddCategory(category)
    if table.HasValue(table.GetKeys(SETTINGS.Settings), category) then return end

    SETTINGS.Settings[category] = {}
end

function SETTINGS:AddSetting(name, category, convar, type)
    local s = {
        ["name"] = name,
        ["convar"] = convar,
        ["type"] = type
    }

    self:AddCategory(category)

    table.insert(self.Settings[category], s)
end

---
--- Settings slider number
---

do
    local PANEL = {}

    function PANEL:Init()
        self:Dock(RIGHT)

        self:SetText("")
    end

    function PANEL:OnMousePressed(key)
        self.Clicked = true 
    end

    function PANEL:OnMouseReleased(key)
        self.Clicked = false 
    end

    function PANEL:AddConvar(convarName)
        local convar = GetConVar(convarName)
        self.Convar = convar

        local max = convar:GetMax()
        self.Max = max

        local min = convar:GetMin()
        self.Min = min

        local value = convar:GetInt()
        self.RealValue = value
        self.Value = value - self.Min

        self.DeltaMinMax = self.Max - self.Min
    end

    function PANEL:PerformLayout()
        local wide = ScreenScale(90)

        self:SetWide(wide)
    end

    function PANEL:GetLocalMax()
        local min = ScreenScale(20)
        local max = ScreenScale(5)
        local wide = self:GetWide()
        
        return wide - max - min
    end
    
    function PANEL:TranslateToLocal(value)
        local wide = self:GetLocalMax()
        local valueLocal = value * wide / self.DeltaMinMax
        
        return valueLocal
    end

    function PANEL:OnValueChanged(value)
        self.Convar:SetInt(value)
    end

    function PANEL:Think()
        if not self.Convar then return end
        
        if not self.Clicked then return end
        if not self:IsHovered() then 
            self.Clicked = false 
            return 
        end

        local wide = self:GetLocalMax()

        local x, y = self:LocalToScreen(0, 0)
        local localValue = math.abs(gui.MouseX() - x) - ScreenScale(20)

        local value = math.Round(localValue * self.DeltaMinMax / wide)

        if self.Value == value then return end

        local realValue = value + self.Min

        if realValue > self.Max or realValue < self.Min then return end
        self.Value = value
        self.RealValue = realValue

        self:OnValueChanged(self.RealValue)
    end

    function PANEL:Paint(w, h)
        -- surface.SetDrawColor(COLOR_RED)
        -- surface.DrawRect(0, 0, w, h)

        if not self.Value then return end

        local min = ScreenScale(20)

        draw.DrawText(self.RealValue, "PRSBOX.Lobby.Font.Info", 0, ScreenScale(5), COLOR_WHITE, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(COLOR_WHITE)
        surface.DrawRect(min, ScreenScale(15) / 2, self:TranslateToLocal(self.Value), h - ScreenScale(15))
    end 

    vgui.Register("PRSBOX.Settings.Slider", PANEL, "DButton")
end 

---
--- Settings button
---

do
    local PANEL = {}

    function PANEL:Init()
        self:SetText("")
        self.debug = false

        self.ButtonState = BUTTON_OPENED

        self.Active = false

        self.TextColor = COLOR_WHITE
        self.BackgroundColor = COLOR_BUTTON_NONE
        self.MarkTall = 0
        self.Speed = GetConVar("prsbox_lobby_button_speed"):GetInt()
    end

    function PANEL:Text(text)
        self.text = text
    end

    function PANEL:SetConvar(convar)
        self.Convar = convar
    end

    function PANEL:SetType(type)
        self.Type = type
    end

    function PANEL:Start()
        local slider = vgui.Create("PRSBOX.Settings.Slider", self)
        if not IsValid(slider) then return end
        self.Slider = slider

        slider:AddConvar(self.Convar)
    end

    function PANEL:PerformLayout()
        local tall = ScreenScale(20)

        self:SetTall(tall)
    end

    function PANEL:Paint(w, h)
        local marginLeft = ScreenScale(3)
        
        if self:IsHovered() or self.Active or self.Slider:IsHovered() then
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_BACKGROUND)
        else
            self.BackgroundColor = LerpColor(FrameTime() * self.Speed, self.BackgroundColor, COLOR_BUTTON_NONE)
        end
        
        surface.SetDrawColor(self.BackgroundColor)
        surface.DrawRect(0, 0, w, h)
        
        if not self.text then return end

        draw.DrawText(self.text, "PRSBOX.Lobby.Font.Button", marginLeft, ScreenScale(2.3), self.TextColor, TEXT_ALIGN_LEFT)
    end

    vgui.Register("PRSBOX.Settings.Button", PANEL, "DButton")
end



---
--- Category
---

do
    local PANEL = {}

    function PANEL:Init()
        
    end

    function PANEL:SetCategory(category)
        self.Category = category
    end

    function PANEL:InitButtons()
        local buttonInfos = SETTINGS.Settings[self.Category]

        for k, info in ipairs(buttonInfos) do
            local button = vgui.Create("PRSBOX.Settings.Button", self)
            if not IsValid(button) then continue end

            button:Text(info["name"])
            button:SetConvar(info["convar"])
            button:SetType(info["type"])

            button:Dock(TOP)
            button:Start()
        end
    end

    function PANEL:Paint(w, h)
        -- draw.DrawText(self.Category, "PRSBOX.Lobby.Font.Big", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)

        
    end

    vgui.Register("PRSBOX.Settings.Category", PANEL, "EditablePanel")
end

---
--- Settings panel
---

do
    local PANEL = {}

    function PANEL:Init()
        local tabMenu = vgui.Create("PRSBOX.Lobby.TabMenu", self)
        if IsValid(tabMenu) then
            self.TabMenu = tabMenu

            tabMenu:Dock(TOP)
            for k, v in ipairs(table.GetKeys(SETTINGS.Settings)) do
                tabMenu:AddTab(v, "PRSBOX.Settings.Category", function (text, menu)
                    menu:SetCategory(text)
                    menu:InitButtons()
                end)
            end

            tabMenu:InitButtons()
        end
    end
    
    vgui.Register("PRSBOX.Settings", PANEL, "EditablePanel")
end

MENU:RegisterButton("Налаштування", 3, PLAYER_NONE, function (menu, button)
    menu:OpenInfoMenu("PRSBOX.Settings")
end)

local s = {"hud", "jmod", "simphys", "admin", "you mom"}

for k, v in ipairs(s) do
    for i=1, 10 do
        SETTINGS:AddSetting("Option " .. i, v, "prsbox_test2", SETTINGS_INT)
    end
end