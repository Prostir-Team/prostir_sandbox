---
--- ConVars
---

CreateClientConVar("prsbox_lobby_fov", "80", true, false, "", 80, 110)

---
--- Menu meta class
---

MENU = MENU or {}

MENU.registeredButtons = {} -- Ця таблиця для реєстрації функціоналу кнопок в головному меню

function MENU:RegisterButton(text, pos, playerState, callback, init)
    local button = {
        ["text"] = text,
        ["pos"] = pos,
        ["playerState"] = playerState,
        ["callback"] = callback,
        ["init"] = init
    }
    
    table.insert(self.registeredButtons, button)
end

---
--- Lobby main panel
---

do
    local PANEL = {}

    function PANEL:Init()
        self:MakePopup()

        self.InfoMenuOpened = false 

        local buttonPanel = vgui.Create("EditablePanel", self)
        if IsValid(buttonPanel) then
            self.ButtonPanel = buttonPanel
            
            function buttonPanel:PerformLayout()
                local scrW, scrH = ScrW(), ScrH()

                local buttonWide = ScreenScale(150)
                local marginTopBottom = ScreenScale(100)
                local marginLeft = ScreenScale(25)
                local buttonTall = ScreenScale(20) 

                self:SetX(marginLeft)
                self:SetSize(buttonWide, #MENU.registeredButtons * buttonTall)

                self:CenterVertical()
            end

            function buttonPanel:Paint(w, h)
                -- surface.SetDrawColor(Color(255, 0, 0))
                -- surface.DrawRect(0, 0, w, h)
            end 
        end

        local infoPanel = vgui.Create("EditablePanel", self)
        if IsValid(infoPanel) then
            self.InfoPanel = infoPanel

            infoPanel.MainMenu = self

            local backButton = vgui.Create("PRSBOX.Lobby.Button", infoPanel)

            if IsValid(backButton) then
                infoPanel.BackButton = backButton

                backButton:Text("Назад")
                backButton:Dock(BOTTOM)

                function backButton:DoClick()
                    local parent = self:GetParent()
                    if not IsValid(parent) then return end

                    local mainMenu = parent.MainMenu
                    if not IsValid(mainMenu) then return end

                    mainMenu:CloseInfoMenu()
                end
            end

            function infoPanel:PerformLayout()
                local buttonWide = ScreenScale(150)
                local buttonMarginLeft = ScreenScale(25) 
                local marginLeft = ScreenScale(5)

                local wide, tall = ScreenScale(380), ScreenScale(300)

                self:SetSize(wide, tall)
                self:CenterVertical()
                self:SetX(buttonMarginLeft)
            end

            infoPanel:Hide()
        end
    end

    function PANEL:SetPlayerState(playerState)
        self.PlayerState = playerState
    end

    function PANEL:OpenInfoMenu(className)
        local buttonPanel = self.ButtonPanel
        local infoPanel = self.InfoPanel
        
        if not IsValid(buttonPanel) then return end
        if not IsValid(infoPanel) then return end

        local currentMenu = infoPanel.CurrentMenu

        if IsValid(currentMenu) then
            currentMenu:Remove()
        end

        local infoMenu = vgui.Create(className, infoPanel)
        if not IsValid(infoMenu) then return end

        infoMenu.MainPanel = self
        infoMenu:Dock(FILL)
        infoPanel.CurrentMenu = infoMenu

        buttonPanel:Hide()
        infoPanel:Show()
    end

    function PANEL:CloseInfoMenu()
        local buttonPanel = self.ButtonPanel
        local infoPanel = self.InfoPanel
        
        if not IsValid(buttonPanel) then return end
        if not IsValid(infoPanel) then return end
        
        local currentMenu = infoPanel.CurrentMenu
        if IsValid(currentMenu) then
            currentMenu:Remove()
        end

        buttonPanel:Show()
        infoPanel:Hide()
    end

    function PANEL:InitButtons()
        local buttonPanel = self.ButtonPanel
        if not IsValid(buttonPanel) then return end

        for k, buttonInfo in SortedPairsByMemberValue(MENU.registeredButtons, "pos", false) do
            if buttonInfo["playerState"] ~= self.PlayerState and buttonInfo["playerState"] ~= PLAYER_NONE then continue end
            
            local button = vgui.Create("PRSBOX.Lobby.Button", buttonPanel)
            if not IsValid(button) then continue end
            
            if buttonInfo["init"] ~= nil then
                buttonInfo["init"](self, button)
            end

            button:Text(buttonInfo["text"])
            button:Dock(TOP)
            button.MainMenu = self
            button.DoClick = function ()
                buttonInfo["callback"](self, button)
            end
        end
    end

    function PANEL:PerformLayout(w, h)
        local scrW, scrH = ScrW(), ScrH()
        self:SetSize(scrW, scrH)
    end

    vgui.Register("PRSBOX.Lobby.Menu", PANEL, "EditablePanel")
end

hook.Add("CalcView", "PRSBOX.Lobby.Camera", function (ply, pos, angles)
    if not IsValid(ply) then return end
    local plyState = ply:GetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)

    if plyState == PLAYER_NONE then return end

    local fov = GetConVar("prsbox_lobby_fov"):GetInt()

    local camPos = angles:Forward() * 50 + angles:Right() * 10 - angles:Up() * 5
    local camAng = Angle(0, 160, 0)

    local view = {
		origin = pos + camPos,
		angles = angles - camAng,
		fov = fov,
		drawviewer = true
	}

	return view
end)

