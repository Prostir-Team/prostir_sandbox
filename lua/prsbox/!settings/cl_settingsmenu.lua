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
--- Category
---

do
    local PANEL = {}

    function PANEL:Init()
        
    end

    function PANEL:SetCategory(category)
        self.Category = category
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
                tabMenu:AddTab(v, "PRSBOX.Settings.Category")
            end

            tabMenu:InitButtons()

            function tabMenu:OnMenuOpen(buttonText, menu)
                menu:SetCategory(buttonText)
            end
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
        SETTINGS:AddSetting("Option " .. i, v, "test", SETTINGS_BOOL)
    end
end