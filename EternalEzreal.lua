if GetObjectName(myHero) ~= "Ezreal" then return end

local ver = "0.02"

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Ezreal", "Toshibiotro", true)

require ("DamageLib")
require ("OpenPredict")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalEzreal.lua", SCRIPT_PATH .. "EternalEzreal.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalEzreal.version", AutoUpdate)

if FileExist(COMMON_PATH.."Draw.lua") then
	require ("Draw")
else
print("draw.lua not found please wait for download")
DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/draw.lua", COMMON_PATH .."Draw.lua", function() print("Draw.lua Downloaded, Please 2x F6") return end)
end	

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local EzrealMenu = Menu("Ezreal", "Ezreal")
EzrealMenu:SubMenu("Combo", "Combo")
EzrealMenu.Combo:Boolean("CQ", "Use Q", true)
EzrealMenu.Combo:Boolean("CW", "Use W", true)
EzrealMenu.Combo:Boolean("CR", "Use R", true)
EzrealMenu.Combo:Boolean("BORK", "Use BORK", true)
EzrealMenu.Combo:Boolean("Bilge", "Use Cutlass", true	)
EzrealMenu.Combo:Slider("CMM", "Min Mana To Combo",50,0,100,1)

EzrealMenu:SubMenu("Harass", "Harass", true)
EzrealMenu.Harass:Boolean("HQ", "Use Q", true)
EzrealMenu.Harass:Boolean("HW", "Use W", true)
EzrealMenu.Harass:Slider("HMM", "Min Mana To Harass",50,0,100,1)

EzrealMenu:SubMenu("AH", "Auto Harass")
EzrealMenu.AH:Boolean("AHQ", "Use Q", true)
EzrealMenu.AH:Boolean("AHW", "Use W", true)
EzrealMenu.AH:Slider("AHC", "Min Mana To Auto Harass",60,0,100,1)

EzrealMenu:SubMenu("LaneClear", "LaneClear", true)
EzrealMenu.LaneClear:Boolean("LCQ", "Use Q", true)
EzrealMenu.LaneClear:Boolean("LCR", "Use R", true)
EzrealMenu.LaneClear:Slider("LCRC", "Min Minions To R",8,1,20,1)
EzrealMenu.LaneClear:Slider("LCMM", "Min Mana To LaneClear",50,0,100,1)

EzrealMenu:SubMenu("LastHit", "LastHit")
EzrealMenu.LastHit:Boolean("LHQ", "Use Q", true)

EzrealMenu:SubMenu("KillSteal", "KillSteal")
EzrealMenu.KillSteal:Boolean("KSQ", "Use Q", true)
EzrealMenu.KillSteal:Boolean("KSW", "Use W", true)
EzrealMenu.KillSteal:Boolean("KSR", "Use R", true)
EzrealMenu.KillSteal:Slider("KSRC", "Distance To KS R",3000,1,100000,1000)

EzrealMenu:SubMenu("Misc", "Misc")
EzrealMenu.Misc:Boolean("QSS", "Auto QSS", true)
EzrealMenu.Misc:Boolean("TearS", "Auto Stack Tear", true)
EzrealMenu.Misc:Slider("TearC", "Min Mana To Stack",70,0,100,1)
EzrealMenu.Misc:Slider("RC", "Range For R", 4000,100,100000,100)
EzrealMenu.Misc:SubMenu("AL", "Auto Level")
EzrealMenu.Misc.AL:Boolean("UAL", "Use Auto Level", false)
EzrealMenu.Misc.AL:Boolean("ALQEW", "R>Q>E>W", false)
EzrealMenu.Misc.AL:Boolean("ALQWE", "R>Q>W>E", false)
EzrealMenu.Misc.AL:Boolean("ALWQE", "R>W>Q>E", false)
EzrealMenu.Misc.AL:Boolean("ALWEQ", "R>W>E>Q", false)
EzrealMenu.Misc:Boolean("BaseUlt", "Use BaseUlt", true)
EzrealMenu.Misc:Boolean("AI", "Auto Ignite", true)
EzrealMenu.Misc:Boolean("AR", "Auto R On X Enemies", true)
EzrealMenu.Misc:Slider("ARC", "Min Enemies To Auto R",3,1,6,1)