---
--- Buttons
---

MENU:RegisterButton("Почати гру", 1, PLAYER_LOBBY, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    ply:SetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)
    
    RunConsoleCommand("prsbox_lobby_start")

    menu:Remove()
end, function (menu, button)
    button.ButtonState = 2
    button.debug = 1
end)

MENU:RegisterButton("Продовжити гру", 1, PLAYER_PAUSE, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    ply:SetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)
    menu:Remove()
end)

MENU:RegisterButton("Покинути сервер", 5, PLAYER_NONE, function ()
    RunConsoleCommand("disconnect")
end)

---
--- Open lobby
---

if IsValid(MAIN_MENU) then
    MAIN_MENU:Remove()
end

net.Receive("PRSBOX.Lobby.StartMenu", function (len)
    local ply = LocalPlayer()
    
    print("--------------------------------------------------------")
    print("Lobby has been started!!!")
    print("--------------------------------------------------------")

    local plyState = ply:GetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)
    if plyState == PLAYER_PAUSE then return end

    ply:SetNWBool("PRSBOX.Lobby.State", PLAYER_LOBBY)
    
    MAIN_MENU = vgui.Create("PRSBOX.Lobby.Menu")
    MAIN_MENU:SetPlayerState(PLAYER_LOBBY)
    MAIN_MENU:InitButtons()
end)

---
--- Open escape lobby
---

hook.Add("PreRender", "PRSBOX.Lobby.Open", function ()
    if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
        local ply = LocalPlayer()
        gui.HideGameUI()
        if not IsValid(ply) or ply:InVehicle() then return end
        
        local plyState = ply:GetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)
        if plyState == PLAYER_LOBBY then return end
        
        if IsValid(MAIN_MENU) then
            ply:SetNWInt("PRSBOX.Lobby.State", PLAYER_NONE)
            
            MAIN_MENU:Remove()
        else
            local plyAngles = ply:GetAngles()
            
            ply:SetEyeAngles(Angle(0, plyAngles.y, 0))
            ply:SetNWInt("PRSBOX.Lobby.State", PLAYER_PAUSE)

            MAIN_MENU = vgui.Create("PRSBOX.Lobby.Menu")
            MAIN_MENU:SetPlayerState(PLAYER_PAUSE)
            MAIN_MENU:InitButtons()
        end
    end
end)