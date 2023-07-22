surface.CreateFont("PrMarkdown.PlainText", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(8),
    ["extended"] = true,
    ["weight"] = 500,
    ["antialias"] = true
})

do -- heading 1 (# Heading)
    local element_name = "PrMarkdown.Heading1"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(20),
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
            self:SetPos(5, h)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do -- heading 2 (## Heading)
    local element_name = "PrMarkdown.Heading2"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(16),
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
            self:SetPos(5, h)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do -- heading 3 (### Heading)
    local element_name = "PrMarkdown.Heading3"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(12),
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
        self:SetPos(5, h)
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
        print(w, h)
        self:SetPos(5, h)
    end

    vgui.Register(element_name, PANEL, "DLabel")
end


do -- unordered list item (- item)
    local PANEL = {}

    function PANEL:Init()
        self:SetFont("PrMarkdown.PlainText")
        self:SetColor(COLOR_WHITE)
    end

    function PANEL:SetText(text)
        self.Text = "• " + text
    end

    function PANEL:PerformLayout(w, h)
        self:SetPos(10, h)
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
        self:SetPos(10, h)
    end

    vgui.Register("PrMarkdown.OrderedListItem", PANEL, "DLabel")
end

