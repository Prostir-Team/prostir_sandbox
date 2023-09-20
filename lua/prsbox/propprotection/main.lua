------------------------------------
--	Simple Prop Protection
--	By Spacetech, Maintained by Donkie
-- 	https://github.com/Donkie/SimplePropProtection
------------------------------------

AddCSLuaFile("prsbox/propprotection/cl_protect.lua")
AddCSLuaFile("prsbox/propprotection/sh_cppi.lua")

SPropProtection = {}
SPropProtection.Version = 1.7

CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFER = 16

include("prsbox/propprotection/sh_cppi.lua")

if SERVER then
	include("prsbox/propprotection/sv_protect.lua")
else
	include("prsbox/propprotection/cl_protect.lua")
end

Msg("==========================================================\n")
Msg("Simple Prop Protection Version " .. SPropProtection.Version .. " by Spacetech has loaded\n")
Msg("==========================================================\n")