if GetObjectName(myHero) ~= "Vayne" then return end

local ver = "0.01"

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Vayne", "Toshibiotro", true)

require ("OpenPredict")
require ("MapPositionGOS")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local VayneMenu = Menu("Vayne", "Vayne")
VayneMenu:SubMenu("Combo", "Combo")
VayneMenu.Combo:Boolean("CQ", "Use Q", true)
VayneMenu.Combo:Boolean("CE", "Use E", true)
VayneMenu.Combo:Boolean("CR", "Use R", true)
VayneMenu.Combo:Slider("CMM", "Min Mana To Combo",20,0,100,1)
VayneMenu.Combo:Boolean("BORK", "Use BORK", true)
VayneMenu.Combo:Boolean("Bilge", "Use Bilge", true)
VayneMenu.Combo:Boolean("RotSec", "ZZRot Condemn", true)

VayneMenu:SubMenu("Harass", "Harass")
VayneMenu.Harass:Boolean("HQ", "Use Q", true)
VayneMenu.Harass:Boolean("HE", "Use E", true)
VayneMenu.Harass:Slider("HMM", "Min Mana To Harass",20,0,100,1)

VayneMenu:SubMenu("LaneClear", "LaneClear")
VayneMenu.LaneClear:Boolean("LCQ", "Use Q", true)
VayneMenu.LaneClear:Slider("LCMM", "Min Mana To LaneClear",20,0,100,1)

VayneMenu:SubMenu("JungleClear", "JungleClear")
VayneMenu.JungleClear:Boolean("JCQ", "Use Q", true)
VayneMenu.JungleClear:Boolean("JCE", "Use E", true)
VayneMenu.JungleClear:Slider("JCMM", "Min Mana To JungleClear",20,0,100,1)

VayneMenu:SubMenu("KillSteal", "KillSteal")
VayneMenu.KillSteal:Boolean("KSQ", "Use Q", true)
VayneMenu.KillSteal:Boolean("KSW", "Use W", true)

VayneMenu:SubMenu("Misc", "Misc")
VayneMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ", "Toshi Special"})
VayneMenu.Misc:Boolean("AC", "Auto Condemn", true)
VayneMenu.Misc:Boolean("ACA", "Anivia Wall Condemn", true)
VayneMenu.Misc:Boolean("ACT", "Trundle Pillar Condemn", true)
VayneMenu.Misc:Boolean("QSS", "Use QSS", true)
VayneMenu.Misc:Boolean("AI", "Auto Ignite", true)
VayneMenu.Misc:Boolean("AR", "Auto R", true)
VayneMenu.Misc:Slider("ARC", "Min Enemies To Auto R",3,1,6,1)
VayneMenu.Misc:Boolean("DAAS", "Don't AA While Invis", true)
VayneMenu.Misc:Boolean("QAC", "Q Animation Cancel", true)

VayneMenu:SubMenu("GapClose", "GapClose")
VayneMenu.GapClose:Boolean("GCQ", "Use Q", true)
VayneMenu.GapClose:Boolean("GCR", "Use R", false)

VayneMenu:SubMenu("AntiGapCloser", "AntiGapCloser")
VayneMenu.AntiGapCloser:Boolean("AGE", "Use E", true)

VayneMenu:SubMenu("Draw", "Drawings")
VayneMenu.Draw:Boolean("DAA", "Draw AA Range", true)
VayneMenu.Draw:Boolean("DQ", "Draw Q Range", true)
VayneMenu.Draw:Boolean("DE", "Draw E Range", true)
VayneMenu.Draw:Boolean("DWD", "Draw W Damage", true)

VayneMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Vayne"] = {"Classic", "Vindicator", "Aristocrat", "DragonSlayer", "Heartseeker", "SKT T1", "Arclight", "DragonSlayer Green", "DragonSlayer Red", "DragonSlayer Blue", "SoulStealer"}}
VayneMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
VayneMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end	

