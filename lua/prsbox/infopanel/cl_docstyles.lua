surface.CreateFont("PrMarkdown.PlainText", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(12),
    ["extended"] = true,
    ["weight"] = 500,
    ["antialias"] = true
})

do -- baseclass
    local PANEL = {}

    function PANEL:Init()
        self.font_size = ScreenScale(12)
        self.margin_left = ScreenScale(5)
        self.margin_top = 2
        self.margin_right = 1
        self.margin_bottom = 2
        self:SetColor(COLOR_WHITE)
        self:SetAutoStretchVertical(false)
    end

    function PANEL:PerformLayout(w, h)
        local tall = math.Round(self:GetWide() * self.font_size / w)
        self:SetTall(tall)
        self:DockMargin(self.margin_left, self.margin_top, self.margin_right, self.margin_bottom)
    end

    vgui.Register("PrMarkdown.BaseClass", PANEL, "DLabel")
end

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

    local PANEL = {}

    function PANEL:Init()
        self.font_size = font_size
        self.margin_top = 5
        self.margin_right = 5
        self.margin_bottom = 5
        self:SetFont(element_name)
    end

    vgui.Register(element_name, PANEL, "PrMarkdown.BaseClass")

    PRMARKDOWN_HEADING1 = element_name
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

    local PANEL = {}

    function PANEL:Init()
        self.font_size = font_size
        self.margin_top = 5
        self.margin_right = 5
        self.margin_bottom = 5
        self:SetFont(element_name)
    end

    vgui.Register(element_name, PANEL, "PrMarkdown.BaseClass")

    PRMARKDOWN_HEADING2 = element_name
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
        self.font_size = font_size
        self.margin_top = 5
        self.margin_right = 5
        self.margin_bottom = 5
        self:SetFont(element_name)
    end

    vgui.Register(element_name, PANEL, "PrMarkdown.BaseClass")

    PRMARKDOWN_HEADING3 = element_name
end

do
    local element_name = "PrMarkdown.PlainText"

    local PANEL = {}

    function PANEL:Init()
        self:SetFont(element_name)
    end

    vgui.Register(element_name, PANEL, "PrMarkdown.BaseClass")

    PRMARKDOWN_PLAIN = element_name
end


do -- unordered list item (- item)
    local element_name = "PrMarkdown.UnorderedListItem"

    local PANEL = {}

    PANEL.SetText_Base = FindMetaTable( "Panel" ).SetText

    function PANEL:Init()
        self:SetText_Base("")
        self:SetFont("PrMarkdown.PlainText")
        self.font_size = ScreenScale(12)
    end

    function PANEL:SetText(text)
        self.Text = tostring("• " .. text)
    end

    function PANEL:GetText()
        return self.Text or ""
    end

    function PANEL:PerformLayout(w, h)
        local tall = math.Round(self:GetWide() * self.font_size / w)
        self:SetTall(tall)
        self:DockMargin(ScreenScale(8), 2, 1, 2)
    end

    function PANEL:Paint(w, h)
        local TextColor = COLOR_WHITE

        surface.SetFont( self:GetFont() or "default" )
        surface.SetTextColor( TextColor )
        surface.SetTextPos(0, 0)
        surface.DrawText( self:GetText() )
    end

    vgui.Register(element_name, PANEL, "DLabel") -- it's a special class coz i'm a lazy ass

    PRMARKDOWN_UNORDERED = element_name
end

do -- ordered list item (1. item)
    local element_name = "PrMarkdown.OrderedListItem"
    local PANEL = {}

    function PANEL:Init()
        self.margin_left = ScreenScale(8)
        self:SetFont("PrMarkdown.PlainText")
    end

    vgui.Register(element_name, PANEL, "PrMarkdown.BaseClass")

    PRMARKDOWN_ORDERED = element_name
end

PrMarkdown_Symbols = {
    ["#"] = PRMARKDOWN_HEADING1,
    ["##"] = PRMARKDOWN_HEADING2,
    ["###"] = PRMARKDOWN_HEADING3,
    ["-"] = PRMARKDOWN_UNORDERED
}

