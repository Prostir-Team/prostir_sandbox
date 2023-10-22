local mat_white = Material("vgui/white")

function LerpColor(t, col1, col2)
    if not istable(col1) or not istable(col2) or not isnumber(t) then
        print("Invalid parameters. Expected (number, Color/Vector, Color/Vector, number)")

        return Color(255, 255, 255)
    end

    -- Convert Vector to Color if necessary
    if istable(col1) and not IsColor(col1) then
        col1 = Color(col1.x, col1.y, col1.z)
    end
    if istable(col2) and not IsColor(col2) then
        col2 = Color(col2.x, col2.y, col2.z)
    end

    -- Clamp t between 0 and 1
    t = math.Clamp(t, 0, 1)

    -- Lerping the color components
    local lerpedColor = Color(
        Lerp(t, col1.r, col2.r),
        Lerp(t, col1.g, col2.g),
        Lerp(t, col1.b, col2.b),
        Lerp(t, col1.a, col2.a)
    )

    return lerpedColor
end

function draw.SimpleLinearGradient(x, y, w, h, startColor, endColor, horizontal)
    draw.LinearGradient(x, y, w, h, { {offset = 0, color = startColor}, {offset = 1, color = endColor} }, horizontal)
end

function draw.LinearGradient(x, y, w, h, stops, horizontal)
    if #stops == 0 then
    return
    elseif #stops == 1 then
        surface.SetDrawColor(stops[1].color)
        surface.DrawRect(x, y, w, h)
        return
    end

    table.SortByMember(stops, "offset", true)

    render.SetMaterial(mat_white)
    mesh.Begin(MATERIAL_QUADS, #stops - 1)
    for i = 1, #stops - 1 do
        local offset1 = math.Clamp(stops[i].offset, 0, 1)
        local offset2 = math.Clamp(stops[i + 1].offset, 0, 1)
        if offset1 == offset2 then continue end

        local deltaX1, deltaY1, deltaX2, deltaY2

        local color1 = stops[i].color
        local color2 = stops[i + 1].color

        local r1, g1, b1, a1 = color1.r, color1.g, color1.b, color1.a
        local r2, g2, b2, a2
        local r3, g3, b3, a3 = color2.r, color2.g, color2.b, color2.a
        local r4, g4, b4, a4

        if horizontal then
            r2, g2, b2, a2 = r3, g3, b3, a3
            r4, g4, b4, a4 = r1, g1, b1, a1
            deltaX1 = offset1 * w
            deltaY1 = 0
            deltaX2 = offset2 * w
            deltaY2 = h
        else
            r2, g2, b2, a2 = r1, g1, b1, a1
            r4, g4, b4, a4 = r3, g3, b3, a3
            deltaX1 = 0
            deltaY1 = offset1 * h
            deltaX2 = w
            deltaY2 = offset2 * h
        end

        mesh.Color(r1, g1, b1, a1)
        mesh.Position(Vector(x + deltaX1, y + deltaY1))
        mesh.AdvanceVertex()

        mesh.Color(r2, g2, b2, a2)
        mesh.Position(Vector(x + deltaX2, y + deltaY1))
        mesh.AdvanceVertex()

        mesh.Color(r3, g3, b3, a3)
        mesh.Position(Vector(x + deltaX2, y + deltaY2))
        mesh.AdvanceVertex()

        mesh.Color(r4, g4, b4, a4)
        mesh.Position(Vector(x + deltaX1, y + deltaY2))
        mesh.AdvanceVertex()
    end
    mesh.End()
end

local blur = Material("pp/blurscreen")

function draw.Blur(amount, panel, x, y, w, h, alpha)
    surface.SetMaterial(blur)

    local scrW, scrH = ScrW(), ScrH()

    -- local wasEnabled = DisableClipping(true)

    -- local x, y = panel:ScreenToLocal(0, 0)

    for i = (1 / amount), 1, (1 / amount) do
        blur:SetInt("$blur", 10 * i)
        render.UpdateScreenEffectTexture()
        surface.SetDrawColor(0, 0, 0, alpha or 255)
        surface.DrawPoly({
            {
                ['x'] = x,
                ['y'] = y,
                ['u'] = x / scrW,
                ['v'] = y / scrH
            },
            {
                ['x'] = w,
                ['y'] = y,
                ['u'] = w / scrW,
                ['v'] = x / scrH
            },
            {
                ['x'] = w,
                ['y'] = h,
                ['u'] = w / scrW,
                ['v'] = h / scrH
            },
            {
                ['x'] = x,
                ['y'] = h,
                ['u'] = x / scrW,
                ['v'] = h / scrH
            }
        })
    end

    -- DisableClipping(wasEnabled)
end