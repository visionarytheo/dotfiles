-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- CUSTOM HYPRLAND LUA CONFIG                             --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

HOME = os.getenv("HOME")
CONFIG_DIR = HOME .. "/.config/hypr"

-- Ensure Lua finds modules in ~/.config/hypr regardless of working directory
package.path = CONFIG_DIR .. "/?.lua;" .. package.path

------------------
---- MODULES -----
------------------

require("monitors")
require("programs")
require("autostart")
require("env_variables")
require("looknfeel")
require("layouts")
require("inputs")
require("keybindings")
require("windows")

-------------------------------------
---- DYNAMIC THEME COLOR INJECTION --
-------------------------------------

-- Safely require colors.lua from ~/.config/hypr/current_theme
package.path = CONFIG_DIR .. "/current_theme/?.lua;" .. package.path
pcall(require, "colors")
