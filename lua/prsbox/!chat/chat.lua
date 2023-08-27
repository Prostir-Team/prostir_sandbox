local CvarFadeTime = CreateConVar("prsbox_chat_fadetime", "5", FCVAR_ARCHIVE)
local CvarPanelSize = CreateConVar("prsbox_chat_size", "0.8", FCVAR_ARCHIVE)
local CvarMessageLimit = CreateConVar("prsbox_chat_limit", "50", FCVAR_ARCHIVE)

local cvar = CvarPanelSize:GetFloat()

--[[
	Шрифти
--]]
surface.CreateFont("PRSBOX.Font.SayText", {
	["font"] = "Roboto",
	["extended"] = true,
	["size"] = ScreenScale(8) * cvar,
	["weight"] = 700
})

surface.CreateFont("PRSBOX.Font.TextEntry", {
	["font"] = "Roboto",
	["extended"] = true,
	["size"] = ScreenScale(10) * cvar,
	["weight"] = 700
})

--[[
	Константи
--]]
local color_white = Color( 255, 255, 255 )
local color_yellow = Color( 255, 255, 0 )
local color_blue = Color( 100, 100, 200 )

local chat_background_color = Color( 0, 0, 0, 200 )
local chat_background_color_hovered = Color( 0, 0, 0, 230 )
local chat_gray = Color(126, 126, 126)

local ChatEnabled = false

local user_groups = {
    ["superadmin"] = Color(142, 255, 114),
    ["admin"] = Color(255, 81, 81),
    ["user"] = Color(0, 140, 255)
}

--[[
    Локальні функції
--]]

local function getEmoji(text, character)
    local take = false
    local out = {}
    local word = ""

    for i=1, #text do
        local c = text[i]

        if c == character then
            if take then
                table.insert(out, word)
                
                word = ""
                take = false
            else
                take = true
            end
        else
            if take then
                word = word .. c
            end
        end
    end

    return out
end

local function getPosEmoji(text, character, font)

end

concommand.Add("chat_test", function ()
    PrintTable(getEmoji("Hello :smile: My name is Kyryl!!!!!!! :cock:", ":"))
end)

--[[
	Повідомлення
--]]

do
	local PANEL = {}

	function PANEL:Init()
		self.Color = color_white
		self.ColorChanged = false 
		self.Hide = false 

		timer.Simple(CvarFadeTime:GetInt(), function()
			if not IsValid(self) then return end

			local scroll = self.Scroll
			if IsValid(scroll) then
				self.Hide = true 
				if not scroll.ChatOpened then
					self:AlphaTo(0, 0.1, 0)
				end
			end
		end)

		local richText = vgui.Create("RichText", self)
		if IsValid(richText) then 
			self.RichText = richText
			self.Text = ""
			richText:Dock(FILL)
			richText:SetVerticalScrollbarEnabled(false)
		end
	end

	function PANEL:PerformLayout(w, h)
		local cvar = CvarPanelSize:GetFloat()
		local round = ScreenScale(5) * cvar
		local offset = ScreenScale(2.2) * cvar
		local mt = ScreenScale(10) * cvar
		local parentWide = self:GetParent():GetWide()

		local richText = self.RichText
		if IsValid(richText) then
			richText:SetFontInternal("PRSBOX.Font.SayText")
			richText:SetFGColor(color_white)
			richText:DockMargin(round, offset, 0, 0)
		end

		if self.Done then return end

		surface.SetFont("PRSBOX.Font.SayText")

		local textNewLines = string.Split(self.Text, "\n")
        local newLines = 0

        for k, line in ipairs(textNewLines) do
            local _textSize = surface.GetTextSize(line)

            newLines = newLines + math.ceil(_textSize / (parentWide - round))
        end

        print(newLines)

        local textSize = surface.GetTextSize(self.Text)
        local tall = (newLines * (mt - offset / 1.5)) + offset * 2
        
        if newLines == 1 then
            tall = mt + offset
            
            self:SetWide(textSize + round * 3)
            self:DockMargin(0, offset, parentWide - textSize - round * 3, 0)
        end

		self.Done = true 
		self:SetTall(tall)
	end

	function PANEL:Setup(data)
		local richText = self.RichText
		
		if not IsValid(richText) then return end
		for k, v in ipairs(data) do
			if istable(v) then
				richText:InsertColorChange(v.r, v.g, v.b, 255)

				if not self.ColorChanged then
					self.Color = v
					self.ColorChanged = true 
				end
			elseif isstring(v) then
				richText:AppendText(v)
				self.Text = self.Text .. v
			elseif v:IsPlayer() then
				local ply = v

				local user = ply:GetUserGroup()
				local color = user_groups[user]

				if not self.ColorChanged then
					self.Color = color
					self.ColorChanged = true
				end

				local text = ply:Nick()

				richText:InsertColorChange(color.r, color.g, color.b, 255)
				richText:AppendText(text)
				richText:InsertColorChange(255, 255, 255, 255)

				self.Text = self.Text .. text
			end
		end
	end

	function PANEL:Paint(w, h)
		local cvar = CvarPanelSize:GetFloat()
		
		local round = ScreenScale(6) * cvar
		
		-- draw.RoundedBoxEx(round, 0, 0, round * 0.8, h, self.Color, true, false, true, false)
		-- draw.RoundedBoxEx(round, round * 0.8, 0, w - round, h, chat_background_color, false, true, false, true)

        draw.RoundedBox(round, 0, 0, w, h, chat_background_color)
    end

	vgui.Register("PRSBOX.Chat.Message", PANEL, "DPanel")
