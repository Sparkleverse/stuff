if GetObjectName(myHero) ~= "Draven" then return end

local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalDraven.lua", SCRIPT_PATH .. "EternalDraven.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalDraven.version", AutoUpdate)

require ("OpenPredict")
require ("ChallengerCommon")

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Draven", "Toshibiotro", true)

local DravenMenu = Menu("Draven", "Draven")
DravenMenu:SubMenu("Combo", "Combo")
DravenMenu.Combo:Boolean("CQ", "Use Q", true)
DravenMenu.Combo:Boolean("CW", "Use W", true)
DravenMenu.Combo:Boolean("CE", "Use E", true)
DravenMenu.Combo:Boolean("CR", "Use R", true)
DravenMenu.Combo:Slider("CMM", "Min Mana To Combo", 20, 0, 100, 1)
DravenMenu.Combo:Boolean("CYGB", "Use GhostBlade", true)

DravenMenu:SubMenu("Harass", "Harass")
DravenMenu.Harass:Boolean("HQ", "Use Q", true)
DravenMenu.Harass:Boolean("HW", "Use W", true)
DravenMenu.Harass:Boolean("HE", "Use E", true)
DravenMenu.Harass:Slider("HMM", "Min Mana To Harass", 50, 0, 100, 1)

DravenMenu:SubMenu("LaneClear", "LaneClear")
DravenMenu.LaneClear:Boolean("LCQ", "Use Q", true)
DravenMenu.LaneClear:Boolean("LCW", "Use W", true)
DravenMenu.LaneClear:Boolean("LCE", "Use E", true)
DravenMenu.LaneClear:Slider("LCMM", "Min Mana To LaneClear", 50, 0 , 100, 1)

DravenMenu:SubMenu("LastHit", "LastHit")
DravenMenu.LastHit:Boolean("LHQ", "Use Q", true)
DravenMenu.LastHit:Boolean("LHE", "Use E", true)
DravenMenu.LastHit:Slider("LHMM", "Min Mana To LastHit", 20, 0, 100, 1)

DravenMenu:SubMenu("JungleClear", "JungleClear")
DravenMenu.JungleClear:Boolean("JCQ", "Use Q", true)
DravenMenu.JungleClear:Boolean("JCW", "Use W", true)
DravenMenu.JungleClear:Boolean("JCE", "Use E", true)
DravenMenu.JungleClear:Slider("JCMM", "Min Mana To Jungle", 50, 0, 100, 1)

DravenMenu:SubMenu("KillSteal", "KillSteal")
DravenMenu.KillSteal:Boolean("KSE", "Use E", true)
DravenMenu.KillSteal:Boolean("KSR", "Use R", true)
DravenMenu.KillSteal:Slider("KSRC", "Range To KS with R", 5000, 0, 25000, 100)

DravenMenu:SubMenu("Misc", "Misc")
DravenMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
DravenMenu.Misc:Boolean("AI", "Auto Ignite", true)
DravenMenu.Misc:Boolean("QSS", "Auto QSS", true)
DravenMenu.Misc:Slider("QSSC", "HP To QSS", 90, 0, 100, 1)
DravenMenu.Misc:Boolean("AR", "Auto R On X Enemies", true)
DravenMenu.Misc:Slider("ARC", "Min Enemies To Auto R", 3, 0, 6, 1)
DravenMenu.Misc:Boolean("AC", "Auto Catch Axes", true)
DravenMenu.Misc:Boolean("AWS", "Auto W On Slows", true)

DravenMenu:SubMenu("Interrupter", "Interrupter")

DravenMenu:SubMenu("AntiGapCloser", "AntiGapCloser")

DravenMenu:SubMenu("Draw", "Drawings")
DravenMenu.Draw:Boolean("DAA", "Draw AA Range", true)
DravenMenu.Draw:Boolean("DE", "Draw E Range", true)
DravenMenu.Draw:Boolean("DR", "Draw KS R Range", true)
DravenMenu.Draw:Boolean("DAP", "Draw Axe Pos", true)
DravenMenu.Draw:Boolean("DD", "Draw Damage", true)

DravenMenu:SubMenu("SkinChanger", "SkinChanger")

