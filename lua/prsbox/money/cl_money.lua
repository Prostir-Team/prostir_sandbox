local scrW, scrH = ScrW(), ScrH()

hook.Add( "OnScreenSizeChanged", "PRSBOX.MONEY.SCR", function()
    scrW, scrH = ScrW(), ScrH()
end)

local color_white = Color(255, 255, 255)

local localPlayer = LocalPlayer()

local MoneyPanel, MoneyTradeMenu = {}, {}

local MPW, MPH = 200, 29

local Isize = 24
local menuicon = Material("icon16/bullet_toggle_plus.png")

local clrR, clrG = Color(255,0,0), Color(0,153,0)

function TransferMoneyToPlayer(ply, amount)
    if !IsValid(ply) then return end
    if amount > PRSBOXLOCALPLAYERMONEY then return end
    if amount < 1 then return end
    net.Start("PRSBOX.SendMoney")
        net.WriteEntity(ply)
        net.WriteUInt(amount, 19 )
    net.SendToServer()
end

local function DropMoney( amount )
    if amount > PRSBOXLOCALPLAYERMONEY then return end
    if amount < 1 then return end

    net.Start("PRSBOX.DropMoney")
        net.WriteUInt(amount, 19 )
    net.SendToServer()
end

function OpenMoneyTransferDialog()
    g_SpawnMenu:Close()
    if IsValid(MoneyTradeMenu) then
        MoneyTradeMenu:RequestFocus()
        return
    end
    MoneyTradeMenu = vgui.Create( "DFrame" )
    MoneyTradeMenu:SetSize( 400, 200 )
    MoneyTradeMenu:Center()
    MoneyTradeMenu:MakePopup()
    MoneyTradeMenu:SetTitle("Передача грошей")

    MoneyTradeMenu.LabelInfo = vgui.Create( "DLabel", MoneyTradeMenu )
    MoneyTradeMenu.LabelInfo:Dock( TOP )
    MoneyTradeMenu.LabelInfo:SetText( "" )
    MoneyTradeMenu.LabelInfo:SetContentAlignment(5)

    MoneyTradeMenu.LabelInfo.Think = function( self )
        if !PRSBOXLOCALPLAYERMONEY then return end
        if !self.Num or self.Num != PRSBOXLOCALPLAYERMONEY then
            self.Num = PRSBOXLOCALPLAYERMONEY
            self:SetText( string.format( "Ваш баланс: %s ₴", string.Comma(PRSBOXLOCALPLAYERMONEY) ) )
        end
    end

    MoneyTradeMenu.NumSlider = vgui.Create( "DNumSlider", MoneyTradeMenu )
    MoneyTradeMenu.NumSlider:Dock( TOP )
    MoneyTradeMenu.NumSlider:SetSize( 300, 100 )
    MoneyTradeMenu.NumSlider:SetText( "Сума передачі" )
    MoneyTradeMenu.NumSlider:SetMin( 1 )
    MoneyTradeMenu.NumSlider:SetValue(100)
    MoneyTradeMenu.NumSlider:SetMax( PRSBOXLOCALPLAYERMONEY )
    MoneyTradeMenu.NumSlider:SetHeight(22)
    MoneyTradeMenu.NumSlider:SetDecimals( 0 )
    MoneyTradeMenu.NumSlider.Think = function( self )
        MoneyTradeMenu.NumSlider:SetMax( PRSBOXLOCALPLAYERMONEY )
    end
    MoneyTradeMenu.NumSlider.OnValueChanged = function( self, val )
        local v = math.floor(math.Clamp(val, 1, PRSBOXLOCALPLAYERMONEY))
        local nick = MoneyTradeMenu.TargetPlayer and MoneyTradeMenu.TargetPlayer:Nick() or "--"
        MoneyTradeMenu.SendButton:SetText( string.format("Надіслати %s %s ₴", nick, v ) )
        MoneyTradeMenu.DropButton:SetText( string.format("Викласти %s ₴", v ) )
    end

    MoneyTradeMenu.SendButton = vgui.Create( "DButton", MoneyTradeMenu )
    MoneyTradeMenu.SendButton:SetText( string.format("Надіслати %s %s ₴", "--", math.floor( MoneyTradeMenu.NumSlider:GetValue() ) ) )
    MoneyTradeMenu.SendButton:Dock(BOTTOM)
    MoneyTradeMenu.SendButton:DockPadding(2,2,2,2)
    MoneyTradeMenu.SendButton.DoClick = function()
        TransferMoneyToPlayer(MoneyTradeMenu.TargetPlayer, math.floor( MoneyTradeMenu.NumSlider:GetValue()) )
    end

    MoneyTradeMenu.DropButton = vgui.Create( "DButton", MoneyTradeMenu )
    MoneyTradeMenu.DropButton:SetText( string.format("Викласти %s ₴", math.floor( MoneyTradeMenu.NumSlider:GetValue() ) ) )
    MoneyTradeMenu.DropButton:Dock(BOTTOM)
    MoneyTradeMenu.DropButton:DockPadding(2,2,2,2)
    MoneyTradeMenu.DropButton.DoClick = function()
        DropMoney( math.floor( MoneyTradeMenu.NumSlider:GetValue() ) )
    end

    MoneyTradeMenu.Panel = vgui.Create( "DPanel", MoneyTradeMenu )
    MoneyTradeMenu.Panel:Dock( FILL )
    MoneyTradeMenu.Panel:DockPadding(2,2,2,2)

    MoneyTradeMenu.ScrollPanel = vgui.Create( "DScrollPanel", MoneyTradeMenu.Panel )
    MoneyTradeMenu.ScrollPanel:Dock( FILL )

    local plytbl = player.GetAll()

    for k, ply in ipairs(plytbl) do
        if !IsValid(ply) then continue end
        if ply == LocalPlayer() then continue end
        local DButton = MoneyTradeMenu.ScrollPanel:Add( "DButton" )
        DButton:SetText( ply:Nick() )
        DButton:Dock( TOP )
        DButton:DockMargin( 0, 0, 0, 5 )
        DButton.DoClick = function(self)
            if !IsValid(ply) then self:Remove() return end
            MoneyTradeMenu.TargetPlayer = ply
            MoneyTradeMenu.SendButton:SetText(string.format("Надіслати %s %s ₴", self:GetText(), math.floor( MoneyTradeMenu.NumSlider:GetValue() ) ) )
        end

        local AvatarImage = vgui.Create("AvatarImage", DButton)
        AvatarImage:SetSize( 18, 18 )
        AvatarImage:AlignTop(2)
        AvatarImage:AlignLeft(2)
        AvatarImage:SetPlayer( ply, 32 )
    end
