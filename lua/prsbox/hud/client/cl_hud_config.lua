PRSBOX_HUD_ACTIVE = CreateClientConVar("prsbox_hud_active", "1", true, false, "Вмикає/Вимикає HUD", 0, 1)
PRSBOX_HUD_ANIMATION_ACTIVE = CreateClientConVar("prsbox_hud_animation_active", "1", true, false, "Вмикає/Вимикає HUD", 0, 1)
PRSBOX_HUD_ALPHA = CreateClientConVar("prsbox_hud_alpha", "255", true, false, "Контролює прозорість HUD'а", 0, 255)

PRSBOX_HUD_RES_W = ScrW()
PRSBOX_HUD_RES_H = ScrH()

PRSBOX_HUD_COLOR_R = CreateClientConVar("prsbox_hud_color_r", "255", true, false, "Міняє червону компоненту кольору HUD'а", 0, 255)
PRSBOX_HUD_COLOR_G = CreateClientConVar("prsbox_hud_color_g", "255", true, false, "Міняє зелену компоненту кольору HUD'а", 0, 255)
PRSBOX_HUD_COLOR_B = CreateClientConVar("prsbox_hud_color_b", "0", true, false, "Міняє синю компоненту кольору HUD'а", 0, 255)

PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE = CreateClientConVar("prsbox_hud_elements_compass_active", "1", true, false, "Вмикає/Вимикає компасс", 0, 1)
PRSBOX_HUD_ELEMENTS_DAMAGENOTIFY_ACTIVE = CreateClientConVar("prsbox_hud_elements_damagenotify_active", "1", true, false, "Вмикає/Вимикає оповіщення про джерело шкоди", 0, 1)

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