local skin= {["Draven"] = {"Classic", "Soul Reaver", "Gladiator", "PrimeTime", "PoolParty", "BeastHunter", "Draven Draven"}}
DravenMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skin[myHero.charName], HeroSkinChanger, true)
DravenMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skin[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local Axe = 0
local target = nil
local CatchPos = {}
local AARange = GetRange(myHero) + GetHitBox(myHero)*2
local ERange = GetCastRange(myHero, _E) + GetHitBox(myHero)
function EDmg(unit) return CalcDamage(myHero, unit, (35 + 35 * GetCastLevel(myHero, _E)) + (GetBonusDmg(myHero) * 0.5), 0) end
function RDmg(unit) return CalcDamage(myHero, unit, (75 + 100 * GetCastLevel(myHero, _R)) + (GetBonusDmg(myHero) * 1.1), 0) end
function QDmg(unit) return CalcDamage(myHero, unit, (myHero.totalDamage + (myHero.totalDamage * (0.35 + 0.1 * GetCastLevel(myHero, _Q)))), 0) end
local EStats = {delay = 0.25, range = ERange, radius = 130, speed = 1400}
local RStats = {delay = 0.5, range = math.huge, radius = 160, speed = 2000}
local Move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local CCType = {[5] = "Stun", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") or nil))
local ulton = false
local Blob = false

function Mode()
    if _G.IOW_Loaded and IOW:Mode() then
        return IOW:Mode()
        elseif _G.PW_Loaded and PW:Mode() then
        return PW:Mode()
        elseif _G.DAC_Loaded and DAC:Mode() then
        return DAC:Mode()
        elseif _G.AutoCarry_Loaded and DACR:Mode() then
        return DACR:Mode()
        elseif _G.SLW_Loaded and SLW:Mode() then
        return SLW:Mode()
    end
end

function ForcePos(Pos)
    if _G.IOW_Loaded then IOW.forcePos = Pos
        elseif _G.DAC_Loaded then DAC.forcePos = Pos
        elseif _G.PW_Loaded then PW.forcePos = Pos
        elseif _G.AutoCarry_Loaded then DACR.forcePos = Pos
        elseif _G.SLW_Loaded then SLW.forcePos = Pos  
    end
end  

OnTick(function()
	
	local ulton = GetCastName(myHero, _R):lower():find("dravenrcast")
	target = GetCurrentTarget()
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local movePos = GetPrediction(target, Move)

	--AutoLevel
	if DravenMenu.Misc.AutoLevel:Value() == 2 then spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
	elseif DravenMenu.Misc.AutoLevel:Value() == 3 then spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
	elseif DravenMenu.Misc.AutoLevel:Value() == 4 then spellorder = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
	elseif DravenMenu.Misc.AutoLevel:Value() == 5 then spellorder = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
	elseif DravenMenu.Misc.AutoLevel:Value() == 6 then spellorder = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
	elseif DravenMenu.Misc.AutoLevel:Value() == 7 then spellorder = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
	end	
	
	if DravenMenu.Misc.AutoLevel:Value() ~= 1 and GetLevelPoints(myHero) > 0 then
		LevelSpell(spellorder[GetLevel(myHero)])
	end
	
	if Blob == true and not isWindingUp then MoveToXYZ(GetMousePos()) end
	
	-- Auto Catch Axe
	local closest = math.huge
	local bestAxe = nil
	local bestAxePos = nil
	for _, axes in pairs(CatchPos) do
		if DravenMenu.Misc.AC:Value() and axes and Axe < 2 then
			if GetDistance(axes) < closest then
				closest = GetDistance(axes)
				bestAxe = axes
				Blop = Vector(bestAxe)
				bestAxePos = Blop + (Blop - myHero.pos):normalized() * 100
			end
        end
    end
	ForcePos(bestAxePos)
	
	-- Combo
	if Mode() == "Combo" then
		if DravenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, AARange) and Axe < 2 then
			if GetPercentMP(myHero) >= DravenMenu.Combo.CMM:Value() then
				CastSpell(_Q)
			end
		end

		if DravenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, AARange) then
			if GetPercentMP(myHero) >= DravenMenu.Combo.CMM:Value() then
				CastSpell(_W)
			end	
		end
		
		if DravenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) and GetDistance(myHero, target) > AARange and GetDistance(target) < GetDistance(movePos.castPos) then
			if GetPercentMP(myHero) >= DravenMenu.Combo.CMM:Value() then
				local ESpot = GetLinearAOEPrediction(target, EStats)
				if ESpot.hitChance >= 0.2 and isWindingUp == false then
					CastSkillShot(_E, ESpot.castPos)
				end
			end		
		end
		
		if DravenMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, ERange) and GetDistance(myHero, target) > AARange and GetDistance(target) > GetDistance(movePos.castPos) then
			if GetPercentMP(myHero) >= DravenMenu.Combo.CMM:Value() and GetPercentHP(target) <= 50 and GetPercentHP(myHero) >= 15 then
				local RSpot = GetLinearAOEPrediction(target, RStats)
				if RSpot.hitChance >= 0.3 and isWindingUp == false and not ulton then
					CastSkillShot(_R, RSpot.castPos)
				end
			end		
		end
		
		if DravenMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 25000) and GetDistance(myHero, target) <= ERange and GetDistance(movePos) <= GetDistance(target) then
			if GetPercentMP(myHero) >= DravenMenu.Combo.CMM:Value() and GetPercentHP(target) <= 75 and GetPercentHP(myHero) >= 15 then
				local RSpot2 = GetLinearAOEPrediction(target, RStats)
				if RSpot2.hitChance >= 0.2 and isWindingUp == false and not ulton then
					CastSkillShot(_R, RSpot2.castPos)
				end	
			end
		end		
	end
	
	-- Harass
	if Mode() == "Harass" then
		if DravenMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, AARange) then
			if GetPercentMP(myHero) >= DravenMenu.Harass.HMM:Value() then
				CastSpell(_Q)
			end	
		end

		if DravenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, AARange) then
			if GetPercentMP(myHero) >= DravenMenu.Harass.HMM:Value() then
				CastSpell(_W)
			end	
		end
		
		if DravenMenu.Harass.HQ:Value() and Ready(_E) and ValidTarget(target, ERange) and GetDistance(myHero, target) >= AARange and GetDistance(target) < GetDistance(movePos.castPos) then
			if GetPercentMP(myHero) >= DravenMenu.Harass.HMM:Value() then
				local HESpot = GetLinearAOEPrediction(target, EStats)
				if HESpot.hitChance >= 0.2 and isWindingUp == false then
					CastSkillShot(_E, HESpot.castPos)
				end	
			end
		end		
	end

	-- LaneClear
	if Mode() == "LaneClear" then
		for _,minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if DravenMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(minion, AARange) and Axe < 2 then
					if GetPercentMP(myHero) >= DravenMenu.LaneClear.LCMM:Value() then
						CastSpell(_Q)
					end
				end
				
				if DravenMenu.LaneClear.LCW:Value() and Ready(_W) and ValidTarget(minion, AARange) then
					if GetPercentMP(myHero) >= DravenMenu.LaneClear.LCMM:Value() then
						CastSpell(_W)
					end	
				end

				if DravenMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
					if GetPercentMP(myHero) >= DravenMenu.LaneClear.LCMM:Value() then
						local LCESpot = GetLinearAOEPrediction(minion, EStats)
						local LCEndPos = LCESpot.castPos + (LCESpot.castPos - myHero.pos):normalized() * ERange
						if LCESpot.hitChance >= 0.1 and CountObjectsOnLineSegment(myHero, LCEndPos, 130, minionManager.objects, MINION_ENEMY) > 2 and isWindingUp == false then
							CastSkillShot(_E, LCESpot.castPos)
						end
					end		
				end	
			end

			if GetTeam(minion) == MINION_JUNGLE then
				if DravenMenu.JungleClear.JCQ:Value() and Ready(_Q) and ValidTarget(minion, AARange) and Axe < 2 then
					if GetPercentMP(myHero) >= DravenMenu.JungleClear.JCMM:Value() then
						CastSpell(_Q)
					end
				end
				
				if DravenMenu.JungleClear.JCW:Value() and Ready(_W) and ValidTarget(minion, AARange) then
					if GetPercentMP(myHero) >= DravenMenu.JungleClear.JCMM:Value() then
						CastSpell(_W)
					end
				end
			end		
		end		
	end
	
	-- LastHit
	if Mode() == "LastHit" then
		for _,lhminion in pairs(minionManager.objects) do
			if GetTeam(lhminion) == MINION_ENEMY then
				if DravenMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(lhminion, ERange) and Axe < 2 then
					if GetPercentMP(myHero) >= DravenMenu.LastHit.LHMM:Value() then
						CastSpell(_Q)
					end
				end
		
				if DravenMenu.LastHit.LHE:Value() and Ready(_E) and ValidTarget(lhminion, ERange) and GetDistance(myHero, lhminion) > AARange then
					if GetPercentMP(myHero) >= DravenMenu.LastHit.LHMM:Value() then
						if GetCurrentHP(lhminion) <= EDmg(lhminion) then
							CastSkillShot(_E, lhminion)
						end
					end
				end
			end
		end
	end		

	--KillSteal
	for _,enemy in pairs(GetEnemyHeroes()) do
		local reduction = (1-(0.08 * CountObjectsOnLineSegment(myHero, enemy, 160, minionManager.objects, MINION_ENEMY)))
		if reduction < 0.4 then
			reduction = 0.4
		end
		
		if DravenMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, ERange) and GetDistance(myHero, enemy) > AARange then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) <= EDmg(enemy) then
				local KSEPos = GetLinearAOEPrediction(enemy, EStats)
				if KSEPos.hitChance >= 0.1 and isWindingUp == false then
					CastSkillShot(_E, KSEPos.castPos)
				end
			end		
		end
		
		if DravenMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, DravenMenu.KillSteal.KSRC:Value()) and GetDistance(myHero, enemy) > AARange then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) <= RDmg(enemy) * reduction then
				local KSRPos = GetLinearAOEPrediction(enemy, RStats)
				if KSRPos.hitChance >= 0.3 and not ulton then
					CastSkillShot(_R, KSRPos.castPos)
				end				
			end
		end

		-- Auto R
		if DravenMenu.Misc.AR:Value() and Ready(_R) and ValidTarget(enemy, 25000) then
			local RPredAR = GetLinearAOEPrediction(enemy, RStats)
			local EndPos = myHero.pos + (myHero.pos - RPredAR.castPos):normalized() * 25000
			if CountObjectsOnLineSegment(myHero, EndPos, 160, GetEnemyHeroes()) >= DravenMenu.Misc.ARC:Value() then
				if RPredAR.hitChance >= 0.2 and not ulton then
					CastSkillShot(_R, RPredAR.castPos)
				end	
			end
		end		
	
		-- Auto Ignite
		if DravenMenu.Misc.AI:Value() and Ignite ~= nil and Ready(Ignite) and ValidTarget(enemy, 600) then
			if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) <= IDamage then
				CastTargetSpell(Ignite, enemy)
			end	
		end
	end	
