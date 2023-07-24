-- я єбав ці панельки в рот, де html блять - n1clude

do
    local PANEL = {}

    function PANEL:Init()
        local sbar = self:GetVBar()
        if not IsValid(sbar) then return end
        self.Sbar = sbar

        sbar:DockPadding(sbar:GetWide(), 0, 0, 0)
        sbar:SetHideButtons(true)

        function sbar:Paint(w, h)
            surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
            surface.DrawRect(0, 0, w, h)
        end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
            surface.SetDrawColor(COLOR_WHITE)
            surface.DrawRect(0, 0, w, h)
        end
    end

    function PANEL:LoadDocument(docName) -- md parser code lmao
        local filename = docName .. ".md"
        print("Loading document: " .. filename)
        local f = file.Read("data/infopanel_docs/" .. filename, "GAME")
        if f == nil then
            local errmsg = self:Add(PRMARKDOWN_HEADING1)
            errmsg:SetText("На жаль, документ не вдалось завантажити :(")
            errmsg:Dock(TOP)
            print("Loading failed.")
            return
        end
        local data_arr = string.Explode("\n", f)
        for _, line in ipairs(data_arr) do
            local str = string.Explode(" ", line)
            local str_type
            local elm = string.sub(str[1], 1, 2) -- first symbol of the first string element
            if tonumber(elm) != nil then -- need to check if the string is an ordered list
                str_type = PRMARKDOWN_ORDERED
            else
                str_type = PrMarkdown_Symbols[str[1]]
                if str_type == nil then -- if it's not a special element, we should make it a plain text
                    str_type = PRMARKDOWN_PLAIN
                end
            end

            if (str_type != PRMARKDOWN_PLAIN) and (str_type != PRMARKDOWN_ORDERED) then
                line = table.concat(str, " ", 2)
            end

            local element = self:Add(str_type)
            element:SetText(line)
            element:Dock(TOP)
        end
        print("Loading succeeded.")
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(COLOR_BUTTON_BACKGROUND)
        surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("PRSBOX.Infopanel.TabContent", PANEL, "DScrollPanel")
end

do
    local PANEL = {}

    function PANEL:Init()
        self:LoadDocument("main")
    end

    vgui.Register("PRSBOX.Infopanel.TabContent.Main", PANEL, "PRSBOX.Infopanel.TabContent")
end

do
    local PANEL = {}

    function PANEL:Init()
        self:LoadDocument("rules")
    end

    vgui.Register("PRSBOX.Infopanel.TabContent.Rules", PANEL, "PRSBOX.Infopanel.TabContent")
end

do
    local PANEL = {}

    function PANEL:Init()
        local tabMenu = vgui.Create("PRSBOX.Lobby.TabMenu", self)
        if IsValid(tabMenu) then
            self.TabMenu = tabMenu

            tabMenu:Dock(TOP)
            tabMenu:AddTab("Головна", "PRSBOX.Infopanel.TabContent.Main")
            tabMenu:AddTab("Правила", "PRSBOX.Infopanel.TabContent.Rules")

            tabMenu:InitButtons()
        end
    end

    vgui.Register("PRSBOX.Infopanel", PANEL, "EditablePanel")
end

MENU:RegisterButton("Інформація", 3, PLAYER_NONE, function(menu, btn)
    menu:OpenInfoMenu("PRSBOX.Infopanel")
end)
