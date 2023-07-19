-- я єбав ці панельки в рот, де html блять - n1clude

do
    local PANEL = {}

    function PANEL:Init()
        local tabMenu = vgui.Create("PRSBOX.Lobby.TabMenu", self)
        if IsValid(tabMenu) then
            self.TabMenu = tabMenu

            tabMenu:Dock(TOP)
            tabMenu:AddTab("Тест", "PRSBOX.Infopanel.TabContent")

            tabMenu:InitButtons()
        end
    end

    vgui.Register("PRSBOX.Infopanel", PANEL, "EditablePanel")
end

do
    local PANEL = {}

    function PANEL:Init()
        self:AppendText("Hello world!")
    end

    vgui.Register("PRSBOX.Infopanel.TabContent", PANEL, "EditablePanel")
end

MENU:RegisterButton("Cool Інформація", 2, PLAYER_NONE, function(menu, btn)
    menu:OpenInfoMenu("PRSBOX.Infopanel")
end)
