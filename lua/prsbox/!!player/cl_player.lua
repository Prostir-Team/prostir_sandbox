print("player start")

surface.CreateFont("PRSBOX.HUD.Player", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(8),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PRSBOX.HUD.PlayerLittle", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(6),
    ["extended"] = true,
    ["weight"] = 700
})

CreateConVar("prsbox_playermodel", "", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "")

CreateClientConVar("prsbox_hud_x", "0", FCVAR_ARCHIVE, false, "", -50, 50)
CreateClientConVar("prsbox_hud_y", "5", FCVAR_ARCHIVE, false, "", -50, 50)

local lastPlayer = NULL

local alphaTo = 0
local currentAlpha = 0


local function drawTextShadow(text, font, x, y, color, align)
    draw.DrawText(text, font, x + 2, y + 2, Color(0, 0, 0, color.a), align)
    draw.DrawText(text, font, x, y, color, align)
end

hook.Add("HUDDrawTargetID", "PRSBOX.ID", function()
    local scrW, scrH = ScrW(), ScrH()
    
    currentAlpha = Lerp(FrameTime() * 5, currentAlpha, alphaTo)

    if IsValid(lastPlayer) and lastPlayer:IsPlayer() then
        local x, y = GetConVar("prsbox_hud_x"):GetInt() * 2, GetConVar("prsbox_hud_y"):GetInt() * 2

        drawTextShadow(lastPlayer:Nick(), "PRSBOX.HUD.Player", scrW / 2 + x, scrH / 2 + y, Color(255, 255, 255, currentAlpha), TEXT_ALIGN_CENTER)
        drawTextShadow(math.Clamp(lastPlayer:Health(), 0, 110) .. "%", "PRSBOX.HUD.PlayerLittle", scrW / 2 + x, scrH / 2 + y + ScreenScale(8), Color(255, 255, 255, currentAlpha), TEXT_ALIGN_CENTER)
    end
    
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return false end

    local trace = ply:GetEyeTrace()
    local otherPlayer = trace.Entity

    if not IsValid(otherPlayer) or not otherPlayer:IsPlayer() then 
        alphaTo = 0

        return false 
    end

    lastPlayer = otherPlayer
    alphaTo = 1000

    return false
end)

do
    local PANEL = {}

    function PANEL:Init()
        self:SetAlpha(0)

        self:AlphaTo(255, 0.1, 0)

        self.DoRemove = false
        self.CurrentState = 0
    end

    function PANEL:SetNotice(Attacker, Inflictor, Victim)
        self.Attacker = Attacker
        self.Inflictor = Inflictor
        self.Victim = Victim

        self.CurTime = CurTime()

        surface.SetFont("PRSBOX.HUD.Player")
        self.AttackerWide = surface.GetTextSize(self.Attacker)

        surface.SetFont("PRSBOX.HUD.Player")
        self.VictimWide = surface.GetTextSize(self.Victim)

        self:PerformLayout()
    end

    function PANEL:Think()
        if CurTime() - self.CurTime >= 5 and not self.DoRemove then
            local x, y = self:GetX(), self:GetY()
            
            self:MoveTo(x + ScreenScale(100), y, 0.2, 0, -1, function ()
                self:Remove()
            end)
            
            self:AlphaTo(0, 0.1, 0)

            self.DoRemove = true
        end

        local y = self:GetY()
        self:SetY(Lerp(FrameTime() * 10, y, self.MoveY + self.CurrentState * self.AddY))
    end

    function PANEL:OnAddNew()
        local x, y = self:GetX(), self:GetY()
        local tall = self:GetTall()
        
        local margin = ScreenScale(5)

        self.CurrentState = self.CurrentState + 1 
    end

    function PANEL:PerformLayout()
        local wide, tall = ScreenScale(40), ScreenScale(15)
        local scrW, scrH = ScrW(), ScrH()
        local marginHorizontal = ScreenScale(50)
        local marginVertical = ScreenScale(10)
        local margin = ScreenScale(3)

        local realWide = self.AttackerWide + self.VictimWide + wide

        self.AddY = tall + margin

        self:SetSize(realWide, tall)
        self:SetPos(scrW - marginHorizontal - realWide, -marginVertical)

        self.MoveY = marginVertical
    end

    function PANEL:Paint(w, h)
        local x, y = self:LocalToScreen(0, 0)

        -- surface.SetDrawColor(Color(255, 0, 0))
        -- surface.DrawRect(0, 0, w, h)

        drawTextShadow(self.Attacker, "PRSBOX.HUD.Player", 0, ScreenScale(4), Color(255, 255, 255), TEXT_ALIGN_LEFT)
        drawTextShadow(self.Victim, "PRSBOX.HUD.Player", w, ScreenScale(4), Color(255, 255, 255), TEXT_ALIGN_RIGHT)

        killicon.Draw(self.AttackerWide + ScreenScale(40) / 2, ScreenScale(6), self.Inflictor, 255)
    end 

    vgui.Register("PRSBOX.HUD.DeathNotice", PANEL, "EditablePanel")
