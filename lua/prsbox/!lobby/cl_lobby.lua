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
        self:MakePopup()

        self.InfoMenuOpened = false

        self:SetZPos(10)

        self:SetAlpha(0)
        self:AlphaTo(255, 0.1, 0)
        local buttonPanel = vgui.Create("EditablePanel", self)
        if IsValid(buttonPanel) then
            self.ButtonPanel = buttonPanel

            function buttonPanel:PerformLayout()
                -- local scrW, scrH = ScrW(), ScrH()

                local buttonWide = ScreenScale(150)
                -- local marginTopBottom = ScreenScale(100)
                local marginLeft = ScreenScale(25)
                local buttonTall = ScreenScale(20)

                self:SetX(marginLeft)
                self:SetSize(buttonWide, #MENU.registeredButtons * buttonTall)

                self:CenterVertical()
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
                -- local buttonWide = ScreenScale(150)
                local buttonMarginLeft = ScreenScale(25)
                -- local marginLeft = ScreenScale(5)

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

    function PANEL:OpenInfoMenu(className, createBackButton)
        local buttonPanel = self.ButtonPanel
        local infoPanel = self.InfoPanel

        if not IsValid(buttonPanel) then return end
        if not IsValid(infoPanel) then return end

        local backButton = infoPanel.BackButton
        if IsValid(backButton) then
            if createBackButton == true or createBackButton == nil then
                backButton:Show()
            else
                backButton:Hide()
            end
        end

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

        hook.Run("OnMenuOpen", self, self.PlayerState)

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

    function PANEL:CloseMenu()
        self:AlphaTo(0, 0.1, 0, function ()
            hook.Run("OnMenuClose", self)

            self:Remove()
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
        PLAYER_STATE = PLAYER_NONE
        RunConsoleCommand("prsbox_lobby_start")
        menu:CloseMenu()

        return
    end

    if IsValid(menu.CheckBox) then return end

    local checkbox = vgui.Create("PRSBOX.Lobby.Checkbox", menu)
    if not IsValid(checkbox) then return end
    menu.CheckBox = checkbox

    checkbox:SetTitle("Пройдіть рашист тест!")
    checkbox:SetText("Вам необхідно пройти рашсит тест, щоб почати гру на сервері! Це було зроблено за для того, щоб русня не змогла завадити грі звичайним українцям, які мирно грають на \"Простір Sandbox!\".")
    checkbox:SetYes("Пройти")
    checkbox:SetState(CHECKBOX_BAD)

    checkbox.OnYesClick = function ()
        menu:OpenInfoMenu("PRSBOX.Rashist", false)

        checkbox:CloseMenu()
    end

    function checkbox:OnNoClick()
        self:CloseMenu()
    end

end)

hook.Add("PRSBOX.RahistTestEnd", "PRSBOX.SetPlayerNone", function ()
    PLAYER_STATE = PLAYER_NONE
end)

MENU:RegisterButton("Продовжити гру", 1, PLAYER_PAUSE, function (menu, button)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    PLAYER_STATE = PLAYER_NONE
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
        if not IsValid(ply) then return end

        if PLAYER_STATE == PLAYER_LOBBY then return end

        if not ply:Alive() then
            RunConsoleCommand("prsbox_lobby_test")
            return
        end

        if IsValid(MAIN_MENU) then
            PLAYER_STATE = PLAYER_NONE

            MAIN_MENU:CloseMenu()
        else
            if PLAYER_VIEW then return end

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

hook.Add("OnMenuOpen", "PRSBOX.Lobby.ViewStart", function (menu, playerState)
    PLAYER_VIEW = true
end)

hook.Add("OnMenuClose", "PRSBOX.Lobby.ViewEnd", function (menu)
    timer.Simple(0.9, function ()
        PLAYER_VIEW = false
    end)
end)