EzrealMenu:SubMenu("Prediction", "Hit Chance")
EzrealMenu.Prediction:Slider("Q", "Q HitChance",30,0,100,1)
EzrealMenu.Prediction:Slider("W", "W HitChance",30,0,100,1)
EzrealMenu.Prediction:Slider("R", "R HitChance",30,0,100,1)

EzrealMenu:SubMenu("Draw", "Drawings")
EzrealMenu.Draw:Boolean("DAA", "Draw AA Range", true)
EzrealMenu.Draw:Boolean("DQ", "Draw Q Range", true)
EzrealMenu.Draw:Boolean("DW", "Draw W Range", true)
EzrealMenu.Draw:Boolean("DE", "Draw E Range", true)

EzrealMenu:SubMenu("Evade", "Evade")
EzrealMenu.Evade:Boolean("EE", "Use E", true)
EzrealMenu.Evade:Boolean("EA", "Annie R", true)
EzrealMenu.Evade:Boolean("EM", "Malphite R", true)
EzrealMenu.Evade:Boolean("ES", "Sona R", true)
EzrealMenu.Evade:Boolean("EO", "Oriana R", true)
EzrealMenu.Evade:Boolean("EL", "Leona R", true)

EzrealMenu:SubMenu("JCS", "Dragon and Baron Steal")
EzrealMenu.JCS:Boolean("JCS", "Steal Baron and Dragon", true)
EzrealMenu.JCS:KeyBinding("DBS", "Hold To Steal", string.byte("T"))

EzrealMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Ezreal"] = {"Classic", "Nottingham", "Striker", "Frosted", "Explorer", "PulseFire", "TPA", "Debonair", "Ace Of Spades"}}
EzrealMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
EzrealMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