end

--[[
	Панель повідомлень
--]]

do
	local PANEL = {}

	function PANEL:Init()
		
		self.Messages = {}
		self.ChatOpened = false 

		self:SetPaintBackground(false)

		local sbar = self:GetVBar()
		if not IsValid(sbar) then return end

		sbar:SetHideButtons(true)

        function sbar:Paint(w, h)
			local cvar = CvarPanelSize:GetFloat()
            draw.RoundedBox(ScreenScale(5) * cvar, 0, 0, w, h, chat_background_color)
        end
        function sbar.btnUp:Paint(w, h) end
        function sbar.btnDown:Paint(w, h) end
        function sbar.btnGrip:Paint(w, h)
            local cvar = CvarPanelSize:GetFloat()
			draw.RoundedBox(ScreenScale(5) * cvar, 0, 0, w, h, chat_background_color_hovered)
        end
	end

	function PANEL:ScrollDown()
		local sbar = self:GetVBar()
		if not IsValid(sbar) then return end

		timer.Simple(0.08, function ()
			sbar:SetScroll(sbar.CanvasSize)
		end)
	end

	function PANEL:AddMessage(data)
		local cvar = CvarPanelSize:GetFloat()

		--local message = vgui.Create("PRSBOX.Chat.Message")
		local message = self:Add( "PRSBOX.Chat.Message" )

		if not IsValid(message) then return end

		message:SetWide(self:GetWide())
		message:Setup(data)
		message:DockMargin(0, ScreenScale(2.5) * cvar, 0, 0)
		message:Dock(TOP)
		message.Scroll = self
		
		table.insert(self.Messages, message)
		--self:AddItem(message)

		self:ScrollDown()
		self:ClearMessages()
	end

	function PANEL:ClearMessages()
		local messageLimit = CvarMessageLimit:GetInt()
		
		if #self.Messages < messageLimit then return end

		local message = self.Messages[1]
		if not IsValid(message) then return end

		message:Remove()

		table.RemoveByValue(self.Messages, message)
	end

	function PANEL:Clear()
		local childs = self.Messages
		if table.Empty(childs) then return end
		for i,pnl in ipairs(childs) do
			pnl:Remove()
		end
	end

	function PANEL:OpenMessages()
		local sbar = self:GetVBar()
		if not IsValid(sbar) then return end

		sbar:SetAlpha(255)

		local messages = self.Messages

		for k, message in ipairs(messages) do
			message:AlphaTo(255, 0.05, 0)
		end

		self:ScrollDown()
	end

	function PANEL:CloseMessages()
		local sbar = self:GetVBar()
		if not IsValid(sbar) then return end

		sbar:SetAlpha(0)

		local messages = self.Messages

		for k, message in ipairs(messages) do
			if message.Hide then
				message:AlphaTo(0, 0.05, 0)
			end	
		end

		self:ScrollDown()
	end

	vgui.Register("PRSBOX.Chat.Scroll", PANEL, "DScrollPanel")