end)

--Auto QSS
OnUpdateBuff(function(unit, buff)
	local QSS = GetItemSlot(myHero, 3140)
	local MercSkimm = GetItemSlot(myHero, 3139)
	if unit.isMe and CCType[buff.Type] and DravenMenu.Misc.QSS:Value() and EnemiesAround(myHero, 900) > 0 and GetPercentHP(myHero) <= DravenMenu.Misc.QSSC:Value() then
		if QSS > 0 and Ready(QSS) then
			CastSpell(QSS)
			elseif MercSkimm > 0 and Ready(MercSkimm) then
			CastSpell(MercSkimm)
		end
	end	

	if unit.isMe and buff.Name == "DravenSpinningAttack" then
		Axe = buff.Count
	end

	if DravenMenu.Misc.AWS:Value() and unit.isMe and buff.Type == 10 and Ready(_W) then
		CastSpell(_W)
	end	
end)

OnRemoveBuff(function(unit, buff)
	if unit.isMe and buff.Name == "DravenSpinningAttack" then
		Axe = 0
	end
end)	

OnCreateObj(function(object)
	if object.name:lower():find("draven") and object.name:lower():find("_q_reticle_self") then
		table.insert(CatchPos, object.pos)
	end
end)	

OnDeleteObj(function(object)
	if object.name:lower():find("draven") and object.name:lower():find("_q_reticle_self") then
		table.remove(CatchPos, 1)
	end
end)

