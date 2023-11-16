SETTINGS = SETTINGS or {}

local category_name = "Хітмаркери"

SETTINGS:AddSetting("Увімкнуто", category_name, "prsbox_hitmarkers", SETTINGS_BOOL)
SETTINGS:AddSetting("Ближня точка", category_name, "prsbox_hitmarkers_closepoint", SETTINGS_INT)
SETTINGS:AddSetting("Дальня точка", category_name, "prsbox_hitmarkers_farpoint", SETTINGS_INT)
SETTINGS:AddSetting("Масштаб", category_name, "prsbox_hitmarkers_scale", SETTINGS_INT)
SETTINGS:AddSetting("Товщина елемента", category_name, "prsbox_hitmarkers_thickness", SETTINGS_INT)