end

--[[
	Основна панель
--]]

do
	local PANEL = {}

	function PANEL:Init()
		local bottom = vgui.Create( "EditablePanel", self )

		if IsValid( bottom ) then
			self.Bottom = bottom
			bottom:Dock( BOTTOM )
			bottom.AlphaLine = 150
			bottom.AlphaToLine = 150

			function bottom:Paint( w, h )
				local cvar = CvarPanelSize:GetFloat()

				local parent = self:GetParent()

				if not IsValid(parent) then return end

				local send = parent.SendButton

				if not IsValid(send) then return end
				
				local sw = send:GetWide()
				local offest = ScreenScale(5) * cvar
				local line = ScreenScale(6) * cvar

				draw.RoundedBoxEx(offest, 0, 0, w - sw, h, chat_background_color, true, false, true, false)
				if send:IsHovered() then
					draw.RoundedBoxEx(offest, w - sw, 0, sw, h, chat_background_color_hovered, false, true, false, true)
					
					self.AlphaToLine = 0
				else
					draw.RoundedBoxEx(offest, w - sw, 0, sw, h, chat_background_color, false, true, false, true)

					self.AlphaToLine = 150
				end

				self.AlphaLine = Lerp(0.5, self.AlphaLine, self.AlphaToLine)

				local color = Color(color_white.r, color_white.g, color_white.b, self.AlphaLine)

				surface.SetDrawColor(color)
				surface.DrawRect(w - sw, line, 1, h - line * 2)
			end

			function bottom:SendMessage()
				local parent = self:GetParent()

				if not IsValid(parent) then return end 
				
				local entry = parent.TextEntry

				if not IsValid(entry) then return end

				LocalPlayer():ConCommand("say \"" .. entry:GetText() .. "\"")
			end

			function bottom:CloseChat()
				local parent = self:GetParent()
				if IsValid( parent ) then
					parent:CloseChat()
				end
			end

			local entry = vgui.Create( "DTextEntry", bottom )
			if IsValid( entry ) then
				self.TextEntry = entry
				entry:Dock( FILL )

				entry:SetPlaceholderText( "Повідомлення..." )
				entry:SetFont( "PRSBOX.Font.TextEntry" )
				entry:SetCursorColor( color_yellow )
				entry:SetTextColor( color_white )
				entry:SetPaintBackground( false )
				

				function entry:OnEnter()
					local parent = self:GetParent()
					if not IsValid(parent) then return end
					
					LocalPlayer():ConCommand("say \"" .. entry:GetText() .. "\"")

					parent:CloseChat()
				end

				function entry:OnTextChanged()
					local panel = self:GetParent()
					
					if not IsValid(panel) then return end

					local chatPanel = panel:GetParent()

					if not IsValid(chatPanel) then return end

					local send = chatPanel.SendButton

					if not IsValid(send) then return end

					local text = self:GetText()

					if text == "" then
						send:SetText("Close")
					else
						send:SetText("Send")
					end
				end

				function entry:OnKeyCode(key)
					local parent = self:GetParent()
					if not IsValid(parent) then return end
					
					if key == KEY_ESCAPE or key == KEY_BACKQUOTE then
						parent:CloseChat()
						gui.HideGameUI()
					end
				end
			end

			local send = vgui.Create( "DButton", bottom )
			if IsValid(send) then
				self.SendButton = send
				send:Dock(RIGHT)

				send:SetFont( "PRSBOX.Font.TextEntry" )
				send:SetPaintBackground( false )
				send:SetTextColor( color_white )
				send:SetText("Close")

				function send:DoClick()
					local panel = self:GetParent()
					
					if not IsValid(panel) then return end

					panel:SendMessage()

					panel:CloseChat()
				end
			end
		end

		local history = vgui.Create( "PRSBOX.Chat.Scroll", self )
		if IsValid( history ) then
			self.History = history
			history:Dock( FILL )
		end
	end

	function PANEL:PerformLayout( w, h )
		local cvar = CvarPanelSize:GetFloat()

		local cw, ch = ScreenScale( 250 ) * cvar, ScreenScale( 230 ) * cvar
		local cx, cy = ScreenScale( 13.6 ), ScreenScale( 45 )

		self:SetSize( cw, ch )
		self:SetPos( cx, ScrH() - cy - ch ) 

		local offset = ScreenScale( 5 ) * cvar

		local bottom = self.Bottom
		if IsValid( bottom ) then
			bottom:SetTall( ScreenScale( 20 ) * cvar )
		end

		local entry = self.TextEntry
		if IsValid( entry ) then
			entry:DockMargin( offset, offset, 0, offset )
		end

		local history = self.History
		if IsValid(history) then
			history:DockMargin(0, 0, 0, offset)
		end
	end

	function PANEL:AddMessage(data)
		local history = self.History
		if IsValid(history) then
			history:AddMessage(data)
		end
	end

	function PANEL:OpenChat()
		self:MakePopup()
		self.TextEntry:RequestFocus()

		local bottom = self.Bottom
		if IsValid( bottom ) then
			bottom:SetAlpha(0)
			bottom:Show()
			bottom:AlphaTo(255, 0.05, 0)
		end

		local history = self.History
		if IsValid(history) then
			history.ChatOpened = true

			history:OpenMessages()
		end

		hook.Run( "StartChat" )
	end

	function PANEL:CloseChat()
		local cvar = CvarPanelSize:GetFloat()
		
		self:SetKeyboardInputEnabled( false )
		self:SetMouseInputEnabled( false )

		local offset = ScreenScale(2.5) * cvar

		local entry = self.TextEntry
		if IsValid(entry) then
			entry:SetText("")
		end

		local send = self.SendButton
		if IsValid(send) then
			send:SetText("Close")
		end

		local bottom = self.Bottom
		if IsValid( bottom ) then
			bottom:AlphaTo(0, 0.05, 0, function()
				bottom:Hide()
			end)
		end

		local history = self.History
		if IsValid(history) then
			history.ChatOpened = false
			history:CloseMessages()
		end

		hook.Run( "FinishChat" )
	end

	vgui.Register( "PRSBOX.Chat", PANEL, "EditablePanel" )

