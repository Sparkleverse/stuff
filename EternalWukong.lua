if GetObjectName(myHero) ~= "MonkeyKing" then return end

local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalWukong.lua", SCRIPT_PATH .. "EternalWukong.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalWukong.version", AutoUpdate)

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Wukong", "Toshibiotro", true)

require ("OpenPredict")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local WMenu = Menu("W", "Wukong")
WMenu:SubMenu("C", "Combo")
WMenu.C:Boolean("CQ", "Use Q", true)
WMenu.C:DropDown("CQC", "Q Settings", 1, {"Normal", "AA Reset"})
WMenu.C:Boolean("CW", "Use W", true)
WMenu.C:Slider("CWC", "HP To W", 75, 0, 100, 1)
WMenu.C:Boolean("CE", "Use E", true)
WMenu.C:Boolean("CR", "Use R", true)
WMenu.C:Slider("CMM", "Min Mana To Combo", 20, 0, 100, 1)
WMenu.C:Boolean("CRC", "Stick To Target With R", true)
WMenu.C:Boolean("CTH", "Use T Hydra", true)
WMenu.C:Boolean("CRH", "Use R Hydra", true)
WMenu.C:Boolean("CYGB", "Use GhostBlade", true)

WMenu:SubMenu("H", "Harass")
WMenu.H:Boolean("HQ", "Use Q", true)
WMenu.H:DropDown("HQC", "Q Settings", 1, {"Normal", "AA Reset"})
WMenu.H:Boolean("HW", "Use W", true)
WMenu.H:Slider("HWC", "HP To Use W", 75, 0, 100, 1)
WMenu.H:Boolean("HE", "Use E", true)
WMenu.H:Slider("HMM", "Min Mana To Harass", 40, 0, 100, 1)

WMenu:SubMenu("LH", "LastHit")
WMenu.LH:Boolean("LHQ", "Use Q", true)
WMenu.LH:Boolean("LHE", "Use E", true)

WMenu:SubMenu("LC", "LaneClear")
WMenu.LC:Boolean("LCQ", "Use Q", true)
WMenu.LC:Boolean("LCW", "Use W", true)
WMenu.LC:Boolean("LCE", "Use E", true)
WMenu.LC:Slider("LCMM", "Min Mana To LaneClear", 40, 0, 100, 1)
WMenu.LC:Boolean("LCTH", "Use T Hydra", true)
WMenu.LC:Boolean("LCRH", "Use R Hydra", true)

WMenu:SubMenu("JC", "JungleClear")
WMenu.JC:Boolean("JCQ", "Use Q", true)
WMenu.JC:Boolean("JCW", "Use W", true)
WMenu.JC:Boolean("JCE", "Use E", true)
WMenu.JC:Slider("JCMM", "Min Mana To Jungle", 50, 0, 100, 1)	
WMenu.JC:Boolean("JCTH", "Use T Hydra", true)
WMenu.JC:Boolean("JCRH", "Use R Hydra", true)

WMenu:SubMenu("KS", "KillSteal")
WMenu.KS:Boolean("KSQ", "Use Q", true)
WMenu.KS:Boolean("KSE", "Use E", true)

WMenu:SubMenu("M", "Misc")
WMenu.M:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
WMenu.M:Boolean("AR", "Auto R", true)
WMenu.M:Slider("ARC", "Min Enemies To Auto R", 3, 1, 6, 1)
WMenu.M:Boolean("AW", "Auto W", true)
WMenu.M:Slider("AWC", "Min HP To W", 20, 0, 100, 1)
WMenu.M:Boolean("AI", "Auto Ignite", true)
WMenu.M:Boolean("QSS", "Use QSS", true)
WMenu.M:Slider("QSSC", "HP To QSS", 90, 0, 100, 1)
WMenu.M:Boolean("DAAS", "Dont Attack While Invis", true)
WMenu.M:Boolean("QT", "Use Q On Towers", true)