function QDmg(unit) return CalcDamage(myHero, unit, 15 + 20 * GetCastLevel(myHero, _Q) + myHero.totalDamage *1.1 + GetBonusAP(myHero) * 0.4, 0) end
function WDmg(unit) return CalcDamage(myHero, unit, 0, 25 + 45 * GetCastLevel(myHero, _W) + (GetBonusAP(myHero) * 0.8)) end
function RDmg(unit) return CalcDamage(myHero, unit, 0, 150 + 200 * GetCastLevel(myHero, _R) + (GetBonusDmg(myHero)) + (GetBonusAP(myHero) * 0.9)) end
local target = GetCurrentTarget()
local QStats = {delay = 0.25, range = 1200, radius = 60, speed = 2000}
local RStats = {delay = 1, range = 20000, radius = 160, speed = 2000}
local WStats = {delay = 0.25, range = 1050, radius = 80, speed = 1600}
local Move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local EvadeSpot = nil
local CCType = {[5] = "Stun", [7] = "Silence", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local nextAttack = 0
local QSS = nil
local MercSkimm = nil

OnTick(function()

	target = GetCurrentTarget()
	EvadeSpot = myHero.pos + (GetMousePos() - myHero.pos):normalized() * 425
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local BORK = GetItemSlot(myHero, 3153)
	local Bilge = GetItemSlot(myHero, 3144)
	local Tear = GetItemSlot(myHero, 3070)
	local Manamune = GetItemSlot(myHero, 3004)
	local ArcStaff = GetItemSlot(myHero, 3003)
	QSS = GetItemSlot(myHero, 3140)
	MercSkimm = GetItemSlot(myHero, 3139)
	local movePos = GetPrediction(target,Move).castPos
		
--AutoLevel	
	if EzrealMenu.Misc.AL.UAL:Value() and EzrealMenu.Misc.AL.ALQEW:Value() then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	if EzrealMenu.Misc.AL.UAL:Value() and EzrealMenu.Misc.AL.ALQWE:Value() then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end	

	if EzrealMenu.Misc.AL.UAL:Value() and EzrealMenu.Misc.AL.ALQEW:Value() then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	if EzrealMenu.Misc.AL.UAL:Value() and EzrealMenu.Misc.AL.ALWQE:Value() then
		spellorder = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end	
	
	if EzrealMenu.Misc.AL.UAL:Value() and EzrealMenu.Misc.AL.ALWEQ:Value() then
		spellorder = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

--Combo	
	if Mix:Mode() == "Combo" then
		
		if EzrealMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 1200) and GetTickCount() > nextAttack then
			if GetPercentMP(myHero) >= EzrealMenu.Combo.CMM:Value() then
				local QPred = GetPrediction(target, QStats)
				if QPred.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) and not QPred:mCollision(1) then
					CastSkillShot(_Q, QPred.castPos)
				end
			end
		end

		if EzrealMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 1050) and GetTickCount() > nextAttack then
			if GetPercentMP(myHero) >= EzrealMenu.Combo.CMM:Value() then
				local WPred = GetLinearAOEPrediction(target, WStats)
				if WPred.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) then
					CastSkillShot(_W, WPred.castPos)
				end	
			end
		end

		if EzrealMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 2000) and GetDistance(myHero, target) > 800 and GetPercentHP(target) <= 55 and GetDistance(myHero, target) <= EzrealMenu.Misc.RC:Value() then
			if GetPercentMP(myHero) >= EzrealMenu.Combo.CMM:Value() then
				local RPred = GetLinearAOEPrediction(target, RStats)
				if RPred.hitChance >= (EzrealMenu.Prediction.R:Value() * 0.01) then
					CastSkillShot(_R, RPred.castPos)
				end
			end
		end
		
		if EzrealMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 85 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end
		
		if EzrealMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) > GetPercentHP(target) and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end		

		if EzrealMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) > GetPercentHP(target) and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end

		if EzrealMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) >= 90 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end
	end		

--Harass	
	if Mix:Mode() == "Harass" then
			
		if EzrealMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, 1200) and GetTickCount() > nextAttack then
			if GetPercentMP(myHero) >= EzrealMenu.Harass.HMM:Value() then
				local QPredH = GetPrediction(target, QStats)
				if QPredH.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) and not QPredH:mCollision(1) then
					CastSkillShot(_Q, QPredH.castPos)
				end
			end
		end
			
		if EzrealMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, 1050) and GetTickCount() > nextAttack then
			if GetPercentMP(myHero) >= EzrealMenu.Harass.HMM:Value() then
				local WPredH = GetLinearAOEPrediction(target, WStats)
				if WPredH.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) then
					CastSkillShot(_W, WPredH.castPos)
				end	
			end
		end
	end	
	
--LaneClear	
	if Mix:Mode() == "LaneClear" then
		
		for _, closeminion in pairs(minionManager.objects) do
			if EzrealMenu.LaneClear.LCQ:Value() and ValidTarget(closeminion, 1200) and GetTickCount() > nextAttack then
				if GetPercentMP(myHero) >= EzrealMenu.LaneClear.LCMM:Value() then
					CastSkillShot(_Q, closeminion)
				end
			end
			
			local RPredLC = GetLinearAOEPrediction(closeminion, RStats)
			local EndPosLC = GetOrigin(myHero) + (VectorWay(GetOrigin(myHero),RPredLC.castPos)/GetDistance(myHero,RPredLC.castPos)) * EzrealMenu.Misc.RC:Value()
			if EzrealMenu.LaneClear.LCR:Value() and ValidTarget(closeminion, 20000) and CountObjectsOnLineSegment(GetOrigin(myHero), EndPosLC, 160, minionManager.objects) >= EzrealMenu.LaneClear.LCRC:Value() then
				if GetPercentMP(myHero) >= EzrealMenu.LaneClear.LCMM:Value() and GetDistance(myHero, closeminion) > 1500 then
					if RPredLC.hitChance >= (EzrealMenu.Prediction.R:Value() * 0.01) then
						CastSkillShot(_R, RPredLC.castPos)
					end
				end
			end
		end
	end