OnLoad(function()
	ChallengerCommon.Interrupter(DravenMenu.Interrupter, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange then
			local IPred = GetLinearAOEPrediction(unit, EStats)
			if IPred.hitChance >= 0.1 then
				CastSkillShot(_E, IPred.castPos)
			end	
		end
	end)
	
	ChallengerCommon.AntiGapcloser(DravenMenu.AntiGapCloser, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange then
			local AGPred = GetLinearAOEPrediction(unit, EStats)
			if AGPred.hitChance >= 0.1 then
				CastSkillShot(_E, AGPred.castPos)
			end	
		end	
	end)
end)

OnDraw(function()
	if DravenMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 1, 25, GoS.White) end
	if DravenMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 1, 25, GoS.Cyan) end
	if DravenMenu.Draw.DR:Value() then DrawCircle(myHero, DravenMenu.KillSteal.KSRC:Value(), 1, 25, GoS.Red) end
		
	for _, enemies in pairs(GetEnemyHeroes()) do
		if DravenMenu.Draw.DD:Value() then
			if Axe > 0 and not Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (QDmg(enemies) * Axe), 0, GoS.White)
				elseif Axe > 0 and Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (QDmg(enemies) * Axe) + EDmg(enemies), 0, GoS.White)
				elseif Axe > 0 and not Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (QDmg(enemies) * Axe) + (RDmg(enemies) * 2), 0, GoS.White)
				elseif Axe > 0 and Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (QDmg(enemies) * Axe) + EDmg(enemies) + (RDmg(enemies) * 2), 0, GoS.White)
				elseif Axe == 0 and Ready(_E) and not Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), EDmg(enemies) + (RDmg(enemies) * 2), 0, GoS.White)
				elseif Axe == 0 and not Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (RDmg(enemies) * 2), 0, GoS.White)
				elseif Axe == 0 and Ready(_E) and Ready(_R) then DrawDmgOverHpBar(enemies, GetCurrentHP(enemies), (RDmg(enemies) * 2) + EDmg(enemies), 0, GoS.White)
			end
		end	
	end
	
	for _, axes in pairs(CatchPos) do
		if DravenMenu.Draw.DAP:Value() and axes then DrawCircle(axes, 100, 1, 50, GoS.White) end
	end
