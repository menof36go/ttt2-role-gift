AddCSLuaFile()

resource.AddFile("vgui/ttt/icon_xmas_present.vmt")
resource.AddFile("vgui/ttt/icon_xmas_present.vtf")

SWEP.HoldType = "normal"

if CLIENT then
   SWEP.PrintName = LANG.TryTranslation("gifter_gift")
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Contains a gift for a special someone.\nBe careful who you give it to!"
   };

   SWEP.Icon = "vgui/ttt/icon_xmas_present"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/props/cs_office/microwave.mdl"

SWEP.DrawCrosshair = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = { ROLE_GIFTER }
SWEP.LimitedStock = false
SWEP.notBuyable = false
SWEP.AllowDrop = true
SWEP.NoSights = true

if SERVER then
	function SWEP:PrimaryAttack()
		if not self:CanPrimaryAttack() then return end

		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self.Weapon:EmitSound("Weapon_Crowbar.Single")
		self:TakePrimaryAmmo(1)
		self.Owner:ViewPunch(Angle( -1, 0, 0 ))
		self:CreateGift()
	end

	function SWEP:CreateGift()
		if not IsValid(self.Owner) or not self.UserID or not self.EquipClass then
			ErrorNoHalt(self.Owner, "tried to create a gift with missing params", self.UserID, self.EquipClass)
			self:Remove()
			return
		end

		local ply = self.Owner
		local gift = ents.Create("ttt_gift_gift")
		gift:SetUID(self.UserID)
		gift:SetContent(self.EquipClass)
		gift.EquipClass = self.EquipClass

		if IsValid(gift) and IsValid(ply) then
			spos = ply:GetShootPos()
			velo = ply:GetVelocity()
			aim = ply:GetAimVector()
			throw = velo + aim * 100
			gift:SetPos(spos + aim * 10)
			gift:Spawn()
			gift:PhysWake()
			phys = gift:GetPhysicsObject()

			if IsValid(phys) then
				phys:SetVelocity(throw)
			end
		end
		self:Remove()
	end

	function SWEP:PreDrop()
		self.Owner:ViewPunch(Angle( -1, 0, 0 ))
		self:CreateGift()
	end
else
	function SWEP:PrimaryAttack()
		if not self:CanPrimaryAttack() then return end

		self.Weapon:EmitSound("Weapon_Crowbar.Single")
	end
end

function SWEP:DrawWorldModel()
	return false
end