local target = GetCurrentTarget()
function QDmg(unit) return CalcDamage(myHero, unit, myHero.totalDamage + (myHero.totalDamage * (0.25 + 0.05 * GetCastLevel(myHero, _W))), 0) end
function WDmg(unit) return (unit.maxHealth * (0.045 + 0.015 * GetCastLevel(myHero, _W))) end
function AADmg(unit) return CalcDamage(myHero, unit, myHero.totalDamage, 0) end
local Move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local CCType = {[5] = "Stun", [7] = "Silence", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local QSS = nil
local MercSkimm = nil
local AARange = GetRange(myHero) + GetHitBox(myHero)
local ERange = GetCastRange(myHero, _E) + GetHitBox(myHero)
local QRange = GetCastRange(myHero, _Q)
local CPos = nil
local ZSpot = nil
local ZZRot = nil
local WallC = nil

OnTick(function()
	
	target = GetCurrentTarget()
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local BORK = GetItemSlot(myHero, 3153)
	local Bilge = GetItemSlot(myHero, 3144)
	QSS = GetItemSlot(myHero, 3140)
	MercSkimm = GetItemSlot(myHero, 3139)
	local movePos = GetPrediction(target,Move).castPos
	CPos = target.pos + (target.pos - myHero.pos):normalized() * 450
	local WStacks = GetBuffData(target, "VayneSilveredDebuff").Count
	ZSpot = target.pos + (target.pos - myHero.pos):normalized() * 100
	ZZRot = GetItemSlot(myHero, 3512)
	
	if myHero.isStealthed and VayneMenu.Misc.DAAS:Value() then Mix:BlockAttack(true) end
	if myHero.isVisible then Mix:BlockAttack(false) end
	
	--AutoLevel
	if VayneMenu.Misc.AutoLevel:Value() == 2 then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	if VayneMenu.Misc.AutoLevel:Value() == 3 then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if VayneMenu.Misc.AutoLevel:Value() == 4 then
		spellorder = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if VayneMenu.Misc.AutoLevel:Value() == 5 then
		spellorder = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if VayneMenu.Misc.AutoLevel:Value() == 6 then
		spellorder = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if VayneMenu.Misc.AutoLevel:Value() == 7 then
		spellorder = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if VayneMenu.Misc.AutoLevel:Value() == 8 then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _W, _W, _W, _W, _R, _Q, _Q, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end		
	
	--Combo
	if Mix:Mode() == "Combo" then
		
		if VayneMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if GetPercentMP(myHero) >= VayneMenu.Combo.CMM:Value() then
				if GetDistance(myHero, target) < GetRange(target) and GetRange(target) < AARange then
					CastTargetSpell(target, _E)
				end
			end
		end

		if VayneMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 600) then
			if GetPercentMP(myHero) >= VayneMenu.Combo.CMM:Value() then
				if GetPercentHP(myHero) >= GetPercentHP(target) and GetPercentHP(target) >= 30 then
					CastSpell(_R)
				end
			end	
		end		
		
		if VayneMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 90 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end
		
		if VayneMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) >= GetPercentHP(target) and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end		

		if VayneMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) >= GetPercentHP(target) and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end

		if VayneMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) >= 90 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end
	end
	
	--Harass
	if Mix:Mode() == "Harass" then
		
		if VayneMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if GetPercentMP(myHero) >= VayneMenu.Harass.HMM:Value() then
				if GetDistance(myHero, target) < GetRange(target) and GetRange(target) < AARange then
					CastTargetSpell(target, _E)
				end
			end
		end
	end
	
	--JungleClear
	if Mix:Mode() == "LaneClear" then
	
		for _, minion in pairs(minionManager.objects) do
			local CMPos = minion.pos + (minion.pos - myHero.pos):normalized() * 450
			if GetTeam(minion) == 300 then
				if not GetObjectName(minion):lower():find("sru_dragon") and not GetObjectName(minion):lower():find("sru_baron") and not GetObjectName(minion):lower():find("mini") then
					if VayneMenu.JungleClear.JCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
						if GetPercentMP(myHero) >= VayneMenu.JungleClear.JCMM:Value() and GetPercentHP(minion) >= 30 then
							if MapPosition:inWall(CMPos) then
								CastTargetSpell(minion, _E)
							end
						end
					end
				end
			end
		end
	end

	--KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if AniviaWall ~= nil then
			WallC = AniviaWall.pos + (AniviaWall.pos - myHero.pos):normalized() * 450
		end	
		
		if TrundlePillar ~= nil then
			WallT = TrundlePillar.pos + (TrundlePillar.pos - myHero.pos):normalized() * 450
		end
		
		if VayneMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, QRange + AARange) then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) <= QDmg(enemy) then
				CastSkillShot(_Q, enemy)
				AttackUnit(enemy)
			end
		end
	
		if VayneMenu.KillSteal.KSW:Value() and ValidTarget(enemy, AARange) then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) <= WDmg(enemy) then
				if AlliesAround(enemy, 600) >= 2 and WStacks(enemy) == 2 then
					AttackUnit(enemy)
				end
			end
		end

		--AutoCondemn
		if VayneMenu.Misc.AC:Value() and Ready(_E) and ValidTarget(enemy, ERange) then
			if MapPosition:inWall(CPos) then
				CastTargetSpell(enemy, _E)
			end
		end
		
		if AniviaWall ~= nil then
			if VayneMenu.Misc.ACA:Value() and Ready(_E) and ValidTarget(enemy, ERange) and CountObjectsOnLineSegment(WallC, AniviaWall, 400, GetEnemyHeroes()) > 0 then
				blah = false
				CastTargetSpell(enemy, _E)
			end	
		end
 
		if TrundlePillar ~= nil then
			if VayneMenu.Misc.ACT:Value() and Ready(_E)	and ValidTarget(enemy, ERange) and CountObjectsOnLineSegment(WallT, TrundlePillar, 225, GetEnemyHeroes()) > 0 then
				blah = false
				CastTargetSpell(enemy, _E)
			end	
		end	
		
		--Auto Ignite 
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if VayneMenu.Misc.AI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) + GetShieldDmg(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if VayneMenu.Misc.AI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end

	--Auto R
	if VayneMenu.Misc.AR:Value() and Ready(_R) then
		if EnemiesAround(myHero, 800) >= VayneMenu.Misc.ARC:Value() and GetPercentHP(myHero) >= 30 then
			CastSpell(_R)
		end
	end
	
	--GapClose
	if VayneMenu.GapClose.GCQ:Value() and Ready(_Q) and ValidTarget(target, 1000) and GetDistance(myHero, target) > AARange then
		if GetDistance(movePos) > GetDistance(target) then
			if Mix:Mode() == "Combo" or Mix:Mode() == "Harass" then
				CastSkillShot(_Q, target)
			end
		end
	end
	
	if VayneMenu.GapClose.GCR:Value() and Ready(_R) and ValidTarget(target, 1200) and GetDistance(myHero, target) > AARange then
		if GetDistance(movePos) > GetDistance(target) and target.ms > myHero.ms then
			if Mix:Mode() == "Combo" or Mix:Mode() == "Harass" then
				CastSpell(_R)
			end
		end	
	end
	
	--ZZRot Condemn
	if VayneMenu.Combo.RotSec:Value() and Ready(_E) and ValidTarget(target, 375) and EnemiesAround(target, 800) < 1 then
		if not MapPosition:inWall(CPos) and ZZRot > 0 and Ready(ZZRot) then
			CastTargetSpell(target, _E)
			blah = true
			else blah = false
		end
	end		
end)	