end

hook.Add( "PopulateMenuBar", "PRSBOX.MoneyMenubar", function( menubar )

    local mx, my, mw, mh = menubar:GetBounds()

    MoneyPanel = vgui.Create( "DPanel", menubar )
    MoneyPanel:SetPos( (scrW * .5) - (MPW * .5), 0)
    MoneyPanel:SetSize( MPW, MPH )

/*---------------------------------------------------------------------------
                                Якщо знадобиться менюшка
---------------------------------------------------------------------------
    MoneyPanel.MenuButton = vgui.Create( "DButton", MoneyPanel )
    MoneyPanel.MenuButton:SetSize(MPH,MPH)
    MoneyPanel.MenuButton:Dock(RIGHT)
    MoneyPanel.MenuButton:SetText( "" )
    MoneyPanel.MenuButton.DoClick = function()
        OpenMoneyTransferDialog()
    end
    local s, s2 = 6, 12
    MoneyPanel.MenuButton.Paint = function(self, w, h )
        local sa, sb = 0, 0
        if self:IsDown() then sa, sb = 5, 10 end
        surface.SetDrawColor( color_white )
        surface.SetMaterial( menuicon )
        surface.DrawTexturedRect( (0 + sa) - s, (0 + sa) - s, s2 + w - sb, s2 + h - sb )
    end
*/
    MoneyPanel.MoneyButton = vgui.Create( "DButton", MoneyPanel )
    MoneyPanel.MoneyButton:SetText( "--" )
    MoneyPanel.MoneyButton:Dock(FILL)
    MoneyPanel.MoneyButton:SetContentAlignment(5)
    MoneyPanel.MoneyButton.Num = false

    MoneyPanel.MoneyButton.DoClick = function( self )
        OpenMoneyTransferDialog()
    end

    MoneyPanel.MoneyButton.Think = function( self )
        if PRSBOXLOCALPLAYERMONEY then
            if !self.Num or self.Num != PRSBOXLOCALPLAYERMONEY then
                self.Num = PRSBOXLOCALPLAYERMONEY
                self:SetText( string.format( "%s ₴", string.Comma(PRSBOXLOCALPLAYERMONEY) ) )
            end
        end
    end

    MoneyPanel.MoneyImage = vgui.Create("DImage", MoneyPanel.MoneyButton)
    MoneyPanel.MoneyImage:SetSize(Isize, Isize)
    MoneyPanel.MoneyImage:SetImage("icon16/money.png")
    //MoneyPanel.MoneyImage:Dock(LEFT)
    local c = (MPH - Isize) * .5
    MoneyPanel.MoneyImage:AlignLeft(c)
    MoneyPanel.MoneyImage:AlignTop(c)
    

    local mbx, mby, mbw, mbh = MoneyPanel.MoneyButton:GetBounds()

    MoneyPanel.ExpenceLabel = vgui.Create( "DLabel", MoneyPanel.MoneyButton )
    MoneyPanel.ExpenceLabel:Dock(FILL)
    MoneyPanel.ExpenceLabel.Num = 0
    MoneyPanel.ExpenceLabel.LastF = 0
    MoneyPanel.ExpenceLabel.FTime = 0
    MoneyPanel.ExpenceLabel.LastA = false
    MoneyPanel.ExpenceLabel.LastB = false
    MoneyPanel.ExpenceLabel:SetText( "" )
    MoneyPanel.ExpenceLabel:SetTextColor(clrR)
    MoneyPanel.ExpenceLabel:SetContentAlignment(2)
    MoneyPanel.ExpenceLabel.AddNum = function( self, amount )
        local s = ""
        MoneyPanel.MoneyButton:SetContentAlignment(8)
        if amount > 0 then
            if self.LastB then self.Num = 0 end
            self:SetTextColor(clrG)
            self.LastA = true
            self.LastB = false
            s = "+"
        elseif amount < 0 then
            if self.LastA then self.Num = 0 end
            MoneyPanel.ExpenceLabel:SetTextColor(clrR)
            self.LastA = false
            self.LastB = true
        else
            self:Hide()
            return
        end
        local a = self.Num + amount
        self:Show()
        self:SetAlpha( 255 )
        self.LastF = RealTime() + 2
        self.FTime = RealTime() + 5
        self:SetText( s .. string.format( "%s ₴", string.Comma(a) ) )
        self.Num = a
    end
    MoneyPanel.ExpenceLabel.Think = function(self)
        local CT = RealTime()
        if self.LastF <= CT and CT <= self.FTime then
            local b = math.Remap( CT, self.LastF, self.FTime, 255, 0)
            self:SetAlpha( b )
        end
        if CT > self.FTime then self:Hide() self.Num = 0 MoneyPanel.MoneyButton:SetContentAlignment(5) end
    end
end )

