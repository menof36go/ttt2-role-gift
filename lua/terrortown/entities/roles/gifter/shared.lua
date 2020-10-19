if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_gift.vmt")
end

function ROLE:PreInitialize()
    self.color = Color(0, 255, 150, 255)

	self.abbr = "gift" -- abbreviation
	self.radarColor = Color(150, 150, 150) -- color if someone is using the radar
	self.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
	self.unknownTeam = true -- player don't know their teammates

	self.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment

	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		credits = 1, -- the starting credits of a specific role
		random = 33, -- only spawn the gifter in one out of 3 rounds
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		shopFallback = SHOP_FALLBACK_TRAITOR
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)

	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("English", self.name, "Gifter")
		LANG.AddToLanguage("English", "info_popup_" .. self.name,
			[[You are a Gifter!
				Buy gifts for your loved ones, but be careful who you choose!]])
		LANG.AddToLanguage("English", "body_found_" .. self.abbr, "This was a Gifter...")
		LANG.AddToLanguage("English", "search_role_" .. self.abbr, "This person was a Gifter!")
		LANG.AddToLanguage("English", "target_" .. self.name, "Gifter")
		LANG.AddToLanguage("English", "ttt2_desc_" .. self.name, [[The Gifter can access his own ([C]) shop and buy gifts for other people. Make sure the receivers are innocent!]])
		LANG.AddToLanguage("English", self.name .. "_gift", "Gift")
		LANG.AddToLanguage("English", self.name .. "_own_gift", "A gift you dropped for a special someone. It contains \"{content}\", but don't spoil the suprise!")
		LANG.AddToLanguage("English", self.name .. "_desc_gift", "A gift! What could be inside? Maybe you should take a peak and find out.")

		LANG.AddToLanguage("Deutsch", self.name, "Verschenker")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. self.name,
			[[Du bist ein Verschenker!
				Beschenke dein Team, aber pass auf, dass du nicht ausversehen die Bösen beschenkst!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. self.abbr, "Er war ein Verschenker...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. self.abbr, "Diese Person war ein Verschenker!")
		LANG.AddToLanguage("Deutsch", "target_" .. self.name, "Verschenker")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. self.name, [[Der Verschenker hat seinen eigenen ([C]) Shop und kann Freunde beschenken. Stell sicher, dass diese Freunde unschuldig sind!]])
		LANG.AddToLanguage("Deutsch", self.name .. "_gift", "Geschenk")
		LANG.AddToLanguage("Deutsch", self.name .. "_own_gift", "Eins deiner Geschenke. Es beinhaltet \"{content}\", aber verdirb nicht die Überraschung!")
		LANG.AddToLanguage("Deutsch", self.name .. "_desc_gift", "Ein Geschenk! Du solltest es schnell öffnen, um herauszufinden was drin ist.")
		
		LANG.AddToLanguage("Русский", self.name, "Даритель")
		LANG.AddToLanguage("Русский", "info_popup_" .. self.name,
			[[Вы даритель!
				Покупайте подарки для своих близких, но будьте осторожны при выборе!]])
		LANG.AddToLanguage("Русский", "body_found_" .. self.abbr, "Это был даритель...")
		LANG.AddToLanguage("Русский", "search_role_" .. self.abbr, "Этот человек был дарителем!")
		LANG.AddToLanguage("Русский", "target_" .. self.name, "Даритель")
		LANG.AddToLanguage("Русский", "ttt2_desc_" .. self.name, [[Даритель может получить доступ к своему ([C]) магазину и покупать подарки для других людей. Убедитесь, что получатели невиновны!]])
		LANG.AddToLanguage("Русский", self.name .. "_gift", "Подарок")
		LANG.AddToLanguage("Русский", self.name .. "_own_gift", "Подарок, который вы сделали для кого-то особенного. Он содержит \"{content}\", но не испортите сюрприз!")
		LANG.AddToLanguage("Русский", self.name .. "_desc_gift", "Подарок! Что могло быть внутри? Может, тебе стоит взглянуть на это и узнать.")
	end
end

if SERVER then
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentItem("item_ttt_passive_credits")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:RemoveEquipmentItem("item_ttt_passive_credits")
	end

	hook.Add("TTT2CanOrderEquipment", "TTT2GifterOrder", function(ply, cls, isItem, credits)
		if not IsValid(ply) or ply:GetSubRole() ~= ROLE_GIFTER then return end

		ply:GiveEquipmentWeapon("weapon_gift_gift", function(ply, giftcls, wep)
			wep.UserID = ply:UserID()
			wep.EquipClass = cls
			ply:SubtractCredits(credits)
		end)

		return false
	end)

	hook.Add("PlayerCanPickupWeapon", "TTT2GifterPreventPickup", function(ply, wep)
		if not IsValid(wep) or not wep.Gifter or not IsValid(ply) then return end

		if wep.Gifter == ply:UserID() then return false end
	end)
end