WMenu:SubMenu("D", "Drawings")
WMenu.D:Boolean("DAA", "Draw AA Range", true)
WMenu.D:Boolean("DQ", "Draw Q Range", true)
WMenu.D:Boolean("DE", "Draw E Range", true)
WMenu.D:Boolean("DR", "Draw R Range", true)
WMenu.D:Boolean("DD", "Draw Damage", true)

WMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["MonkeyKing"] = {"Classic", "Volcanic", "General", "Jade Dragon", "Underworld", "Radiant"}}
WMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
WMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end	

local spellorder1 = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
local spellorder2 = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
local spellorder3 = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
local spellorder4 = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
local spellorder5 = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
local spellorder6 = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}

local target = GetCurrentTarget()
function QDmg(unit) return CalcDamage(myHero, unit, myHero.totalDamage + ((30 * GetCastLevel(myHero, _Q)) + (myHero. totalDamage * 0.1)), 0) end
function EDmg(unit) return CalcDamage(myHero, unit, 15 + 45 * GetCastLevel(myHero, _E) + GetBonusDmg(myHero) * 0.8) end
local AARange = GetRange(myHero) + GetHitBox(myHero)
local ERange = GetCastRange(myHero, _E) + GetHitBox(myHero)
local QRange = GetCastRange(myHero, _Q) + GetHitBox(myHero)
local RRange = GetCastRange(myHero, _R) + GetHitBox(myHero)
function RDmg(unit) return CalcDamage(myHero, unit, ((-70 + 90 * GetCastLevel(myHero, _R)) + (myHero.totalDamage * 1.1)) * 4, 0) end
local TH = nil
local T = nil
local RH = nil
local YGB = nil
local CCType = {[5] = "Stun", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}

