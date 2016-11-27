
local Version = 0.1

function AutoUpdate(data)
    if tonumber(data) > tonumber(Version) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalYasuo.lua", SCRIPT_PATH .. "EternalYasuo.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalYasuo.version", AutoUpdate)

class "Winding"

function Winding:__init()
	Winding.Up = false
	Winding.Down = false
	self.LastAttack = 0
	self.AnimationTime = 0
	
	self.AltAttacks = { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3", "viktorqbuff"}
	self.AAResets = { "dariusnoxiantacticsonh", "fiorae", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "itemtitanichydracleave", "gravesmove", "masochism"}
	self.NotAttacks = {"jarvanivcataclysmattack", "monkeykingdoubleattack", "shyvanadoubleattack", "shyvanadoubleattackdragon", "zyragraspingplantattack", "zyragraspingplantattack2", "zyragraspingplantattackfire", "zyragraspingplantattack2fire", "viktorpowertransfer", "gravesautoattackrecoil"}
	
	OnTick(function() self:Tick() end)
	OnAttackCancel(function(unit, result) self:Cancel(unit, result) end)
	OnProcessSpell(function(unit, spell) self:Spell(unit, spell) end)
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)
end

function Winding:Tick()
	if GetTickCount() >= self.LastAttack + (1000*(self.AnimationTime)) then
		Winding.Down = false
	end	
end

function Winding:Cancel(unit, result)
	if unit.isMe and result.flag2 > 0 then
		self:ResetAA()
	end	
end

function Winding:Spell(unit, spell)
	if unit.isMe then
		if self:IsAA(spell.name) then
			Winding.Up = true
			Winding.Down = false
			self.LastAttack = GetTickCount()
			self.AnimationTime = spell.animationTime
		elseif table.contains(self.AAResets, spell.name:lower()) then
			self:ResetAA()
		end	
	end	
end

function Winding:SpellComplete(unit, spell)
	if unit.isMe and self:IsAA(spell.name) then
		Winding.Up = false
		Winding.Down = true
	end
end

function Winding:ResetAA()
	self.LastAttack = 0
	Winding.Up = false
	Winding.Down = false
end

function Winding:IsAA(spell)
	return (spell:lower():find("attack") and not table.contains(self.NotAttacks, spell:lower())) or table.contains(self.AltAttacks, spell:lower())
end

class "MinionManager"

function MinionManager:__init()
	MinionManager.Minions = {
	All = {},
	Enemy = {},
	Ally = {},
	Jungle = {}
	}
	
	OnCreateObj(function(o) self:CreateO(o) end)
	OnObjectLoad(function(o) self:CreateO(o) end)
	OnDeleteObj(function(o) self:DeleteO(o) end)
end

function MinionManager:CreateO(o)
	if o.isMinion and not o.dead and not o.charName:find("Plant") then
		if o.charName:find("Minion") or o.team == MINION_JUNGLE then
			table.insert(MinionManager.Minions.All, o)
			if o.team == MINION_ENEMY then
				table.insert(MinionManager.Minions.Enemy, o)
			elseif o.team == MINION_ALLY then
				table.insert(MinionManager.Minions.Ally, o)
			elseif o.team == MINION_JUNGLE then
				table.insert(MinionManager.Minions.Jungle, o)
			end
		end
	end		
end

function MinionManager:DeleteO(o)
	if o.isMinion then
		for _, i in pairs(MinionManager.Minions.All) do
			if i == o then
				table.remove(MinionManager.Minions.All, _)
			end
		end
		
		if o.team == MINION_ENEMY then
			for _, i in pairs(MinionManager.Minions.Enemy) do
				if i == o then
					table.remove(MinionManager.Minions.Enemy, _)
				end
			end
		elseif o.team == MINION_JUNGLE then
			for _, i in pairs(MinionManager.Minions.Jungle, _) do
				if i == o then
					table.remove(MinionManager.Minions.Jungle, _)
				end
			end
		elseif o.team == MINION_ALLY then
			for _, i in pairs(MinionManager.Minions.Ally) do
				if i == o then
					table.remove(MinionManager.Minions.Ally, _)
				end
			end
		end		
	end	
