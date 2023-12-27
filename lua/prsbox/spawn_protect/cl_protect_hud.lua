// This is Advanced Spawn Protection for Prostir 2.0 (idi nahuy)
// Which means that icons are replaced with the default one, and no halo around players to keep this code 'optimized' as Isemenuk requested
// My first commit here btw


local alpha = 255
CreateConVar(   "advsp_draw_overlay", "0", { FCVAR_ARCHIVE }, "Enables small overlay over your screen when protection is on")
// CreateConVar(   "advsp_draw_halo", "1", { FCVAR_ARCHIVE }, "Draws green outline")
// CreateConVar(   "advsp_draw_custom_icons", "0", { FCVAR_ARCHIVE }, "Uses more 'modern' variant for icons instead of the 'icon16' icons")

concommand.Add( "advsp_version", function( ply )
    print("Version - Prostir 1.4 ")
end)


hook.Add("PostDrawTranslucentRenderables", "ADVSP.ShittyAssIcon", function()

    for _, ply in pairs(player.GetAll()) do
        if ply:IsValid() and ply:Alive() and ply:IsPlayer() and ply:GetNWBool("SpawnProtected") then

            cam.Start3D2D(ply:GetPos() + Vector(0, 0, 45) + Angle( 0, CurTime() * 155,0):Forward() * 15 ,Angle( 0, EyeAngles().y - 90,90), 0.1)
                    
            local IMaterial = "icon16/bullet_error.png"

                IMaterial = "icon16/shield.png"
            
                surface.SetMaterial( Material(IMaterial)  )
                surface.SetDrawColor(255, 255, 255, 100)
                local IconSize = 120
                surface.DrawTexturedRect(-IconSize / 2, -IconSize / 2, IconSize, IconSize)
            cam.End3D2D()
        end
    end
end)


hook.Add("HUDPaint", "ADVSP.CreateSigmaHud", function()
    local ply = LocalPlayer()

    local endTime = ply:GetNWFloat("SpawnProtectionEndTime", 0)
    local remainingTime = math.max(0, endTime - CurTime())

    if remainingTime <= 0 then
        alpha = math.Clamp( alpha - 3, 0,255 )
    else
        alpha = math.Clamp( alpha + 6, 0,255 )
    end

    if not ply:Alive() then
        alpha = 0
    end
        
    if alpha > 1 then
        
        local Xbox = ScrW() / 2
        local Ybox =  ScrH() / 1.05 / 1.05

        local StringText = "∞"

        if remainingTime <= 9999 then
            StringText = string.sub( tostring( remainingTime + 0.001 ), 1,4  )
        end

        if GetConVar("advsp_draw_overlay"):GetBool() then
            surface.SetMaterial( Material("vgui/gradient-d") )
            surface.SetDrawColor(100, 255, 100, alpha / 35)
            surface.DrawTexturedRect(0, ScrH()/1.075, ScrW() , ScrH()/14.5)

            surface.SetMaterial( Material("vgui/gradient-u") )
            surface.SetDrawColor(100, 255, 100, alpha / 35)
            surface.DrawTexturedRect(0, 0, ScrW() , ScrH()/14.5)
        end

        local lenStr = string.len( StringText ) * 5.4
        draw.RoundedBox( 5, Xbox - lenStr - 7, Ybox+2, lenStr * 2.7 , 25, Color( 25, 25, 25, alpha - 100) )
        
        local IMaterial = "icon16/bullet_error.png"

        IMaterial = "icon16/shield.png"
        
        surface.SetDrawColor(100, 255, 100, alpha / 2) // Color for dec
        surface.DrawOutlinedRect(Xbox - lenStr - 7, Ybox+2, lenStr * 2.75 , 25, 2) // Dec
        surface.SetDrawColor(255, 255, 255, alpha) // Color for icon
        surface.SetMaterial( Material(IMaterial) ) // Mat
        local IconSize = 15 + math.sin( CurTime() * 2 ) * 2 // Icon sizee
        surface.DrawTexturedRect(Xbox - IconSize, Ybox - 35, IconSize*2 , IconSize*2) // Icon
        draw.SimpleText(StringText, "Trebuchet24", Xbox, Ybox, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
        
    end
end)


// hook.Add( "PreDrawHalos", "ADVSP.Protecthalo", function()

//     if GetConVar("advsp_enabled"):GetBool() then // and GetConVar("advsp_enabled"):GetBool() 
// 	    local staff = {}
    
// 	    for _, ply in ipairs( player.GetAll() ) do
// 		    if ply:GetPos():Distance( LocalPlayer():GetPos() ) < 1000 and ply:GetNWBool("SpawnProtected", true) and GetConVar("advsp_draw_halo"):GetBool() then
// 			    staff[ #staff + 1 ] = ply
// 		    end
// 	    end

// 	    halo.Add( staff, Color(100,255,100), 0, 0, 1, true, false )
//     end
// end )