end)

OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") then
		isWindingUp = true
	end
	
	if Mode() == "Combo" then
		if unit.isHero and spell.name:lower():find("attack") and spell.target.isMe then
			if DravenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(unit, ERange) then
				local EPred = GetLinearAOEPrediction(unit, EStats)
				if EPred.hitChance >= 0.1 and isWindingUp == false then
					CastSkillShot(_E, EPred.castPos)
				end
			end		
		end
	end
	
	if Mode() == "Harass" then
		if unit.isHero and spell.name:lower():find("attack") and spell.target.isMe then
			if DravenMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(unit, ERange) then
				local EPred2 = GetLinearAOEPrediction(unit, EStats)
				if EPred2.hitChance >= 0.1 and isWindingUp == false then
					CastSkillShot(_E, EPred2.castPos)
				end
			end		
		end
	end
	
	if Mode() == "LaneClear" then
		if unit.team == MINION_JUNGLE and spell.name:lower():find("attack") and spell.target.isMe and not GetObjectName(unit):lower():find("mini") and not GetObjectName(unit):lower():find("dragon") and not GetObjectName(unit):lower():find("baron") then
			local EPredJ = GetLinearAOEPrediction(unit, EStats)
			DelayAction(function()
				if EPredJ.hitChance >= 0.1 and isWindingUp == false then
					CastSkillShot(_E, EPredJ.castPos)
				end
			end, spell.windUpTime / 1.5)
		end
	end		
end)

OnProcessSpellComplete(function(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") then
		isWindingUp = false
	end
	
	if unit.isMe and spell.name:lower():find("dravenspinningattack") then
		ForcePos(nil)
		Blob = true
		DelayAction(function()
			Blob = false
		end, spell.windUpTime)	
	end	
end)	

OnAnimation(function(unit, animation)
	if unit.isMe and isWindingUp and animation:lower():find("run") or animation:lower():find("idle") then
		isWindingUp = false
	end	
end)

print("Thanks For Using Eternal Draven, Have Fun " ..GetUser().. " :)")	
