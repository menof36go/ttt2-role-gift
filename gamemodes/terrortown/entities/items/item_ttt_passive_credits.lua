if SERVER then
    util.AddNetworkString("TTT2PCreditNext")
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/icon_passivecredits.vmt")
end

CreateConVar("ttt2_pcredits_per_intervall", 1, { FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The amount of credits received per intervall")

local max = math.max
local round = math.Round

ITEM.PrintName = "item_credits_passive_name"
ITEM.hud = Material("vgui/ttt/equip/credits_default.vmt")
ITEM.EquipMenuData = {
	type = "item_passive",
	name = "Passive Credits",
	desc = "Regularly receive free credits."
}
ITEM.material = "vgui/ttt/icon_passivecredits.vmt"
ITEM.CanBuy = { ROLE_TRAITOR }
ITEM.credits = 2
ITEM.notBuyable = true

if CLIENT then
    ---
    -- Draws a counter next to the item icon
    -- @hook
    -- @internal
    -- @realm client
    function ITEM:DrawInfo()
        if not IsValid(self.Owner) or not self.Owner:IsPlayer() then return end

        local next = GetGlobalFloat("ttt2_pcredits_next_" .. self.Owner:UserID())

        if not next then return end

        return tostring(round(max(0, next - CurTime())))
    end
end

---
-- Called just before entity is deleted. This is used to reset data you set before
-- @param Player ply
-- @hook
-- @realm shared
function ITEM:Reset(ply)
    timer.Remove("passive_credits_timer_" .. ply:UserID())
end

local function UpdateNext(ply, initCreditsPerIntervall, initIntervallLength)
    if not IsValid(ply) then
        timer.Remove("passive_credits_timer_" .. ply:UserID())
        return
    end

    ply:AddCredits(initCreditsPerIntervall)

    SetGlobalFloat("ttt2_pcredits_next_" .. ply:UserID(), CurTime() + initIntervallLength)
end

---
-- A player or NPC has picked the @{ITEM} up
-- @param Player ply
-- @hook
-- @realm shared
function ITEM:Equip(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    self.Owner = ply

    if SERVER then
        local initCreditsPerIntervall = GetConVar("ttt2_pcredits_per_intervall") and GetConVar("ttt2_pcredits_per_intervall"):GetInt()
        local initIntervallLength = GetConVar("ttt2_pcredits_intervall_length") and GetConVar("ttt2_pcredits_intervall_length"):GetFloat()

        SetGlobalFloat("ttt2_pcredits_next_" .. ply:UserID(), CurTime() + initIntervallLength)

        timer.Create("passive_credits_timer_" .. ply:UserID(), initIntervallLength, 0, function()
            UpdateNext(ply, initCreditsPerIntervall, initIntervallLength)
        end)
    end
end

---
-- A player or NPC has bought the @{ITEM}
-- @param Player ply
-- @hook
-- @realm shared
function ITEM:Bought(ply)

end
