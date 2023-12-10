---
--- ConVars
---

CreateClientConVar("prsbox_lobby_fov", "80", true, false, "", 80, 110)
CreateClientConVar("prsbox_lobby_camera_speed", "10", true, false, "", 5, 100)

---
--- Player client variables
---

PLAYER_STATE = PLAYER_NONE
local PLAYER_VIEW = false


---
--- Materials
---

local logoBackground = Material("prostir/prostir_background.png")
local logo = Material("prostir/prostir_logo.png")

---
--- Menu meta class
---

MENU = MENU or {}

MENU.registeredButtons = {} -- Ця таблиця для реєстрації функціоналу кнопок в головному меню

function MENU:ButtonExist(text)
    for k, info in ipairs(self.registeredButtons) do
        if info["text"] == text then return true end
    end
end

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
        self.InfoMenuOpened = false

        self.Buttons = {}
        self.Windows = {}

        self:SetZPos(10)

        self:SetAlpha(0)
        self:AlphaTo(255, 0.1, 0)

        local buttonPanel = vgui.Create("EditablePanel", self)
        if IsValid(buttonPanel) then
            self.ButtonPanel = buttonPanel

            function buttonPanel:PerformLayout()
                local buttonWide = ScreenScale(150)
                local marginLeft = ScreenScale(25)
                local buttonTall = ScreenScale(20)

                self:SetX(marginLeft)
                self:SetSize(buttonWide, #MENU.registeredButtons * buttonTall)

                self:CenterVertical()
            end
        end
    end

    function PANEL:SetPlayerState(playerState)
        self.PlayerState = playerState
    end

    function PANEL:WindowExists(classname)
        for k, name in ipairs(table.GetKeys(self.Windows)) do
            if name == classname then
                return true
            end
        end

        return false
    end

    function PANEL:OpenWindow(classname, windowname, closebutton, wide, tall, data)
        if self:WindowExists(classname) then return end
        
        local window = vgui.Create("PRSBOX.Lobby.Window", self)
        window:SetLobby(self)
        window:SetCloseButton(closebutton)
        window:SetInfoPanel(classname)
        window:SetWindowSize(wide, tall)
        window:SetWindowName(windowname)
        window:GiveData(data)

        self.Windows[classname] = {self.PlayerState, window}
    end

    function PANEL:GetWindow(classname)
        local window = self.Windows[classname][2]
        if not IsValid(window) then return end

        return window.InfoPanel
    end

    function PANEL:OnWindowClose(classname)
        if not self:WindowExists(classname) then return end
        
        self.Windows[classname] = nil
    end

    function PANEL:ChangeZPosWindow(classname)
        for k, name in ipairs(table.GetKeys(self.Windows)) do
            local window = self.Windows[name][2]

            if name == classname then
                window:SetZPos(11)

                continue
            end

            window:SetZPos(10)
        end
    end

    function PANEL:InitButtons()
        local buttonPanel = self.ButtonPanel
        if not IsValid(buttonPanel) then return end

        hook.Run("OnMenuOpen", self, self.PlayerState)

        PLAYER_VIEW = true

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

            table.insert(self.Buttons, button)
        end
    end

    function PANEL:DeleteAllButtons()
        for k, button in ipairs(self.Buttons) do
            if not IsValid(button) then continue end

            button:Remove()
        end

        self.Buttons = {}
    end

    function PANEL:OpenMenu()
        self:AlphaTo(255, 0.1, 0)

        self:Show()
        self:MakePopup()
    end

    function PANEL:CloseMenu()
        self:AlphaTo(0, 0.1, 0, function ()
            hook.Run("OnMenuClose", self)

            timer.Simple(0.9, function ()
                PLAYER_VIEW = false
            end)

            PLAYER_STATE = PLAYER_NONE
            self:DeleteAllButtons()
            self:Hide()
        end)
    end

    function PANEL:PerformLayout(w, h)
        local scrW, scrH = ScrW(), ScrH()
        self:SetSize(scrW, scrH)
    end

    function PANEL:Paint(w, h)
        local wide = ScreenScale(400)

        draw.SimpleLinearGradient(0, 0, wide, h, Color(0, 0, 0, 255), Color(0, 0, 0, 0), true)

        local logoBackWide = ScreenScale(170)
        local logoBackTall = ScreenScale(47)

        local logoSize = ScreenScale(60)

        local buttonPanel = self.ButtonPanel
        if not IsValid(buttonPanel) then return end

        local logoX = ScreenScale(25)
        local logoXMargin = ScreenScale(10)
        local logoYMargin = ScreenScale(20)

        if not buttonPanel:IsVisible() then return end

        local y = buttonPanel:GetY() - logoBackTall - logoYMargin

        surface.SetMaterial(logoBackground)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(logoX, y, logoBackWide, logoBackTall)

        surface.SetMaterial(logo)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(logoX + logoXMargin, buttonPanel:GetY() - logoYMargin - logoSize / 2 - logoBackTall / 2, logoSize, logoSize)
    end

    vgui.Register("PRSBOX.Lobby.Menu", PANEL, "EditablePanel")
end

local function openMainMenu(playerState)
    if not IsValid(MAIN_MENU) then
        MAIN_MENU = vgui.Create("PRSBOX.Lobby.Menu")
    end

    PLAYER_STATE = playerState

    local ply = LocalPlayer()
    if IsValid(ply) then
        local plyAngles = ply:GetAngles()
        ply:SetEyeAngles(Angle(0, plyAngles.y, 0)) 
    end

    MAIN_MENU:OpenMenu()
    MAIN_MENU:SetPlayerState(playerState)
    MAIN_MENU:InitButtons()
end

---
--- Player camera view
---

local camPos = Vector()
local camAng = Angle()
local camFov = 0

hook.Add("CalcView", "PRSBOX.Lobby.Camera", function (ply, pos, angles, fov)
    if not IsValid(ply) then return end
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

    if PLAYER_VIEW then
        return view
    end
end)

---
--- Buttons
---

MENU:RegisterButton("Почати гру", 1, PLAYER_LOBBY, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local completeRahist = ply:GetNWBool("PRSBOX.Net.CompleteRashist", false)

    if completeRahist then
        RunConsoleCommand("prsbox_lobby_spawn")
        menu:CloseMenu()

        return
    end

    menu:OpenWindow("PRSBOX.Rashist", "Rahist tester", false, 380, 300)
end)

hook.Add("PRSBOX.RahistTestEnd", "PRSBOX.SetPlayerNone", function ()
    PLAYER_STATE = PLAYER_NONE
end)

MENU:RegisterButton("Продовжити гру", 1, PLAYER_PAUSE, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    menu:CloseMenu()
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
    if PLAYER_STATE == PLAYER_PAUSE then return end

    openMainMenu(PLAYER_LOBBY)
end)

net.Receive("PRSBOX.Lobby.CheckDeath", function (len, ply)
    if PLAYER_STATE == PLAYER_NONE  then return end
    
    if IsValid(MAIN_MENU) then
        PLAYER_STATE = PLAYER_NONE

        MAIN_MENU:CloseMenu()
    end
end)

net.Receive("PRSBOX.Lobby.OpenWindow", function (len)
    local windowName = net.ReadString()
    local windowTitle = net.ReadString()
    local closeButton = net.ReadBool()
    local wide = net.ReadInt(11)
    local tall = net.ReadInt(11)
    local open = net.ReadBool()
    local data = net.ReadTable()

    if open and PLAYER_STATE == PLAYER_NONE then
        openMainMenu(PLAYER_PAUSE)
    end

    MAIN_MENU:OpenWindow(windowName, windowTitle, closeButton, wide, tall, data)
end)

---
--- Open escape lobby
---

hook.Add("PreRender", "PRSBOX.Lobby.Open", function ()
    if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
        local ply = LocalPlayer()
        gui.HideGameUI()
        if not IsValid(ply) then return end

        if PLAYER_STATE == PLAYER_LOBBY then return end

        if not ply:Alive() then
            RunConsoleCommand("prsbox_lobby_test")
            return
        end

        if PLAYER_STATE == PLAYER_NONE then
            if PLAYER_VIEW then return end

            openMainMenu(PLAYER_PAUSE)
        else
            MAIN_MENU:CloseMenu()
        end
    end
end)

hook.Add("HUDShouldDraw", "PRSBOX.Lobby.HideCrosshair", function (name)
    if name == "CHudCrosshair" and PLAYER_STATE ~= PLAYER_NONE then
        return false
    end
end)