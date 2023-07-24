surface.CreateFont("PrMarkdown.PlainText", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(12),
    ["extended"] = true,
    ["weight"] = 500,
    ["antialias"] = true
})

do -- heading 1 (# Heading)
    local element_name = "PrMarkdown.Heading1"
    local font_size = ScreenScale(20)
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = font_size,
        ["extended"] = true,
        ["weight"] = 700,
        ["antialias"] = true
    })

    do
        local PANEL = {}

        function PANEL:Init()
            self:SetFont(element_name)
            self:SetColor(COLOR_WHITE)
        end

        function PANEL:PerformLayout(w, h)
            self:SetTall(font_size)
            self:DockMargin(5, 5, 5, 5)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do -- heading 2 (## Heading)
    local element_name = "PrMarkdown.Heading2"
    local font_size = ScreenScale(18)
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = font_size,
        ["extended"] = true,
        ["weight"] = 700,
        ["antialias"] = true
    })

    do
        local PANEL = {}

        function PANEL:Init()
            self:SetFont(element_name)
            self:SetColor(COLOR_WHITE)
        end

        function PANEL:PerformLayout(w, h)
            self:SetTall(font_size)
            self:DockMargin(5, 5, 5, 5)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do -- heading 3 (### Heading)
    local element_name = "PrMarkdown.Heading3"
    local font_size = ScreenScale(16)
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = font_size,
        ["extended"] = true,
        ["weight"] = 700,
        ["antialias"] = true
    })

    local PANEL = {}

    function PANEL:Init()
        self:SetFont(element_name)
        self:SetColor(COLOR_WHITE)
    end

    function PANEL:PerformLayout(w, h)
        self:SetTall(font_size)
        self:DockMargin(5, 5, 5, 5)
    end

    vgui.Register(element_name, PANEL, "DLabel")
end

do
    local element_name = "PrMarkdown.PlainText"

    local PANEL = {}

    function PANEL:Init()
        self:SetFont(element_name)
        self:SetColor(COLOR_WHITE)
    end

    function PANEL:PerformLayout(w, h)
        self:SetTall(ScreenScale(12))
        self:DockMargin(ScreenScale(5), 1, 1, 1)
    end

    vgui.Register(element_name, PANEL, "DLabel")
end


do -- unordered list item (- item)
    local PANEL = {}

    PANEL.SetText_Base = FindMetaTable( "Panel" ).SetText

    function PANEL:Init()
        self:SetText_Base("")
        self:SetFont("PrMarkdown.PlainText")
    end

    function PANEL:SetText(text)
        self.Text = tostring("• " .. text)
    end

    function PANEL:GetText()
        return self.Text or ""
    end

    function PANEL:PerformLayout(w, h)
        self:SetTall(ScreenScale(12))
        self:DockMargin(ScreenScale(8), 2, 1, 2)
    end

    function PANEL:Paint(w, h)
	    local TextColor = COLOR_WHITE

	    surface.SetFont( self:GetFont() or "default" )
	    surface.SetTextColor( TextColor )
	    surface.SetTextPos(0, 0)
	    surface.DrawText( self:GetText() )
    end

    vgui.Register("PrMarkdown.UnorderedListItem", PANEL, "DLabel")
end

do -- ordered list item (1. item)
    local PANEL = {}

    function PANEL:Init()
        self:SetFont("PrMarkdown.PlainText")
        self:SetColor(COLOR_WHITE)
    end

    function PANEL:PerformLayout(w, h)
        self:SetTall(ScreenScale(12))
        self:DockMargin(ScreenScale(8), 2, 1, 2)
    end

    vgui.Register("PrMarkdown.OrderedListItem", PANEL, "DLabel")
end