OnTick(function()
	
	target = GetCurrentTarget()
	TH = GetItemSlot(myHero, 3748)
	T = GetItemSlot(myHero, 3077)
	RH = GetItemSlot(myHero, 3074)
	YGB = GetItemSlot(myHero, 3142)
	local Invis = GotBuff(myHero, "monkeykingdecoystealth")
	local UltOn = GotBuff(myHero, "MonkeyKingSpinToWin")
	local THBuff = GotBuff(myHero, "itemtitanichydracleavebuff")
	local IDamage = (50 + (20 * GetLevel(myHero)))
	
	if Invis > 0 and WMenu.M.DAAS:Value() then Mix:BlockAttack(true) end
	if Invis < 1 then Mix:BlockAttack(false) end
	
	if UltOn > 0 then Mix:BlockAttack(true) end
	if UltOn < 1 then Mix:BlockAttack(false) end
	
	--AutoLevel
	if GetLevelPoints(myHero) > 0 then
		if WMenu.M.AutoLevel:Value() == 2 then
			LevelSpell(spellorder1[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			elseif WMenu.M.AutoLevel:Value() == 3 then
			LevelSpell(spellorder2[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			elseif WMenu.M.AutoLevel:Value() == 4 then
			LevelSpell(spellorder3[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			elseif WMenu.M.AutoLevel:Value() == 5 then
			LevelSpell(spellorder4[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			elseif WMenu.M.AutoLevel:Value() == 6 then
			LevelSpell(spellorder5[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			elseif WMenu.M.AutoLevel:Value() == 7 then
			LevelSpell(spellorder6[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	-- Combo
	if Mix:Mode() == "Combo" then
		if WMenu.C.CQ:Value() and WMenu.C.CQC:Value() == 1 and Ready(_Q) and ValidTarget(target, QRange) then
			if GetPercentMP(myHero) >= WMenu.C.CMM:Value() then
				CastSpell(_Q)
			end
		end
		
		if WMenu.C.CE:Value() and Ready(_E) and ValidTarget(target, ERange) and GetDistance(target) > AARange then
			if GetPercentMP(myHero) >= WMenu.C.CMM:Value() then
				CastTargetSpell(target, _E)
			end
		end
		
		if WMenu.C.CW:Value() and Ready(_W) and ValidTarget(target, 175) then
			if GetPercentMP(myHero) >= WMenu.C.CMM:Value() and GetPercentHP(myHero) <= WMenu.C.CWC:Value() then
				CastSpell(_W)
			end	
		end
		
		if WMenu.C.CR:Value() and UltOn < 1 and Ready(_R) and not Ready(_E) and not Ready(_Q) and not Ready(TH) and not Ready(T) and not Ready(RH) and THBuff < 1 and ValidTarget(target, RRange) and GetPercentHP(target) >= 25 then
			CastSpell(_R)
		end
		
		if WMenu.C.CRC:Value() and UltOn > 0 and ValidTarget(target, 600) then
			MoveToXYZ(target)
		end

		if WMenu.C.CYGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 700) then
			CastSpell(YGB)
		end
	end
	
	-- Harass
	if Mix:Mode() == "Harass" then
		if WMenu.C.CQ:Value() and WMenu.H.HQC:Value() == 1 and Ready(_Q) and ValidTarget(target, QRange) then
			if GetPercentMP(myHero) >= WMenu.H.HMM:Value() then
				CastSpell(_Q)
			end	
		end	
	
		if WMenu.H.HE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if GetPercentMP(myHero) >= WMenu.H.HMM:Value() then
				CastTargetSpell(target, _E)
			end
		end
		
		if WMenu.H.HW:Value() and Ready(_W) and ValidTarget(target, 175) then
			if GetPercentMP(myHero) >= WMenu.H.HMM:Value() and GetPercentHP(myHero) <= WMenu.H.HEC:Value() then
				CastSpell(_W)
			end
		end
	end		

	--LaneClear
	if Mix:Mode() == "LaneClear" then
		for _,minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if WMenu.LC.LCW:Value() and Ready(_W) and ValidTarget(minion, AARange) and MinionsAround(minion, 175, MINION_ENEMY) > 2 then
					if GetPercentMP(myHero) >= WMenu.LC.LCMM:Value() then
						CastSpell(_W)
					end	
				end
				
				if WMenu.LC.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) and MinionsAround(minion, 187.5, MINION_ENEMY) > 1 then
					if GetPercentMP(myHero) >= WMenu.LC.LCMM:Value() then
						CastTargetSpell(minion, _E)
					end	
				end
			end
			
			if GetTeam(minion) == 300 then
				if WMenu.JC.JCE:Value() and Ready(_E) and ValidTarget(minion, ERange) and not GetObjectName(minion):lower():find("mini") then
					if GetPercentMP(myHero) >= WMenu.JC.JCMM:Value() then
						CastTargetSpell(minion, _E)
					end	
				end
			end
		end
	end
	
	--LastHit
	if Mix:Mode() == "LastHit" then
		for _,minion in pairs(minionManager.objects) do
			if WMenu.LH.LHQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) and GetDistance(myHero, minion) > AARange then
				if GetCurrentHP(minion) < QDmg(minion) then
					CastSpell(_Q)
				end	
			end
			
			if WMenu.LH.LHE:Value() and Ready(_E) and ValidTarget(minion, ERange) and GetDistance(myHero, minion) > AARange then
				if GetCurrentHP(minion) < EDmg(minion) then
					CastTargetSpell(minion, _E)
				end
			end
		end
	end				

	-- KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if WMenu.KS.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, QRange) then
			if GetCurrentHP(enemy) + GetHPRegen(enemy) + GetDmgShield(enemy) <= QDmg(enemy) then
				CastSpell(_Q)
				AttackUnit(enemy)
			end
		end

		if WMenu.KS.KSE:Value() and Ready(_E) and ValidTarget(enemy, ERange) then
			if GetCurrentHP(enemy) + GetHPRegen(enemy) + GetDmgShield(enemy) <= EDmg(enemy) then
				CastTargetSpell(enemy, _E)
			end
		end

		-- Auto Ignite
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if WMenu.M.AI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) + GetShieldDmg(enemy) + GetHPRegen(enemy) <= IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if WMenu.M.AI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) <= IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end

	-- Auto R
	if WMenu.M.AR:Value() and Ready(_R) then
		if EnemiesAround(myHero, RRange) >= WMenu.M.ARC:Value() then
			CastSpell(_R)
		end	
	end
	
	-- Auto W
	if WMenu.M.AW:Value() and Ready(_W) then
		if EnemiesAround(myHero, 700) >= 1 and GetPercentHP(myHero) <= WMenu.M.AWC:Value() then
			CastSpell(_W)
		end	
	end
end)	

-- Auto QSS
OnUpdateBuff(function(unit, buff)
	local QSS = GetItemSlot(myHero, 3140)
	local MercSkimm = GetItemSlot(myHero, 3139)
	if unit.isMe and CCType[buff.Type] and WMenu.M.QSS:Value() and QSS > 0 and Ready(QSS) then
		if GetPercentHP(myHero) <= WMenu.M.QSSC:Value() and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(QSS)
		end	
	end
	
	if unit.isMe and CCType[buff.Type] and WMenu.M.QSS:Value() and MercSkimm > 0 and Ready(MercSkimm) then
		if GetPercentHP(myHero) <= WMenu.M.QSSC:Value() and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(MercSkimm)
		end
	end
end)

-- Drawings
OnDraw(function()
	if IsObjectAlive(myHero) then
		if WMenu.D.DQ:Value() then DrawCircle(myHero, QRange, 1, 25, GoS.Red) end
		if WMenu.D.DE:Value() then DrawCircle(myHero, ERange, 1, 25, GoS.Cyan) end
		if WMenu.D.DAA:Value() then DrawCircle(myHero, AARange, 1, 25, GoS.White) end
		if WMenu.D.DR:Value() then DrawCircle(myHero, RRange, 1, 25, GoS.Pink) end
		
		for _, enemy in pairs(GetEnemyHeroes()) do
			if WMenu.D.DD:Value() then
				if Ready(_Q) and not Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), QDmg(enemy), 0, GoS.White)
					elseif Ready(_Q) and Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), QDmg(enemy) + EDmg(enemy), 0, GoS.White)
					elseif Ready(_Q) and not Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), QDmg(enemy) + RDmg(enemy), 0, GoS.White)
					elseif Ready(_Q) and Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), QDmg(enemy) + EDmg(enemy) + RDmg(enemy), 0, GoS.White)
					elseif not Ready(_Q) and Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), EDmg(enemy) + RDmg(enemy), 0, GoS.White)
					elseif not Ready(_Q) and not Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), RDmg(enemy), 0, GoS.White)
					elseif not Ready(_Q) and Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), RDmg(enemy) + EDmg(enemy), 0, GoS.White)
				end
			end
		end
	end	