--Auto QSS
OnUpdateBuff(function(unit, buff)
	if unit.isMe and CCType[buff.Type] and VayneMenu.Misc.QSS:Value() and QSS > 0 and Ready(QSS) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(QSS)
		end	
	end
	
	if unit.isMe and CCType[buff.Type] and VayneMenu.Misc.QSS:Value() and MercSkimm > 0 and Ready(MercSkimm) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(MercSkimm)
		end
	end
end)	

OnDraw(function()
	if VayneMenu.Draw.DQ:Value() then DrawCircle(myHero, QRange, 1, 25, GoS.Red) end
	if VayneMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 1, 25, GoS.Blue) end
	if VayneMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 1, 25, GoS.White) end
	
	for _, enemy in pairs(GetEnemyHeroes()) do
		if VayneMenu.Draw.DWD:Value() then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), WDmg(enemy), 0, GoS.White) end
	end
end)	

-- Auto Attack Resets
OnProcessSpellComplete(function(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if VayneMenu.Combo.CQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) and GetCurrentHP(spell.target) > AADmg(spell.target) then
				if GetPercentMP(myHero) >= VayneMenu.Combo.CMM:Value() then	
					CastSkillShot(_Q, GetMousePos())
				end	
			end
		end
			
		if Mix:Mode() == "Harass" then
			if VayneMenu.Harass.HQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) and GetCurrentHP(spell.target) > AADmg(spell.target) then
				if GetPercentMP(myHero) >= 	VayneMenu.Harass.HMM:Value() then
					CastSkillShot(_Q, GetMousePos())
				end				
			end
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			if GetTeam(spell.target) == 300 - GetTeam(myHero) then
				if VayneMenu.LaneClear.LCQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) and GetCurrentHP(spell.target) > AADmg(spell.target) then
					if GetPercentMP(myHero) >= VayneMenu.LaneClear.LCMM:Value() then
						CastSkillShot(_Q, GetMousePos())
					end
				end
			end

			if GetTeam(spell.target) == 300 then
				if VayneMenu.JungleClear.JCQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) and GetCurrentHP(spell.target) > AADmg(spell.target) then
					if GetPercentMP(myHero) >= VayneMenu.JungleClear.JCMM:Value() then
						CastSkillShot(_Q, GetMousePos())
					end
				end
			end
		end
	end