end

class "SkinChanger"

function SkinChanger:__init()
	self.Skins = {
	["Zed"] = {"Classic", "Shockblade", "SKT T1", "Project", "Shockblade Pink", "Shockblade Yellow", "Shockblade Blue", "Shockblade Red", "Shockblade Purple", "Shockblade Green", "Championship"},
	["Yasuo"] = {"Classic", "High Noon", "PROJECT", "Blood Moon"}
	}
	SkinChangerMenu = Menu("SkinChanger", myHero.charName.." SkinChanger")
	SkinChangerMenu:DropDown("Skin", myHero.charName.." Skins", 1, self.Skins[myHero.charName], HeroSkinChanger, true)
	SkinChangerMenu.Skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(self.Skins[myHero.charName][model].." "..myHero.charName.." Loaded!") end
end

class "Damage"

function Damage:__init()

	DamageMod = {
	["Annie"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "MoltenShield") > 0 and amount * (1 - ({0.16,0.22,0.28,0.34,0.4})[GetCastLevel(unit, _E)]) or amount
	end,
	["Braum"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "BraumShieldRaise") > 0 and amount * (1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[GetCastLevel(unit, _E)]) or amount
	end,
	["Urgot"] = function(unit, amount, damageType) 
		return BuffManager:GetBuff(unit, "urgotswapdef") > 0 and amount * (1 - ({0.3, 0.4, 0.5})[GetCastLevel(unit, _R)]) or amount
	end,	
	["Amumu"] = function(unit, amount, damageType)
		return damageType == 1 and BuffManager:GetBuff(unit, "Tantrum") > 0 and amount - ({2, 4, 6, 8, 10})[GetCastLevel(unit, _E)] or amount
	end,
	["Galio"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "GalioIdolOfDurand") > 0 and amount * 0.5 or amount
	end,
	["Garen"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "GarenW") > 0 and amount * 0.7 or amount
	end,
	["Gragas"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "GragasWSelf") > 0 and amount - amount * ({0.1, 0.12, 0.14, 0.16, 0.18})[GetCastLevel(unit, _W)] or amount
	end,
	["Kassadin"] = function(unit, amount, damageType)
		return damageType == 2 and amount * 0.85 or amount
	end,
	["Maokai"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "MaokaiDrainDefense") > 0 and amount * 0.8 or amount
	end,
	["MasterYi"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "Meditate") > 0 and amount - amount * (1 - ({0.5, 0.55, 0.6, 0.65, 0.7})[GetCastLevel(unit, _W)]) or amount
	end,
	["Malzahar"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "malzaharpassiveshield") > 0 and amount * 0.1 or amount
	end,
	["Alistar"] = function(unit, amount, damageType)
		return BuffManager:GetBuff(unit, "FerociousHowl") > 0 and amount * (1 - ({0.5,0.6,0.7})[GetCastLevel(unit, _R)]) or amount
	end
	}
	
end

function Damage:CalcPhysical(unit, damage)
	if unit == nil or unit.dead then
		return 0
	end
	
	local APF =  GetArmorPenFlat(myHero) * 0.4 + (GetArmorPenFlat(myHero)*0.6)/18 * unit.level
	local APP = GetArmorPenPercent(myHero)
	local BAP = myHero.bonusArmorPenPercent
	local armor = GetArmor(unit)
	local bonusArmor = GetArmor(unit) - GetBaseArmor(unit)
	local value = 100 / (100 + (armor * APP) - (bonusArmor * (1 - BAP)) - APF)

	if armor < 0 then
		value = 2 - 100 / (100 - armor)
	elseif (armor * APP) - (bonusArmor * (1 - BAP)) - APF < 0 then
		value = 1
	end
	
	return math.max(0, math.floor(self:ReductionMod(unit, value * damage, 1)))