end

if IsValid( PRSBOX_CHAT ) then
	PRSBOX_CHAT:Remove()
end

local function BindPress( ply, bind, pressed )
	if pressed and string.sub( bind, 1, 11 ) == "messagemode" then
		if not IsValid( PRSBOX_CHAT ) then
			PRSBOX_CHAT = vgui.Create( "PRSBOX.Chat" )
		end

		PRSBOX_CHAT:OpenChat()

		return true
	end
end

local function ChatHide( name )
	if (name == "CHudChat") then
		return false
	end
end

local PLAYER = FindMetaTable("Player")

local reg = debug.getregistry()

LegacyChatAddText = LegacyChatAddText or chat.AddText
LegacyPrintMessage = LegacyPrintMessage or reg.Player.PrintMessage
LegacyChatPrint = LegacyChatPrint or reg.Player.ChatPrint

local function ChatSetText( ... )
	if not ChatEnabled then
		local data = { ... }
		LegacyChatAddText( data ) 
		return 
	end
	if not IsValid(PRSBOX_CHAT) then
		PRSBOX_CHAT = vgui.Create("PRSBOX.Chat")
		PRSBOX_CHAT:OpenChat()
		PRSBOX_CHAT:CloseChat()
	end

	local data = {...}

	PRSBOX_CHAT:AddMessage(data)
