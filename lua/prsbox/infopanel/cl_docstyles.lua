do
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
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do
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
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do
    local element_name = "PrMarkdown.Heading3"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(12),
        ["extended"] = true,
        ["weight"] = 700,
        ["antialias"] = true
    })

    do
        local PANEL = {}

        function PANEL:Init()
            self:SetFont(element_name)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do
    local element_name = "PrMarkdown.PlainText"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(8),
        ["extended"] = true,
        ["weight"] = 500,
        ["antialias"] = true
    })

    do
        local PANEL = {}

        function PANEL:Init()
            self:SetFont(element_name)
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end

do
    local element_name = "PrMarkdown.UnorderedListItem"
    surface.CreateFont(element_name, {
        ["font"] = "Roboto",
        ["size"] = ScreenScale(8),
        ["extended"] = true,
        ["weight"] = 500,
        ["antialias"] = true
    })

    do
        local PANEL = {}

        function PANEL:Init()
            self:SetFont(element_name)
        end

        function PANEL:SetText(text)
            self.Text = "• " + text
        end

        vgui.Register(element_name, PANEL, "DLabel")
    end
end
