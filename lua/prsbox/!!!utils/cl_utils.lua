function LerpColor(t, col1, col2)
    if not istable(col1) or not istable(col2) or not isnumber(t) then
        print("Invalid parameters. Expected (number, Color/Vector, Color/Vector, number)")
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
