CreateClientConVar("prsbox_test", "10", true, false, "", 0, 10)


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


        local label = vgui.Create("DLabel", self)
        if IsValid(label) then
            self.Label = label

            label:SetText("")
            label:Dock(FILL)
            label.text = ""

            function label:Paint(w, h)
                draw.DrawText(self.text, "PRSBOX.Lobby.Font.Info", w / 2, ScreenScale(5.5), COLOR_WHITE, TEXT_ALIGN_CENTER)
            end
        end
        
        local lowButton = vgui.Create("DButton", self)
        if IsValid(lowButton) then
            self.LowButton = lowButton

            lowButton:SetText("<")
            lowButton:Dock(LEFT)
            lowButton:SetTextColor(COLOR_WHITE)
            lowButton:SetFont("PRSBOX.Lobby.Font.Info")

            function lowButton:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                parent:ChangeValue(-1)
            end

            function lowButton:Paint()
            end
        end

        local highButton = vgui.Create("DButton", self)
        if IsValid(highButton) then
            self.HighButton = highButton

            highButton:SetText(">")
            highButton:Dock(RIGHT)
            highButton:SetTextColor(COLOR_WHITE)
            highButton:SetFont("PRSBOX.Lobby.Font.Info")

            function highButton:DoClick()
                local parent = self:GetParent()
                if not IsValid(parent) then return end

                parent:ChangeValue(1)
            end

            function highButton:Paint()
            end
        end
    end

    function PANEL:AddConvar(convarName)
        if not ConVarExists(convarName) then return end

        local convar = GetConVar(convarName)
        self.Convar = convar
        local value = convar:GetInt()
        self.Value = value
        local min = convar:GetMin()
        self.Min = min
        local max = convar:GetMax()
        self.Max = max

        local label = self.Label
        if IsValid(label) then
            label.text = value
        end
    end

    function PANEL:ChangeValue(value)
        self.Value = self.Convar:GetInt()
        
        self.Value = self.Value + value

        if self.Value > self.Max or self.Value < self.Min then return end

        self.Convar:SetInt(self.Value)

        local label = self.Label
        if IsValid(label) then
            label.text = self.Value
        end
    end

    function PANEL:PerformLayout()
        local wide = ScreenScale(58)

        self:SetWide(wide)
    end

    

    function PANEL:Paint(w, h)
        -- surface.SetDrawColor(COLOR_RED)
        -- surface.DrawRect(0, 0, w, h)
    end 

    vgui.Register("PRSBOX.Settings.Slider", PANEL, "EditablePanel")
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
        
        if self:IsHovered() or self.Active then
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
        SETTINGS:AddSetting("Option " .. i, v, "prsbox_test", SETTINGS_INT)
    end
end