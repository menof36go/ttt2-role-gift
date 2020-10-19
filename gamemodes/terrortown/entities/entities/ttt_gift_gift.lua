AddCSLuaFile()

if SERVER then
    print("If this is still here after upload remind the addon creator that he is an idiot who forgot to add the resource.AddWorkshop back in :)!")
end

resource.AddFile("models/props/xmas_present/c_xmas_present.mdl")
resource.AddFile("materials/models/props/xmas_present/c_xmas_blue.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_blue.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_green.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_green.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_yellow.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_yellow.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_red.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_red.vtf")

ENT.Type = "anim"
ENT.NextUse = 0
ENT.Counter = 0

function ENT:Initialize()
	self:SetModel("models/props/xmas_present/c_xmas_present.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSkin(math.random(0,3))

  	local phys = self:GetPhysicsObject()
    if IsValid(phys) then
       	phys:SetMass(50)
    end

	var = self
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "UID")
	self:NetworkVar("String", 0, "Content")
end

local lastCall = -1

function ENT:Use(activator)
	if not IsValid(activator) or not activator:IsPlayer() then return end

	if CurTime() < lastCall + 1 then
		lastCall = CurTime()
		return
	else
		lastCall = CurTime()
	end

	if activator:UserID() == self:GetUID() then
		activator:GiveEquipmentWeapon("weapon_gift_gift", function(ply, cls, wep)
			wep.UserID = self:GetUID()
			wep.EquipClass = self.EquipClass
		end)
	else
		local isItem = items.IsItem(self.EquipClass)

		if isItem and activator:HasBought(self.EquipClass) then
			self:EmitSound("buttons/button9.wav",75, 150)
			return
		end

		local effect = EffectData()
		effect:SetOrigin(self:GetPos() + Vector(0,0, 10))
		effect:SetStart(self:GetPos() + Vector(0,0, 10))
		util.Effect("cball_explode", effect, true, true)

		if isItem then
			local item = activator:GiveEquipmentItem(self.EquipClass)
			if isfunction(item.Bought) then
				item:Bought(ply)
			end
		else
			activator:GiveEquipmentWeapon(self.EquipClass, function(ply, cls, wep)
				wep.Gifter = self:GetUID()
				if isfunction(wep.WasBought) then
					wep:WasBought(ply)
				end
			end)
		end
	end

	self:Remove()
end

if CLIENT then
	local TryT
	local GetP

	-- target ID function
	hook.Add("TTTRenderEntityInfo", "TTT2GifterEntityInfo", function(tData)
		local e = tData:GetEntity()
		if not e or not IsValid(e) or e:GetClass() ~= "ttt_gift_gift" then return end

		if not e.ProperContentName then
			local cls = e:GetContent()
			e.ProperContentName = cls
			local eqtbl = nil

			if cls then
				if items.IsItem(cls) then
					eqtbl = items.GetStored(cls)
				else
					eqtbl = weapons.GetStored(cls)
				end

				if eqtbl then
					e.ProperContentName = GetEquipmentTranslation(eqtbl.ClassName, eqtbl.PrintName)
				end
			end
		end

		local client = LocalPlayer()
		local uid = e:GetUID()
		local owner = uid and Player(uid)
		owner = IsValid(owner) and owner:IsPlayer() and owner

		TryT = TryT or LANG.TryTranslation
		GetP = GetP or LANG.GetPTranslation

		local isOwner = client == owner

		tData:EnableText()
		tData:EnableOutline()
		tData:SetOutlineColor(Color(0, 255, 150, 255))
		tData:SetTitle(TryT("gifter_gift"))
		tData:SetSubtitle(owner and owner:Nick())
		tData:SetKeyBinding("+use")

		if isOwner then
			tData:AddDescriptionLine(GetP("gifter_own_gift", {content = e.ProperContentName}))
		else
			tData:AddDescriptionLine(TryT("gifter_desc_gift"))
		end
	end)
end
