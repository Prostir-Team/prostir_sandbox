do
    function ulx.build(calling_ply)
        if not IsValid(calling_ply) then return end
        if not calling_ply:IsPlayer() then return end
        if calling_ply:BuildMode() then return end

        ulx.fancyLogAdmin( calling_ply, "#A has enabled the build mode!")

        hook.Run("PRSBOX.EnterBuildMode", calling_ply)
    end

    local build = ulx.command("Sandbox", "ulx build", ulx.build, "!build")
    build:defaultAccess(ULib.ACCESS_ALL)
    build:help("Команда, яка активує режим будівельника.")
end

do
    function ulx.pvp(calling_ply)
        if not IsValid(calling_ply) then return end
        if not calling_ply:IsPlayer() then return end
        if not calling_ply:BuildMode() then return end

        ulx.fancyLogAdmin( calling_ply, "#A has enabled the pvp mode!")

        hook.Run("PRSBOX.EnterPvpMode", calling_ply)
    end

    local pvp = ulx.command("Sandbox", "ulx pvp", ulx.pvp, "!pvp")
    pvp:defaultAccess(ULib.ACCESS_ALL)
    pvp:help("Команда, яка деактивує режим будівельника.")
end 