end)

OnCreateObj(function(object)
	if object.isSpell and object.spellName:lower():find("aniviaiceblock") and object.spellOwner.team == GetTeam(myHero) then
		AniviaWall = object
	end
	
	if object.isSpell and object.spellName:lower():find("trundlewall") and object.spellOwner.team == GetTeam(myHero) then
		TrundlePillar = object
	end
end)

OnDeleteObj(function(object)
	if object.isSpell and object.spellName:lower():find("aniviaiceblock") and object.spellOwner.team == GetTeam(myHero) then
        AniviaWall = nil
	end
	
	if object.isSpell and object.spellName:lower():find("trundlewall") and object.spellOwner.team == GetTeam(myHero) then
		TrundlePillar = nil
	end
end)	

OnAnimation(function(unit, animation)
	if unit.isMe and animation:lower():find("spell1") then
		if VayneMenu.Misc.QAC:Value() then
			CastEmote(EMOTE_DANCE)
		end		
	end	
end)

OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("vaynecondemn") and spell.target.isHero and blah then
		if ZZRot > 0 then
			if Ready(ZZRot) and IsObjectAlive(spell.target) then
				CastSkillShot(ZZRot, ZSpot)
			end	
		end
	end
end)

OnProcessWaypoint(function(unit, waypointProc)
	if unit.isHero and waypointProc.dashspeed > unit.ms and not unit.isMe and unit.team == 300 - myHero.team and unit.isTargetable then
		local dashTargetPos = waypointProc.position
		if VayneMenu.AntiGapCloser.AGE:Value() then	
			if GetDistance(myHero, dashTargetPos) < ERange and Ready(_E) then
				CastTargetSpell(unit, _E)
			end	
		end
	end
end)	

print("Thanks For Using Eternal Vayne, Have Fun " ..myHero.name.. " :)")	