--LastHit	
	if Mix:Mode() == "LastHit" then
		
		for _, closeminion in pairs(minionManager.objects) do
			if EzrealMenu.LastHit.LHQ:Value() and ValidTarget(closeminion, 1200) and GetDistance(myHero, closeminion) > 550 then
				if GetCurrentHP(closeminion) <= QDmg(closeminion) then
					local QPredLH = GetPrediction(closeminion, QStats)
					if QPredLH.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) and not QPredLH:mCollision(1) and not QPredLH:hCollision(1) then
						CastSkillShot(_Q, QPredLH.castPos)
					end
				end
			end
		end
	end

--KillSteal	
	for _, enemy in pairs(GetEnemyHeroes()) do
		if EzrealMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 1200) and IsObjectAlive(enemy) then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) <= QDmg(enemy) then
				local QPredKS = GetPrediction(enemy, QStats)
				if QPredKS.hitChance >= (EzrealMenu.Prediction.Q:Value() * 0.01) and not QPredKS:mCollision(1) and not QPredKS:hCollision(1) then
					CastSkillShot(_Q, QPredKS.castPos)
				end
			end
		end

		if EzrealMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 1050) and IsObjectAlive(enemy) then
			if GetCurrentHP(enemy) + GetMagicShield(enemy) <= WDmg(enemy) then
				local WPredKS = GetLinearAOEPrediction(enemy, WStats)
				if WPredKS.hitChance >= (EzrealMenu.Prediction.W:Value() * 0.01) then
					CastSkillShot(_W, WPredKS.castPos)
				end
			end
		end

		if EzrealMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, EzrealMenu.KillSteal.KSRC:Value()) and GetDistance(myHero, enemy) > 700 and IsObjectAlive(enemy) then
			if GetCurrentHP(enemy) + GetMagicShield(enemy) <= RDmg(enemy) then
				local RPredKS = GetLinearAOEPrediction(enemy, RStats)
				if RPredKS.hitChance >= (EzrealMenu.Prediction.R:Value() * 0.01) then
					CastSkillShot(_R, RPredKS.castPos)
				end
			end
		end

--Auto R
		if EzrealMenu.Misc.AR:Value() and Ready(_R) and ValidTarget(enemy, 20000) then
			local RPredAR = GetLinearAOEPrediction(enemy, RStats)
			local EndPos = GetOrigin(myHero) + (VectorWay(GetOrigin(myHero),RPredAR.castPos)/GetDistance(myHero,RPredAR.castPos)) * EzrealMenu.Misc.RC:Value()
			if CountObjectsOnLineSegment(GetOrigin(myHero), EndPos, 160, GetEnemyHeroes()) >= EzrealMenu.Misc.ARC:Value() then
				if RPredAR.hitChance >= (EzrealMenu.Prediction.R:Value() * 0.01) then
					CastSkillShot(_R, RPredAR.castPos)
				end
			end
		end
	
--Auto Ignite 
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if EzrealMenu.Misc.AI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if EzrealMenu.Misc.AI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end	
	
--Baron/Dragon Steal
	if EzrealMenu.JCS.DBS:Value() and EzrealMenu.JCS.JCS:Value() then
		MoveToXYZ(GetMousePos())
		for _, camp in pairs(minionManager.objects) do
			local RDragDmg = getdmg("R",camp,myHero,GetCastLevel(myHero, _R))
			if GetTeam(camp) == 300 and IsObjectAlive(camp) and GetObjectName(camp) == "SRU_Baron" or GetObjectName(camp):lower():find("sru_dragon") then
				if GetHealthPrediction(camp, 1 + (GetDistance(myHero, camp) / 2000)) < RDragDmg then
					CastSkillShot(_R, camp)
				end
			end
		end
	end
	
