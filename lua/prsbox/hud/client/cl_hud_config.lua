PRSBOX_HUD_ACTIVE = CreateClientConVar("prsbox_hud_active", "1", FCVAR_ARCHIVE)
PRSBOX_HUD_ALPHA = CreateClientConVar("prsbox_hud_alpha", "255", FCVAR_ARCHIVE)

PRSBOX_HUD_RES_W = ScrW()
PRSBOX_HUD_RES_H = ScrH()

PRSBOX_HUD_COLOR_R = CreateClientConVar("prsbox_hud_color_r", "255", FCVAR_ARCHIVE)
PRSBOX_HUD_COLOR_G = CreateClientConVar("prsbox_hud_color_g", "255", FCVAR_ARCHIVE)
PRSBOX_HUD_COLOR_B = CreateClientConVar("prsbox_hud_color_b", "0", FCVAR_ARCHIVE)

PRSBOX_HUD_ELEMENTS_COMPASS_ACTIVE = CreateClientConVar("prsbox_hud_elements_compass_active", "1", FCVAR_ARCHIVE)
PRSBOX_HUD_ELEMENTS_CROSSHAIR_ACTIVE = CreateClientConVar("prsbox_hud_elements_crosshair_active", "1", FCVAR_ARCHIVE)
PRSBOX_HUD_ELEMENTS_DAMAGENOTIFY_ACTIVE = CreateClientConVar("prsbox_hud_elements_damagenotify_active", "1", FCVAR_ARCHIVE)

surface.CreateFont( "PRSBOX_HUD_FONT_HEALTH", {
	font = "HudDefault",
	extended = true,
	size = PRSBOX_HUD_RES_H*0.04,
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