end)		

--Some Stuff	
OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("tiamatcleave") then
		Mix:ResetAA()
	end
	
	if unit.isMe and spell.name:lower():find("monkeykingq") then
		Mix:ResetAA()
	end
	
	if Mix:Mode() == "LaneClear" then
		if unit.isMinion and GetTeam(unit) == 300 and not GetObjectName(unit):lower():find("mini") and spell.target.isMe then
			if WMenu.JC.JCW:Value() and Ready(_W) and GetPercentMP(myHero) >= WMenu.JC.JCMM:Value() then
				DelayAction(function()
					CastSpell(_W)
				end, spell.windUpTime / 1.5)
			end
		end		
	end
	
	if unit.isMe and spell.name:lower():find("monkeykingspintowin") then
		if YGB > 0 and Ready(YGB) then
			CastSpell(YGB)
		end	
	end
end)	

-- AA Resets
OnProcessSpellComplete(function(unit, spell)
	if Mix:Mode() == "Combo" then
		if unit.isMe and spell.target.isHero and IsObjectAlive(spell.target) then
			if spell.name:lower():find("basicattack") and WMenu.C.CQ:Value() and WMenu.C.CQC:Value() == 2 then
				if Ready(_Q) and GetPercentMP(myHero) >= WMenu.C.CMM:Value() then
					CastSpell(_Q)
				end
			end

			if spell.name:lower():find("basicattack") then
				if WMenu.C.CTH:Value() and not Ready(_Q) and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.C.CRH:Value() and not Ready(_Q) and RH > 0 and Ready(RH) then
					CastSpell(RH)
					elseif WMenu.C.CRH:Value() and not Ready(_Q) and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end		
		
			if spell.name:lower():find("monkeykingq") then
				if WMenu.C.CTH:Value() and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.C.CRH:Value() and RH > 0 and Ready(RH) then
					CastSpell(RH)
					elseif WMenu.C.CRH:Value() and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end	
		end
	end

	if Mix:Mode() == "Harass" then
		if unit.isMe and spell.target.isHero and IsObjectAlive(spell.target) then
			if spell.name:lower():find("basicattack") and WMenu.H.HQ:Value() and WMenu.H.HQC:Value() == 2 then
				if Ready(_Q) and GetPercentMP(myHero) >= WMenu.H.HMM:Value() then
					CastSpell(_Q)
				end
			end

			if spell.name:lower():find("basicattack") then
				if WMenu.H.HTH:Value() and not Ready(_Q) and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.H.HRH:Value() and not Ready(_Q) and RH > 0 and Ready(RH) then
					CastSpell(RH)
					elseif WMenu.H.HRH:Value() and not Ready(_Q) and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end

			if spell.name:lower():find("monkeykingq") then
				if WMenu.H.HTH:Value() and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.H.HRH:Value() and RH > 0 and Ready(TH) then
					CastSpell(RH)
					elseif WMenu.H.HRH:Value() and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end
		end
	end

	if Mix:Mode() == "LaneClear" then
		if unit.isMe and spell.target.isMinion and GetTeam(spell.target) == MINION_ENEMY and IsObjectAlive(spell.target) then
			if spell.name:lower():find("basicattack") and WMenu.LC.LCQ:Value() then
				if Ready(_Q) and GetPercentMP(myHero) >= WMenu.LC.LCMM:Value() then
					CastSpell(_Q)
				end
			end
			
			if spell.name:lower():find("basicattack") then
				if WMenu.LC.LCTH:Value() and not Ready(_Q) and TH > 0 and Ready(TH) and MinionsAround(spell.target, 700, MINION_ENEMY) > 1 then
					CastSpell(TH)
					elseif WMenu.LC.LCRH:Value() and not Ready(_Q) and RH > 0 and Ready(RH) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(RH)
					elseif WMenu.LC.LCRH:Value() and not Ready(_Q) and T > 0 and Ready(T) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(T)
				end
			end

			if spell.name:lower():find("monkeykingq") then
				if WMenu.LC.LCTH:Value() and TH > 0 and Ready(TH) and MinionsAround(spell.target, 700, MINION_ENEMY) > 1 then
					CastSpell(TH)
					elseif WMenu.LC.LCRH:Value() and RH > 0 and Ready(RH) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(RH)
					elseif WMenu.LC.LCRH:Value() and T > 0 and Ready(T) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(T)
				end
			end
		end

		if unit.isMe and spell.target.isMinion and GetTeam(spell.target) == 300 and IsObjectAlive(spell.target) and not GetObjectName(spell.target):lower():find("mini") then
			if spell.name:lower():find("basicattack") and WMenu.JC.JCQ:Value() then
				if Ready(_Q) and GetPercentMP(myHero) >= WMenu.JC.JCMM:Value() then
					CastSpell(_Q)
				end
			end

			if spell.name:lower():find("basicattack") then
				if WMenu.JC.JCTH:Value()and not Ready(_Q) and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.JC.JCRH:Value() and not Ready(_Q) and RH > 0 and Ready(RH) then
					CastSpell(RH)
					elseif WMenu.JC.JCRH:Value() and not Ready(_Q) and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end
		
			if spell.name:lower():find("monkeykingq") then
				if WMenu.JC.JCTH:Value() and TH > 0 and Ready(TH) then
					CastSpell(TH)
					elseif WMenu.JC.JCRH:Value() and RH > 0 and Ready(RH) then
					CastSpell(RH)
					elseif WMenu.JC.JCRH:Value() and T > 0 and Ready(T) then
					CastSpell(T)
				end
			end		
		end
	end

	if unit.isMe and spell.name:lower():find("basicattack") and spell.target.name:lower():find("turret") and Ready(_Q) then
		CastSpell(_Q)
	end
end)

print("Thanks For Using Eternal Wukong, Have Fun " ..myHero.name.. " :)")	