end

local function ChatPrint( ply, msg )
	ChatSetText( color_blue, msg )
end

local function PrintMessage( ply, type, msg )
	if type != 3 then LegacyPrintMessage( ply, type, msg ) return end
	ChatSetText( color_blue, msg )
end

local function EnableBetterChat()
    hook.Add( "PlayerBindPress", "PROSTIR.OverrideChatBinds", BindPress )
    hook.Add("HUDShouldDraw", "PROSTIR.DisableDefaultChat", ChatHide )
    chat.AddText = ChatSetText
    PLAYER.PrintMessage = PrintMessage
    PLAYER.ChatPrint = ChatPrint
end

local function DisableBetterChat()
    hook.Remove("PlayerBindPress", "PROSTIR.OverrideChatBinds")
    hook.Remove("HUDShouldDraw", "PROSTIR.DisableDefaultChat")
    chat.AddText = LegacyChatAddText
    PLAYER.PrintMessage = LegacyPrintMessage
    PLAYER.ChatPrint = LegacyChatPrint
end

local function ChatSwitch( bl )
    if bl then
    	ChatEnabled = true
        EnableBetterChat()
        return
    end
    ChatEnabled = false
    DisableBetterChat()
end

local cvarbl = CreateConVar("prsbox_chat_work", "1", FCVAR_ARCHIVE)

ChatSwitch( cvarbl:GetBool() )

cvars.AddChangeCallback("prsbox_chat_size", function(convar_name, value_old, value_new)
	local cvar = CvarPanelSize:GetFloat()
	
	surface.CreateFont("PRSBOX.Font.SayText", {
		["font"] = "Roboto",
		["extended"] = true,
		["size"] = ScreenScale(8) * cvar,
		["weight"] = 700
	})

	surface.CreateFont("PRSBOX.Font.TextEntry", {
		["font"] = "Roboto",
		["extended"] = true,
		["size"] = ScreenScale(10) * cvar,
		["weight"] = 700
	})
end)

cvars.AddChangeCallback("prsbox_chat_work", function(convar_name, value_old, value_new)
    ChatSwitch( tobool(value_new) )
end)

cvars.AddChangeCallback("prsbox_chat_limit", function(convar_name, value_old, value_new)
    LocalPlayer():ConCommand("prsbox_chat_clear")
end)


local function killfunc( animData, panel )
	panel:Remove()
end

concommand.Add("prsbox_chat_clear", function()
	if !PRSBOX_CHAT then return end
	for _, pnl in ipairs(PRSBOX_CHAT.History.Messages) do
		pnl:AlphaTo(0, 0.1, 0, killfunc)
	end
	PRSBOX_CHAT.History.Messages = {}
end)

concommand.Add("chat_test_message", function ()
	chat.AddText(Color(255, 255, 255), "Test Messageashdjhasjkdhjakshdjlkhasj hhas hdjahs lhdashj dhajksh jdlasdh jashdjk hlajskhd lajshld jka\nTest Message\nTest Message\nTest Message\nTest Message")	
end)
concommand.Add("chat_test_message2", function ()
	chat.AddText(Color(255, 255, 255), "d jahlsdh ajkshdjklha sjhdja shjhdas jkhdjkahsl jkdash djkhasjhd jash;jdh jashjdhla shjdhjkas;dj ashjkdhjka shjkdhsaj khjkdlhaj skhdjkhas jkhdjkalshjd hajkshdj khasljkdh jkashdjkh ajkshdjkahs djklahsjkh djakshd ajlkshfjqhjwhquehuwq ndquwh duqwiodj qoijwdqpwjd oipqjwdi")	
end)