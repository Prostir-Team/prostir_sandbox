---
--- ConVars
---

CreateClientConVar("prsbox_lobby_fov", "80", true, false, "", 80, 110)
CreateClientConVar("prsbox_lobby_camera_speed", "10", true, false, "", 5, 100)

---
--- Player client variables
---

local PLAYER_STATE = PLAYER_NONE
local PLAYER_LAST_WEAPON = ""

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

        self:SetZPos(1000)

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

---
--- Player camera view
---

local camPos = Vector()
local camAng = Angle()
local camFov = 0

hook.Add("CalcView", "PRSBOX.Lobby.Camera", function (ply, pos, angles, fov)
    if not IsValid(ply) then return end

    -- In know, this part of code is fucking shit (by Swanchick)

    if ply:InVehicle() then return end

    local camSpeed = GetConVar("prsbox_lobby_camera_speed"):GetInt()

    if PLAYER_STATE == PLAYER_NONE then
        local endCamPos = Vector()
        local endCamAng = Angle()
        local endFov = fov

        camPos = LerpVector(FrameTime() * camSpeed / 2, camPos, endCamPos)
        camAng = LerpAngle(FrameTime() * camSpeed / 2, camAng, endCamAng)
        camFov = Lerp(FrameTime() * camSpeed / 2, camFov, endFov)
    else
        local tr = util.TraceLine( {
            ["start"] = ply:EyePos(),
            ["endpos"] = ply:EyePos() + angles:Forward() * 60,
            ["collisiongroup"] = COLLISION_GROUP_DEBRIS
        })

        local fraction = PLAYER_STATE == PLAYER_LOBBY and 1 or tr.Fraction

        local endCamPos = angles:Forward() * fraction * 50 + (PLAYER_STATE == PLAYER_LOBBY and angles:Right() * 10 or Vector()) - angles:Up() * 5
        local endCamAng = Angle(0, 160, 0)
        local endFov = GetConVar("prsbox_lobby_fov"):GetInt()

        camPos = LerpVector(FrameTime() * camSpeed, camPos, endCamPos)
        camAng = LerpAngle(FrameTime() * camSpeed, camAng, endCamAng)
        camFov = Lerp(FrameTime() * camSpeed, camFov, endFov)
    end

    local view = {
        ["origin"] = pos + camPos,
        ["angles"] = angles - camAng,
        ["fov"] = camFov,
        ["drawviewer"] = PLAYER_STATE ~= PLAYER_NONE
    }

    return view
end)

---
--- Buttons
---

MENU:RegisterButton("Почати гру", 1, PLAYER_LOBBY, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    PLAYER_STATE = PLAYER_NONE
    
    RunConsoleCommand("prsbox_lobby_start")

    menu:Remove()
end, function (menu, button)
    button.ButtonState = 2
    button.debug = 1
end)

MENU:RegisterButton("Продовжити гру", 1, PLAYER_PAUSE, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    PLAYER_STATE = PLAYER_NONE
    menu:Remove()
end)

MENU:RegisterButton("Тест", 2, PLAYER_NONE, function (menu, button)
    if IsValid(menu.CheckBox) then return end
    
    local checkbox = vgui.Create("PRSBOX.Lobby.Checkbox", menu)
    if not IsValid(checkbox) then return end
    menu.CheckBox = checkbox

    checkbox:SetTitle("Пройдіть рашист тестер")
    checkbox:SetText("Вам потрібно пройти рашист тестер aksdhkajhs dhalsjhd jahsjd hlajkshd jkhalsjhd lasd hasjhd jas!!!")
    checkbox:SetState(CHECKBOX_BAD)

    function checkbox:OnYesClick()
        print("yes")

        self:Remove()
    end

    function checkbox:OnNoClick()
        print("no")

        self:Remove()
    end
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

    if PLAYER_STATE == PLAYER_PAUSE then return end

    PLAYER_STATE = PLAYER_LOBBY
    
    MAIN_MENU = vgui.Create("PRSBOX.Lobby.Menu")
    MAIN_MENU:SetPlayerState(PLAYER_LOBBY)
    MAIN_MENU:InitButtons()
end)

net.Receive("PRSBOX.Lobby.CheckDeath", function (len, ply)
    if IsValid(MAIN_MENU) then
        PLAYER_STATE = PLAYER_NONE
        
        MAIN_MENU:Remove()
    end
end)

---
--- Open escape lobby
---

hook.Add("PreRender", "PRSBOX.Lobby.Open", function ()
    if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
        local ply = LocalPlayer()
        gui.HideGameUI()
        if not IsValid(ply) or ply:InVehicle() then return end

        if PLAYER_STATE == PLAYER_LOBBY then return end
        
        if not ply:Alive() then
            RunConsoleCommand("prsbox_lobby_test")
            return 
        end

        if IsValid(MAIN_MENU) then
            PLAYER_STATE = PLAYER_NONE
            
            MAIN_MENU:Remove()
        else
            local plyAngles = ply:GetAngles()

            ply:SetEyeAngles(Angle(0, plyAngles.y, 0))
            PLAYER_STATE = PLAYER_PAUSE

            MAIN_MENU = vgui.Create("PRSBOX.Lobby.Menu")
            MAIN_MENU:SetPlayerState(PLAYER_PAUSE)
            MAIN_MENU:InitButtons()
        end
    end
end)

hook.Add("HUDShouldDraw", "PRSBOX.Lobby.HideCrosshair", function (name)
    if name == "CHudCrosshair" and PLAYER_STATE ~= PLAYER_NONE then
        return false 
    end
end)