hook.Add("PRSBOX.OnMoneyChanged", "PRSBOX.MoneyMenuHook", function(old, new)
    old = old or 0
    if !IsValid(MoneyPanel) then return end
    if !IsValid(MoneyPanel.ExpenceLabel) then return end
    MoneyPanel.ExpenceLabel:AddNum(new - old)
end)

surface.CreateFont( "ScoreShow", {
    font="Roboto",
    size=24,
    extended=true
} )

--[[
Панель, яка відповідає візуалізації рахунок й додає грошей за вбивство гравцю.
-- ]]

local mentalyinse

local PANEL = {}

local timeToDelete = 2
local endPointY = 100
local lerpSpeed = 10

local score_margin = 20

function PANEL:Init()
    self.text = ""
    self.curTime = CurTime()
    self.color = color_white

    self.end_timer = false 
    self.end_y = 100
end

function PANEL:SetText(text, color)
    self.text = text

    surface.SetFont("ScoreShow")
    local textWidth = surface.GetTextSize(text)

    self:SetSize(textWidth, 32)
    self:CenterHorizontal()

    self.color = color
end

function PANEL:Think()
    local curTime = CurTime()

    self:SetY(Lerp(FrameTime() * lerpSpeed, self:GetY(), self.end_y))

    if curTime - self.curTime >= timeToDelete and not self.end_timer then
        self.end_timer = true 

        self:AlphaTo(0, FrameTime() * 5, 0, function ()
            self:Remove()
        end)
    end
