if SERVER then
    AddCSLuaFile("scripts/sh_convarutil.lua")
	AddCSLuaFile()
end

include("scripts/sh_convarutil.lua")

-- Must run before hook.Add
local cg = ConvarGroup("PCredits", "Passive Credits")
Convar(cg, true, "ttt2_pcredits_per_intervall", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of credits received per intervall", "int", 1, 100)
Convar(cg, true, "ttt2_pcredits_intervall_length", 120, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Length of the intervall", "float", 1, 600, 1)
--