--Auto Harass
	if EzrealMenu.AH.AHQ:Value() and Ready(_Q) and ValidTarget(target, 1200) then
		if GetPercentMP(myHero) >= EzrealMenu.AH.AHC:Value() then
			if Mix:Mode() ~= "Combo" and Mix:Mode() ~= "Harass" and Mix:Mode() ~= "LaneClear" and Mix:Mode() ~= "LastHit" then
				local QPredAH = GetPrediction(target, QStats)
				if QPredAH.hitChance >= 0.3 and QPredAH:mCollision(1) then
					CastSkillShot(_Q, QPredAH.castPos)
				end
			end
		end
	end

	if EzrealMenu.AH.AHW:Value() and Ready(_W) and ValidTarget(target, 1050) then
		if GetPercentMP(myHero) >= EzrealMenu.AH.AHC:Value() then
			if Mix:Mode() ~= "Combo" and Mix:Mode() ~= "Harass" and Mix:Mode() ~= "LaneClear" and Mix:Mode() ~= "LastHit" then
				local WPredAH = GetLinearAOEPrediction(target, WStats)
				if WPredAH.hitChance >= 0.3 then
					CastSkillShot(_W, WPredAH.castPos)
				end
			end
		end
	end	
	
--Auto Stack Tear
	if EzrealMenu.Misc.TearS:Value() then
		if GetPercentMP(myHero) >= EzrealMenu.Misc.TearC:Value() and GetDistance(myHero, target) > 1200 then
			if Tear > 0 and CanUseSpell(myHero, Tear) ~= ON_COOLDOWN then
				if Mix:Mode() ~= "Combo" and Mix:Mode() ~= "Harass" and Mix:Mode() ~= "LastHit" then
					for _, closeminion in pairs(minionManager.objects) do
						if Ready(_Q) and ValidTarget(closeminion, 1200) then
							CastSkillShot(_Q, closeminion)
						end
					end		
				end	
			end			
		end
	end	
	
	if EzrealMenu.Misc.TearS:Value() then
		if GetPercentMP(myHero) >= EzrealMenu.Misc.TearC:Value() and GetDistance(myHero, target) > 1200 then
			if Manamune > 0 and CanUseSpell(myHero, Manamune) ~= ON_COOLDOWN then
				if Mix:Mode() ~= "Combo" and Mix:Mode() ~= "Harass" and Mix:Mode() ~= "LastHit" then
					for _, closeminion in pairs(minionManager.objects) do
						if Ready(_Q) and ValidTarget(closeminion, 1200) then
							CastSkillShot(_Q, closeminion)
						end
					end		
				end	
			end			
		end
	end

	if EzrealMenu.Misc.TearS:Value() then
		if GetPercentMP(myHero) >= EzrealMenu.Misc.TearC:Value() and GetDistance(myHero, target) > 1200 then
			if ArcStaff > 0 and CanUseSpell(myHero, ArcStaff) ~= ON_COOLDOWN then
				if Mix:Mode() ~= "Combo" and Mix:Mode() ~= "Harass" and Mix:Mode() ~= "LastHit" then
					for _, closeminion in pairs(minionManager.objects) do
						if Ready(_Q) and ValidTarget(closeminion, 1200) then
							CastSkillShot(_Q, closeminion)
						end
					end		
				end	
			end			
		end
	end		
end)			

OnUpdateBuff(function(unit, buff)
	if unit.isMe and CCType[buff.Type] and EzrealMenu.Misc.QSS:Value() and QSS > 0 and Ready(QSS) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(QSS)
		end	
	end
	
	if unit.isMe and CCType[buff.Type] and EzrealMenu.Misc.QSS:Value() and MercSkimm > 0 and Ready(MercSkimm) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(MercSkimm)
		end
	end	
end)

