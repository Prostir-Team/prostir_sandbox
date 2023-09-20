function ulx.rtv(calling_ply)

end

local rtv = ulx.command("Sandbox", "ulx rtv", ulx.rtv, "!rtv")
rtv:defaultAccess(ULib.ACCESS_ALL)
rtv::help("Голосування")