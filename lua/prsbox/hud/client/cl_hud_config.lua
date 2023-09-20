PRSBOX_HUD_ACTIVE = CreateClientConVar("prsbox_hud_active", "1", true, false, "Вмикає/Вимикає HUD", 0, 1)
PRSBOX_HUD_ANIMATION_ACTIVE = CreateClientConVar("prsbox_hud_animation_active", "1", true, false, "Вмикає/Вимикає HUD", 0, 1)
PRSBOX_HUD_ALPHA = CreateClientConVar("prsbox_hud_alpha", "255", true, false, "Контролює прозорість HUD'а", 0, 255)

PRSBOX_HUD_RES_W = ScrW()
PRSBOX_HUD_RES_H = ScrH()

PRSBOX_HUD_COLOR_R = CreateClientConVar("prsbox_hud_color_r", "255", true, false, "Міняє червону компоненту кольору HUD'а", 0, 255)
PRSBOX_HUD_COLOR_G = CreateClientConVar("prsbox_hud_color_g", "255", true, false, "Міняє зелену компоненту кольору HUD'а", 0, 255)
PRSBOX_HUD_COLOR_B = CreateClientConVar("prsbox_hud_color_b", "0", true, false, "Міняє синю компоненту кольору HUD'а", 0, 255)

PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE = CreateClientConVar("prsbox_hud_elements_compass_active", "1", true, false, "Вмикає/Вимикає компасс", 0, 1)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_ACTIVE = CreateClientConVar("prsbox_hud_elements_crosshair_active", "1", true, false, "Вмикає/Вимикає користувацький приціл", 0, 1)
PRSBOX_HUD_ELEMENTS_DAMAGENOTIFY_ACTIVE = CreateClientConVar("prsbox_hud_elements_damagenotify_active", "1", true, false, "Вмикає/Вимикає оповіщення про джерело шкоди", 0, 1)

PRSBOX_HUD_ELEMENTS_CROSSHAIR_IsDynamic = CreateClientConVar("prsbox_hud_elements_crosshair_isDynamic", "1", true, false, "Вмикає/Вимикає розкид прицілу", 0, 1)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_DynamicSpread = CreateClientConVar("prsbox_hud_elements_crosshair_dynamicSpread", "0.5", true, false, "Контролює розкид прицілу", 0, nil)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_R = CreateClientConVar("prsbox_hud_elements_crosshair_color_r", "255", true, false, "Міняє червону компоненту кольору прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_G = CreateClientConVar("prsbox_hud_elements_crosshair_color_g", "255", true, false, "Міняє зелену компоненту кольору прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_COLOR_B = CreateClientConVar("prsbox_hud_elements_crosshair_color_b", "255", true, false, "Міняє синю компоненту кольору прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_Thickness = CreateClientConVar("prsbox_hud_elements_crosshair_thickness", "1", true, false, "Міняє жирність ліній прицілу", 0, nil)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_IsOutline = CreateClientConVar("prsbox_hud_elements_crosshair_outline", "1", true, false, "Вмикає/Вимикає обмальовку ліній прицілу", 0, 1)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_R = CreateClientConVar("prsbox_hud_elements_crosshair_outline_color_r", "0", true, false, "Міняє червону компоненту кольору обмальовки прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_G = CreateClientConVar("prsbox_hud_elements_crosshair_outline_color_g", "0", true, false, "Міняє червону компоненту кольору обмальовки прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_OUTLINE_COLOR_B = CreateClientConVar("prsbox_hud_elements_crosshair_outline_color_b", "0", true, false, "Міняє червону компоненту кольору обмальовки прицілу", 0, 255)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_Length = CreateClientConVar("prsbox_hud_elements_crosshair_length", "1", true, false, "Міняє довжину ліній прицілу", 0, nil)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_LineGap = CreateClientConVar("prsbox_hud_elements_crosshair_lineGap", "1", true, false, "Міняє відстань ліній прицілу від центру", 0, nil)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_IsDot = CreateClientConVar("prsbox_hud_elements_crosshair_isDot", "1", true, false, "Вмикає/Вимикає крапку по центру", 0, nil)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_Alpha = CreateClientConVar("prsbox_hud_elements_crosshair_alpha", "255", true, false, "Міняє прозорість прицілу", 0, 255)


surface.CreateFont( "PRSBOX_HUD_FONT_DEFAULT", {
	font = "HudDefault",
	extended = true,
	size = PRSBOX_HUD_RES_H*0.05,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "PRSBOX_HUD_FONT_AMMO", {
	font = "HudDefault",
	extended = true,
	size = PRSBOX_HUD_RES_H*0.035,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

cvars.AddChangeCallback( "prsbox_hud_color_r", PRSBOX_HUD_UpdateColor )
cvars.AddChangeCallback( "prsbox_hud_color_g", PRSBOX_HUD_UpdateColor )
cvars.AddChangeCallback( "prsbox_hud_color_b", PRSBOX_HUD_UpdateColor )
cvars.AddChangeCallback( "prsbox_hud_alpha", PRSBOX_HUD_UpdateColor )

hook.Add( "OnScreenSizeChanged", "Prsbox_Hud_OnScreenSizeChanged", function( oldWidth, oldHeight )
	PRSBOX_HUD_RES_W = ScrW()
	PRSBOX_HUD_RES_H = ScrH()
end )

