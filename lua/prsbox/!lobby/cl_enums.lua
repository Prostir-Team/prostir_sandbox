---
---  Fonts
---

surface.CreateFont("PRSBOX.Lobby.Font.Big", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(20),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PRSBOX.Lobby.Font.Button", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(15),
    ["extended"] = true,
    ["weight"] = 700
})

surface.CreateFont("PRSBOX.Lobby.Font.Info", {
    ["font"] = "Roboto",
    ["size"] = ScreenScale(10),
    ["extended"] = true,
    ["weight"] = 700
})

---
--- Colors
---

COLOR_WHITE = Color(255, 255, 255)
COLOR_BLACK = Color(0, 0, 0)
COLOR_RED = Color(255, 0, 0)
COLOR_GREEN = Color(0, 255, 0)
COLOR_BUTTON_NONE = Color(0, 0, 0, 0)
COLOR_BUTTON_WHITE_NONE = Color(255, 255, 255, 0)
COLOR_BUTTON_BACKGROUND = Color(0, 0, 0, 200)
COLOR_BUTTON_TEXT = Color(142, 255, 114)
COLOR_BUTTON_TEXT_LOCKED = Color(255, 75, 75)


---
--- Button states
---

BUTTON_OPENED = 1
BUTTON_CLOSED = 2

---
--- Player states
---

PLAYER_NONE = 0
PLAYER_PAUSE = 1
PLAYER_LOBBY = 2

---
--- Checkbox state
---

CHECKBOX_GOOD = COLOR_BUTTON_TEXT
CHECKBOX_BAD = COLOR_BUTTON_TEXT_LOCKED