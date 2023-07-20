---
--- Global functions
---

SETTINGS = SETTINGS or {}

SETTINGS.Settings = {}

function SETTINGS:AddSetting(name, convar, type)
    local s = {
        ["name"] = name,
        ["convar"] = convar,
        ["type"] = type
    }

    table.insert(self.Settings, s)
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
            for i=1, 5 do
                tabMenu:AddTab("TEST " .. i, "TEST.TAB")
            end

            tabMenu:InitButtons()
        end
    end
    
    vgui.Register("PRSBOX.Settings", PANEL, "EditablePanel")
end

MENU:RegisterButton("Налаштування", 3, PLAYER_NONE, function (menu, button)
    menu:OpenInfoMenu("PRSBOX.Settings")
end)