end

function Damage:CalcMagical(unit, damage)
	if unit == nil or unit.dead then
		return 0
	end
	
	local MR = GetMagicResist(unit)
	local MPP = GetMagicPenPercent(myHero)
	local MPF = GetMagicPenFlat(myHero)
	local value = 100 / (100 + (MR * MPP) - MPF)

	if MR < 0 then
		value = 2 - 100 / (100 - MR)
	elseif (MR * MPP) - MPF < 0 then
		value = 1
	end
	
	return math.max(0, math.floor(self:ReductionMod(unit, value * damage, 2)))
end

function Damage:ReductionMod(unit, amount, damageType)
	if unit and	unit.isHero then
		if DamageMod[unit.charName] then
			amount = DamageMod[unit.charName](unit, amount, damageType)
		end
		if BuffManager:GetBuff(myHero, "Exhaust") > 0 then
			amount = amount * 0.6
		end
		amount = amount * (1 - (0.06 * BuffManager:GetBuff(unit, "MasteryWardenOfTheDawn")))
	end
	return amount
end

class "BuffManager"

function BuffManager:__init()
	BuffManager.Buffs = {}
	OnUpdateBuff(function(unit, buff) self:UpdateBuff(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:RemoveBuff(unit, buff) end)
	OnLoad(function() self:Load() end)
end

function BuffManager:UpdateBuff(unit, buff)
	if not BuffManager.Buffs[unit.networkID] then
		BuffManager.Buffs[unit.networkID] = {}
	end
	
	if not BuffManager.Buffs[unit.networkID][buff.Name] or BuffManager.Buffs[unit.networkID][buff.Name] ~= buff.Count then
		BuffManager.Buffs[unit.networkID][buff.Name] = buff.Count
	end	
end

function BuffManager:RemoveBuff(unit, buff)
	if BuffManager.Buffs[unit.networkID] and BuffManager.Buffs[unit.networkID][buff.Name] then
		BuffManager.Buffs[unit.networkID][buff.Name] = nil
	end
end

function BuffManager:GetBuff(unit, buff)
	return BuffManager.Buffs[unit.networkID] and BuffManager.Buffs[unit.networkID][buff] or 0
end

function BuffManager:Load()
	for i = 1, 63 do
		for _, e in pairs(GetEnemyHeroes()) do	
			if GetBuffName(e, i) ~= "" and GetBuffCount(e, i) > 0 then
				if not BuffManager.Buffs[e.networkID] then
					BuffManager.Buffs[e.networkID] = {}
				end	
				BuffManager.Buffs[e.networkID][GetBuffName(e, i)] = GetBuffCount(e, i) 
			end
		end

		for _, a in pairs(GetAllyHeroes()) do			
			if GetBuffName(a, i) ~= "" and GetBuffCount(a, i) > 0 then
				if not BuffManager.Buffs[a.networkID] then
					BuffManager.Buffs[a.networkID] = {}
				end	
				BuffManager.Buffs[a.networkID][GetBuffName(a, i)] = GetBuffCount(a, i) 
			end
		end

		for _, m in pairs(MinionManager.Minions.All) do
			if not m.dead then		
				if GetBuffName(m, i) ~= "" and GetBuffCount(m, i) > 0 then
					if not BuffManager.Buffs[m.networkID] then
						BuffManager.Buffs[m.networkID] = {}
					end	
					BuffManager.Buffs[m.networkID][GetBuffName(m, i)] = GetBuffCount(m, i) 
				end
			end
		end	
		
		if not BuffManager.Buffs[myHero.networkID] then
			BuffManager.Buffs[myHero.networkID] = {}
		end
		if GetBuffName(myHero, i) ~= "" and GetBuffCount(myHero, i) > 0 then
			BuffManager.Buffs[myHero.networkID][GetBuffName(myHero, i)] = GetBuffCount(myHero, i) 
		end	
	end
end

class "AutoLevel"

function AutoLevel:__init()

	self.SpellOrder = {
	[2]={_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W},
	[3]={_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E},
	[4]={_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E},
	[5]={_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q},
	[6]={_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W},
	[7]={_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
	}

	ALMenu = Menu("AL", myHero.charName.." Auto Level")
	ALMenu:DropDown("ALC", "Level Options", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
	ALMenu:Boolean("LVL1", "Dont Use Level 1", true)
	
	OnTick(function() self:Tick() end)
	
end

function AutoLevel:Tick()
	if GetLevelPoints(myHero) > 0 and ALMenu.ALC:Value() ~= 1 and ( not ALMenu.LVL1:Value() or myHero.level > 1 ) then
		LevelSpell(self.SpellOrder[ALMenu.ALC:Value()][myHero.level + 1 - GetLevelPoints(myHero)])
	end
end

class "Yasuo"

function Yasuo:__init()

	self.ERange = GetCastRange(myHero, _E)
	self.RRange = GetCastRange(myHero, _R) + myHero.boundingRadius
	self.AARange = GetRange(myHero) + (myHero.boundingRadius * 2)
	self.QStats = {delay = 0.25, range = 525, speed = math.huge, width = 40}
	self.QStats2 = {delay = 0.5, range = 1150, speed = 1500, width = 90}
	self.QStats3 = {range = 375}
	self.Damage = {
	[0] = function(unit)
		local crit = myHero.critChance
		local critDamage = GetItemSlot(myHero, 3031) > 0 and 2.25 or 1.75
		local AD = (crit == 1 and myHero.totalDamage * critDamage or myHero.totalDamage)
		return Damage:CalcPhysical(unit, 20 * GetCastLevel(myHero, _Q) + AD)
	end,
	[2] = function(unit) 
		local EStacks = BuffManager:GetBuff(myHero, "YasuoDashScalar")
		return Damage:CalcMagical(unit, 50 + (20 * GetCastLevel(myHero, _E)) + (myHero.ap * 0.6) * (1 + (0.25 * EStacks)))
	end,
	[3] = function(unit) 
		return Damage:CalcPhysical(unit, 100 + (100 * GetCastLevel(myHero, _R)) + GetBonusDmg(myHero) * 1.5)
	end
	}
	
	self.Turrets = {}
	self.EStuff = nil
	self.KnockedUp = {}
	self.Marked = {}
	
	self.Target = GetCurrentTarget()

	YasuoMenu = Menu("Yasuo", "Eternal Yasuo")
	YasuoMenu:SubMenu("Combo", "Combo")
	YasuoMenu.Combo:Boolean("CQ", "Use Q", true)
	YasuoMenu.Combo:Boolean("CE", "Use E", true)
	YasuoMenu.Combo:Boolean("CR", "Use R", true)
	
	YasuoMenu:SubMenu("Harass", "Harass")
	YasuoMenu.Harass:Boolean("HQ", "Use Q", true)
	YasuoMenu.Harass:Boolean("HE", "Use E", true)
	
	YasuoMenu:SubMenu("GapClose", "GapClose")
	YasuoMenu.GapClose:Boolean("GCC", "GapClose in Combo", true)
	YasuoMenu.GapClose:Boolean("GCH", "GapClose in Harass", false)
	YasuoMenu.GapClose:Boolean("GCE", "Use E", true)
	
	YasuoMenu:SubMenu("LaneClear", "LaneClear")
	YasuoMenu.LaneClear:Boolean("LCQ", "Use Q", true)
	YasuoMenu.LaneClear:Boolean("LCE", "Use E", true)
	
	YasuoMenu:SubMenu("JungleClear", "JungleClear")
	YasuoMenu.JungleClear:Boolean("JCQ", "Use Q", true)
	YasuoMenu.JungleClear:Boolean("JCE", "Use E", true)
	
	YasuoMenu:SubMenu("LastHit", "LastHit")
	YasuoMenu.LastHit:Boolean("LHQ", "Use Q", true)
	YasuoMenu.LastHit:Boolean("LHE", "Use E", true)
	
	YasuoMenu:SubMenu("Killsteal", "Killsteal")
	YasuoMenu.Killsteal:Boolean("KSQ", "Use Q", true)
	YasuoMenu.Killsteal:Boolean("KSE", "Use E", true)
	YasuoMenu.Killsteal:Boolean("KSR", "Use R", true)
	
	YasuoMenu:SubMenu("Misc", "Misc")
	YasuoMenu.Misc:Boolean("AR", "Auto R", true)
	YasuoMenu.Misc:Slider("ARC", "Min Enemies To Auto R", 3, 1, 6, 1)
	
	YasuoMenu:SubMenu("Draw", "Drawings")
	YasuoMenu.Draw:Boolean("DA", "Disable All Draws", false)
	YasuoMenu.Draw:Boolean("DAA", "Draw AA Range", true)
	YasuoMenu.Draw:Boolean("DQ", "Draw Q Range", true)
	YasuoMenu.Draw:Boolean("DE", "Draw E Range", true)
	YasuoMenu.Draw:Boolean("DR", "Draw R Range", true)
	
	YasuoMenu:SubMenu("Keys", "Keys")
	YasuoMenu.Keys:KeyBinding("CK", "Combo Key", string.byte(" "))
	YasuoMenu.Keys:KeyBinding("HK", "Harass Key", string.byte("C"))
	YasuoMenu.Keys:KeyBinding("LCK", "LaneClear Key", string.byte("V"))
	YasuoMenu.Keys:KeyBinding("LHK", "LastHit Key", string.byte("X"))
	
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpell(function(unit, spell) self:Spell(unit, spell) end)
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)
	OnObjectLoad(function(object) self:OLoad(object) end)
	OnCreateObj(function(object) self:OLoad(object) end)
	OnDeleteObj(function(object) self:DeleteO(object) end)
	OnUpdateBuff(function(unit, buff) self:UBuff(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:RBuff(unit, buff) end)
	OnProcessWaypoint(function(unit, wp) self:ProcessWP(unit, wp) end)
end

function Yasuo:Mode()
	if YasuoMenu.Keys.CK:Value() then
		return "Combo"
	elseif YasuoMenu.Keys.HK:Value() then
		return "Harass"
	elseif YasuoMenu.Keys.LCK:Value() then
		return "LaneClear"
	else
		return YasuoMenu.Keys.LHK:Value() and "LastHit" or ""
	end	
end

function Yasuo:Tick()
	self.Target = GetCurrentTarget()
	
	if self:Mode() == "Combo" then
		self:Combo()
	elseif self:Mode() == "Harass" then
		self:Harass()
	elseif self:Mode() == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif	self:Mode() == "LastHit" then
		self:LastHit()
	end
	
	self:Killsteal()
	
	if YasuoMenu.Misc.AR:Value() and self:Ready(_R) and self:CountAirbourne() >= YasuoMenu.Misc.ARC:Value() then
		CastSpell(_R)
	end
end

function Yasuo:Draw()
	if myHero.dead or YasuoMenu.Draw.DA:Value() then
		return
	end
	
	if YasuoMenu.Draw.DAA:Value() then
		DrawCircle(myHero, self.AARange, 2, 25, GoS.White)
	end
	
	if YasuoMenu.Draw.DE:Value() then
		DrawCircle(myHero, self.ERange, 2, 25, GoS.Cyan)
	end
	
	if YasuoMenu.Draw.DQ:Value() then
		DrawCircle(myHero, self:QRange(), 2, 25, GoS.Cyan)
	end
	
	if YasuoMenu.Draw.DR:Value() then
		DrawCircle(myHero, 1200 + myHero.boundingRadius, 2, 25, GoS.Cyan)
	end
end

function Yasuo:Spell(unit, spell)		
end

function Yasuo:SpellComplete(unit, spell)
end

function Yasuo:OLoad(object)
	if GetObjectType(object) == Obj_AI_Turret and object.team ~= myHero.team then
		table.insert(self.Turrets, object)
	end	
end

function Yasuo:DeleteO(object)
	for _, i in pairs(self.Turrets) do
		if object == i then
			table.remove(self.Turrets, _)
		end
	end		
end

function Yasuo:UBuff(unit, buff)
	if unit.team ~= myHero.team then 
		if buff.Name == "YasuoDashWrapper" then
			self.Marked[unit.networkID] = true
		elseif unit.isHero and (buff.Type == 29 or buff.Type == 30) then
			self.KnockedUp[unit.networkID] = buff.ExpireTime
		end
	end
end

function Yasuo:RBuff(unit, buff)
	if unit.team ~= myHero.team then
		if buff.Name == "YasuoDashWrapper" then
			self.Marked[unit.networkID] = nil
		elseif unit.isHero and (buff.Type == 29 or buff.Type == 30) then
			if self.KnockedUp[unit.networkID] then
				self.KnockedUp[unit.networkID] = 0
			end
		end		
	end
end

function Yasuo:ProcessWP(unit, wp)
	if unit.isMe then
		if wp.dashspeed > unit.ms then
			self.EStuff = {pos = wp.position, speed = wp.dashspeed, distance = GetDistance(wp.position, unit), startTime = GetGameTimer()}
		else
			self.EStuff = nil
		end
	end	
end

function Yasuo:Combo()
	if Winding.Up then
		return
	end
	
	self:GapClose()
	
	if self:Ready(_R) then
		self:CastR()
	end
	
	if YasuoMenu.Combo.CQ:Value() and self:Ready(_Q) and ValidTarget(self.Target, self:QRange()) then
		self:CastQ(self.Target)
	end
	
	if YasuoMenu.Combo.CE:Value() and self:Ready(_E) and ValidTarget(self.Target, self.ERange) and not self:IsMarked(self.Target) and not self:UnderTurret(self:EPos(self.Target)) then
		CastTargetSpell(self.Target, _E)
	end
end

function Yasuo:CastR()
	local k = self.KnockedUp[self.Target.networkID]
	
	if k and ValidTarget(self.Target, 1200 + myHero.boundingRadius) and math.abs(k - GetGameTimer()) <= GetLatency() * 0.004 then
		CastSpell(_R)
	end
end

function Yasuo:GapCloseMinion()	
	local best = nil
	local closest = math.huge
	for _, i in pairs(MinionManager.Minions.Enemy) do
		if ValidTarget(i, self.ERange) and not self:IsMarked(i) and self:IsSafe(self:EPos(i)) then
			if GetDistance(self.Target, self:EPos(i)) < GetDistance(myHero, self.Target) and GetDistance(self:EPos(i), self.Target) < closest then
				best = i
				closest = GetDistance(self:EPos(i), self.Target)
			end
		end
	end
	return best
end

function Yasuo:GapClose()
	if Winding.Up or not self:Ready(_E) then
		return
	end
	
	local k = self:GapCloseMinion()
	
	if (self:Mode() == "Combo" and YasuoMenu.GapClose.GCC:Value() or self:Mode() == "Harass" and YasuoMenu.GapClose.GCH:Value()) and YasuoMenu.GapClose.GCE:Value() then
		if k and self:Ready(_E) and ValidTarget(self.Target, 1500) then
			CastTargetSpell(k, _E)
		end
	end
end

function Yasuo:Harass()
	if Winding.Up then
		return
	end
	
	if YasuoMenu.Harass.HQ:Value() and self:Ready(_Q) and ValidTarget(self.Target, self:QRange()) then
		self:CastQ(self.Target)
	end
	
	if YasuoMenu.Harass.HE:Value() and self:Ready(_E) and ValidTarget(self.Target, self.ERange) and not self:IsMarked(self.Target) and not self:UnderTurret(self:EPos(self.Target)) and GetDistance(self.Target) then
		CastTargetSpell(self.Target, _E)
	end
end

function Yasuo:LaneClear()
	if Winding.Up then
		return
	end
	
	self:LastHit()
	
	if YasuoMenu.LaneClear.LCE:Value() and self:Ready(_E) then
		local m = self:EMinion()
		if m then
			CastTargetSpell(m, _E)
		end
	end
	
	if YasuoMenu.LaneClear.LCQ:Value() and self:Ready(_Q) then
		local bestM = self:QMinion()
		if bestM then
			self:CastQ(bestM)
		end
	end		
end	

function Yasuo:JungleClear()
	if Winding.Up then
		return
	end
	
	for _, i in pairs(MinionManager.Minions.Jungle) do
		if self:Ready(_Q) and YasuoMenu.JungleClear.JCQ:Value() and ValidTarget(i, self:QRange()) then
			self:CastQ(i)
		end
		
		if self:Ready(_E) and YasuoMenu.JungleClear.JCE:Value() and ValidTarget(i, self.ERange) and not self:IsMarked(i) and self:IsSafe(self:EPos(i)) then
			CastTargetSpell(i, _E)
		end
	end
end

function Yasuo:LastHit()
	for _, i in pairs(MinionManager.Minions.Enemy) do
		if Winding.Down or (not Winding.Up and GetDistance(myHero, i) > self.AARange) then
			if YasuoMenu.LastHit.LHQ:Value() and self:Ready(_Q) and ValidTarget(i, self:QRange()) and i.health <= self.Damage[0](i) then
				CastSkillShot(_Q, i)
			elseif YasuoMenu.LastHit.LHE:Value() and self:Ready(_E) and ValidTarget(i, self.ERange) and self:IsSafe(self:EPos(i)) and not self:IsMarked(i) and i.health <= self.Damage[2](i) then
				CastTargetSpell(i, _E)
			end
		end
	end
end

function Yasuo:Killsteal()
	if Winding.Up then
		return
	end
	
	for _, e in pairs(GetEnemyHeroes()) do
		if YasuoMenu.Killsteal.KSQ:Value() and self:Ready(_Q) and ValidTarget(e, self:QRange()) and e.health + e.shieldAD <= self.Damage[0](e) then
			self:CastQ(e)
		elseif YasuoMenu.Killsteal.KSE:Value() and self:Ready(_E) and not self:IsMarked(e) and ValidTarget(e, self.ERange) and e.health + e.shieldAP <= self.Damage[2](e) then
			CastTargetSpell(e, _E)
		elseif YasuoMenu.Killsteal.KSR:Value() and self:Ready(_R) and self:IsAirbourne(e) and ValidTarget(e, 1200 + myHero.boundingRadius) and e.health + e.shieldAP <= self.Damage[3](e) then
			CastSpell(_R)
		end
	end
end

function Yasuo:EMinionsAround(pos, range)
	local hit = 0
	for _, i in pairs(MinionManager.Minions.Enemy) do
		if ValidTarget(i) and GetDistance(i, pos) <= range then
			hit = hit + 1
		end
	end
	return hit
end

function Yasuo:QMinion()
	local bestM = nil
	local most = 0
	for _, i in pairs(MinionManager.Minions.Enemy) do 
		if ValidTarget(i, self:QRange()) then
			local startPos = myHero.pos
			local endPos = startPos + self:QRange() * (i.pos - startPos):normalized()
			local Width = self:QStack() == 1 and self.QStats2.width or self.QStats.width
			local hit = CountObjectsOnLineSegment(startPos, endPos, Width, MinionManager.Minions.Enemy)
			if hit > most then
				most = hit
				bestM = i
			end
		end
	end
	return bestM
end

function Yasuo:EMinion()
	local closest = math.huge
	local m = nil
	for _, i in pairs(MinionManager.Minions.Enemy) do
		if ValidTarget(i, self.ERange) and not self:IsMarked(i) and self:IsSafe(self:EPos(i)) and GetDistance(i) < closest then
			closest = GetDistance(i)
			m = i
		end
	end
	return m
end	

function Yasuo:IsMarked(unit)
	return self.Marked[unit.networkID]
end

function Yasuo:CastQ(unit)
	if not self:Ready(_Q) or unit.dead then
		return
	end
	
	local QRange = (self.EStuff and self.QStats3.range) or (self:QStack() == 1 and self.QStats2.range) or self.QStats.range
	
	if CanUseSpell(myHero, _E) == 8 and self.EStuff and GetDistance(self.EStuff.pos, unit) <= 375 and unit.health - self.Damage[2](unit) > 0 then
		CastSkillShot(_Q, unit)
		return
	end
	
	local Pred = self:QStack() == 1 and GetLinearAOEPrediction(unit, self.QStats2) or GetLinearAOEPrediction(unit, self.QStats)
	
	local HitChance = unit.isMinion and 0 or 0.2
	
	if Pred and GetDistance(myHero, unit) <= QRange and Pred.hitChance >= HitChance then
		CastSkillShot(_Q, Pred.castPos)
	end
end

function Yasuo:IsSafe(pos)
	local t = self:ClosestTurret(pos)
	if t then
		local range = 775 + (t.boundingRadius*2)
		if GetDistance(pos, t) > range then
			return true
		elseif GetDistance(pos, t) <= range and self:AMinionsAround(t, range - t.boundingRadius*2) > 1 then
			return true
		end
		return false
	end
	return true
end

function Yasuo:UnderTurret(pos)
	local t = self:ClosestTurret(pos)
	return t and GetDistance(t, pos) <=  775 + (t.boundingRadius*2)
end

function Yasuo:ClosestTurret(pos)
	local closest = math.huge
	local t = nil
	for _, i in pairs(self.Turrets) do
		if GetDistance(pos, i) <= closest then
			closest = GetDistance(pos, i)
			t = i
		end
	end
	return t
end

function Yasuo:EPos(unit)
	return myHero.pos + (Vector(unit) - myHero.pos):normalized() * 600
end

function Yasuo:QRange()
	return GetCastRange(myHero, _Q) + myHero.boundingRadius
end

function Yasuo:QStack()
	return BuffManager:GetBuff(myHero, "YasuoQ3W")
end

function Yasuo:Ready(spell)
	return CanUseSpell(myHero, spell) == READY
end

function Yasuo:AMinionsAround(pos, range)
	local count = 0
	for _, i in pairs(MinionManager.Minions.Ally) do
		if not i.dead and i.valid and GetDistance(pos, i) <= range then
			count = count + 1
		end
	end
	return count
end

function Yasuo:CountAirbourne()
	local count = 0
	for i, e in pairs(GetEnemyHeroes()) do
		if self.KnockedUp[e.networkID] and self.KnockedUp[e.networkID] > 0 and ValidTarget(e, 1200 + myHero.boundingRadius) then
			count = count + 1
		end
	end
	return count
end

function Yasuo:IsAirbourne(unit)
	return self.KnockedUp[unit.networkID] and self.KnockedUp[unit.networkID] > 0
end

local Champs = {"Yasuo"}
if table.contains(Champs, myHero.charName) then
	require("OpenPredict")
	_G[myHero.charName]()
	MinionManager()
	SkinChanger()
	Winding()
	Damage()
	BuffManager()
	AutoLevel()
end