end

function PANEL:OnAddNewScore()
    self.end_y = self.end_y + score_margin
end

local cl_drawhud = GetConVar("cl_drawhud")

function PANEL:Paint(w, h)
    if ( not cl_drawhud:GetBool() ) then return end
    
    draw.DrawText(self.text, "ScoreShow", 1, 1, color_black, TEXT_ALIGN_LEFT)

    draw.DrawText(self.text, "ScoreShow", 0, 0, self.color, TEXT_ALIGN_LEFT)
end 

vgui.Register("PRSBOX.UI.GetScore", PANEL)

local scores = {}

local function createScore(text, col)
    local score = vgui.Create("PRSBOX.UI.GetScore", GetHUDPanel())
    score:SetText(text, col)

    table.insert(scores, score)

    for k, v in ipairs(scores) do
        if not IsValid(v) then 
            -- table.remove(scores, k)
            continue 
        end

        v:OnAddNewScore()
    end
end

local ptbl = {
    [1] = "Ворога вбито",
    [2] = "Хедшот",
    [3] = "Вбито в ближньому бою",
    [4] = "Вбивсто з літаку",
    [5] = "Ворожу техніку знищено",
    [6] = "Останьою кулею",
    [7] = "Вбивсто технікою",
    [8] = "Вбито шматом гівна",
    [9] = "За вашою технікою слідує ракета, повернення коштів неможливе!!!",
    [10] = "Вбивсто пропом",
    [11] = "Вбито беззбройного гравця",
    [12] = "Вбито AFK гравця",
    [13] = "Техніка в надто поганому стані, повернення коштів неможливе!"
}

local netbitcount = 4

local Tcw, Tcr, Tcg = Color(255, 255, 255, 255), Color( 255, 0, 0, 255), Color( 0, 255, 0, 255)

function MoneyHudAddKillNotify( amount, type )
    local str = ""
    local col = Tcw
    if amount then
        if amount != 0 then
            str = amount .. " ₴ "
        end
        if amount > 0 then
            col = Tcg
        else
            col = Tcr
        end
    end

    if isnumber(type) then
        str = str .. ptbl[type]
    elseif isstring(type) then
        str = str .. type
    end
    
    createScore(str, col)
end

net.Receive("PRSBOX.KillNotify", function()
    local Negate = net.ReadBool()
    local points = net.ReadUInt( 19 )

    if ( Negate ) then
        points = -points
    end

    local type = net.ReadBool()
    local str

    if type then
        str = net.ReadString()
    else
        str = net.ReadUInt(netbitcount)
    end

    MoneyHudAddKillNotify( points, str )
end)