end

if IsValid(TEST_PANEL) then
    TEST_PANEL:Remove()
end

local deathPanels = {}

local function moveOtherPanels()
    for k, panel in ipairs(deathPanels) do
        if not IsValid(panel) then continue end

        panel:OnAddNew()
    end
end

local function addNewDeath(Attacker, Inflictor, Victim)
    local deathPanel = vgui.Create("PRSBOX.HUD.DeathNotice", GetHUDPanel())
    if IsValid(deathPanel) then
        deathPanel:SetNotice(Attacker, Inflictor, Victim)

        table.insert(deathPanels, deathPanel)

        moveOtherPanels()
    end
end

cvars.AddChangeCallback("prsbox_playermodel", function (convar, old, new)
    net.Start("PRSBOX.Net.PlayerChangeModel")
        net.WriteString(old)
        net.WriteString(new)
    net.SendToServer()
end)

concommand.Add("death_notice", function ()
    addNewDeath("TEST", "suicide", "TEST2")
end)

hook.Add("PRSBOX:AddDeathNoctice", "PRSBOX.CustomDeathNotice", function (Attacker, team1, Inflictor, Victim, team2)
    addNewDeath(Attacker, Inflictor, Victim)

    return true
end)

hook.Add("PRSBOX.ContentIcon.Paint", "TESTPAINT", function (panel, w, h)
    -- draw.DrawText("Hello World", "DermaLarge", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
end)

---
--- New crosshair
---

local DrawCrosshair = false

hook.Add("HUDPaint", "PRSBOX.HUD.Crosshair", function ()
    if not DrawCrosshair then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local crosshairSize = 12
    local crosshairSizeSmall = 2
    local crosshairMaring = 2

    local crosshairMargined = (crosshairSize + crosshairMaring)
    local crosshairSmallMargined = (crosshairSizeSmall + crosshairMaring)

    surface.SetDrawColor(COLOR_BLACK)
    surface.DrawRect(scrW / 2 - crosshairSmallMargined / 2, scrH / 2 - crosshairMargined / 2, crosshairSmallMargined, crosshairMargined)
    surface.DrawRect(scrW / 2 - crosshairMargined / 2, scrH / 2 - crosshairSmallMargined / 2, crosshairMargined, crosshairSmallMargined)

    surface.SetDrawColor(COLOR_WHITE)
    surface.DrawRect(scrW / 2 - crosshairSizeSmall / 2, scrH / 2 - crosshairSize / 2, crosshairSizeSmall, crosshairSize)
    surface.DrawRect(scrW / 2 - crosshairSize / 2, scrH / 2 - crosshairSizeSmall / 2, crosshairSize, crosshairSizeSmall)
end)

hook.Add("HUDShouldDraw", "PRSBOX.Hud.DisableHL2Crosshair", function (name)
    if name == "CHudCrosshair" and DrawCrosshair then
        return false 
    end
end)