local spawn = nil
local arrivalTime = nil
local baseUnit = nil
local reduction = (1-(0.1 * CountObjectsOnLineSegment(GetOrigin(myHero), spawn, 160, minionManager.objects)))
		if reduction < 0.3 then
			reduction = 0.3
		end	

OnDraw(function()
	local pos = GetOrigin(myHero)
	if EzrealMenu.Draw.DQ:Value() then DrawCircle(pos, 1200, 1, 25, GoS.Red) end
	if EzrealMenu.Draw.DW:Value() then DrawCircle(pos, 1050, 1, 25, GoS.Blue) end
	if EzrealMenu.Draw.DAA:Value() then DrawCircle(pos, 550 + GetHitBox(myHero), 1, 25, GoS.White) end
	if EzrealMenu.Draw.DE:Value() then DrawCircle(pos, 475, 1, 25, GoS.Green) end
	
	if EzrealMenu.Misc.BaseUlt:Value() and arrivalTime ~= nil then
		local rTime = GetDistance(baseUnit.pos,spawn.pos)/2000+1
		if arrivalTime-rTime-GetGameTimer()-GetLatency()*.001 < 0 then
			if GetCurrentHP(baseUnit) < (RDmg(baseUnit) * reduction)  then
				CastSkillShot(_R,spawn.pos)
				arrivalTime = nil
				baseUnit = nil
			end	
		end
	end	
end)	

OnObjectLoad(function(object)
    if object.type == Obj_AI_SpawnPoint and object.team == 300 - myHero.team then
        spawn = object
    end
end)

OnProcessRecall(function(unit, recall)
	if recall.name ~= "recall" then return end
		if unit.team == 300 - GetTeam(myHero) then
			arrivalTime = GetGameTimer() + (recall.totalTime - recall.passedTime)*.001
			baseUnit = unit
				if arrivalTime > recall.totalTime + GetGameTimer() then
					arrivalTime = nil
				end
		end		
end)

OnProcessSpell(function(unit, spell)
    if unit.team ~= GetTeam(myHero) and spell.name:lower():find("infernalguardian") then
        if EzrealMenu.Evade.EA:Value() and GetDistance(myHero, spell.endPos) < 290 and Ready(_E) then
            CastSkillShot(_E, EvadeSpot)
        end
    end
   
    if unit.team ~= GetTeam(myHero) and spell.name:lower():find("sonar") then
        if EzrealMenu.Evade.ES:Value() and GetDistance(myHero, spell.endPos) < 290 and Ready(_E) then
            CastSkillShot(_E, EvadeSpot)
        end
    end
   
    if unit.team ~= GetTeam(myHero) and spell.name:lower():find("ufslash") then
        if EzrealMenu.Evade.EM:Value() and GetDistance(myHero, spell.endPos) < 150 and Ready(_E) then
            CastSkillShot(_E, EvadeSpot)
        end
    end

	if unit.team ~= GetTeam(myHero) and spell.name:lower():find("orianadetonatecommand") then
		if EzrealMenu.Evade.EO:Value() and GetDistance(myHero, spell.endPos) < 410 and Ready(_E) then
			CastSkillShot(_E, EvadeSpot)
		end
	end	

	if unit.team ~= GetTeam(myHero) and spell.name:lower():find("leonasolarflare") then
		if EzrealMenu.Evade.EL:Value() and GetDistance(myHero, spell.endPos) < 300 and Ready(_E) then
			CastSkillShot(_E, EvadeSpot)
		end
	end	

	if unit.isMe and spell.name:lower():find("attack") then
		nextAttack = GetTickCount() + spell.windUpTime * 1000
	end	
end)	

function VectorWay(A,B)
WayX = B.x - A.x
WayY = B.y - A.y
WayZ = B.z - A.z
return Vector(WayX, WayY, WayZ)
end

print("Thanks For Using Eternal Ezreal, Have Fun :)")
