if GetObjectName(GetMyHero()) ~= "Trundle" then return end
	
local ver = "0.02"

require("DamageLib")
require("OpenPredict")
require("ChallengerCommon")

if not FileExist(COMMON_PATH.. "Analytics.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Trundle", "Toshibiotro", true)

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalTrundle.lua", SCRIPT_PATH .. "EternalTrundle.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalTrundle.version", AutoUpdate)

local TrundleMenu = Menu("Trundle", "Trundle")
TrundleMenu:SubMenu("Combo", "Combo")
TrundleMenu.Combo:Boolean("CQ", "Use Q", true)
TrundleMenu.Combo:Boolean("CW", "Use W", true)		
TrundleMenu.Combo:Boolean("CE", "Use E", true)
TrundleMenu.Combo:Boolean("CR", "Use R", true)
TrundleMenu.Combo:Slider("CRC", "Min HP To Use R",80,1,100,1)
TrundleMenu.Combo:Slider("CRTC", "Min Target HP To Use R",60,1,100,1)
TrundleMenu.Combo:Slider("CC", "Min Mana To Combo",60,1,100,1)
TrundleMenu.Combo:Boolean("CTH", "Use T Hydra", true)
TrundleMenu.Combo:Boolean("CRH", "Use R Hydra", true)

TrundleMenu:SubMenu("Harass", "Harass")
TrundleMenu.Harass:Boolean("HQ", "Use Q", true)
TrundleMenu.Harass:Boolean("HW", "Use W", true)
TrundleMenu.Harass:Boolean("HE", "Use E", true)
TrundleMenu.Harass:Slider("HC", "Min Mana To Harass",60,1,100,1)
TrundleMenu.Harass:Boolean("HTH", "Use T Hydra", true)
TrundleMenu.Harass:Boolean("HRH", "Use R Hydra", true)

TrundleMenu:SubMenu("LaneClear", "LaneClear")
TrundleMenu.LaneClear:Boolean("LCQ", "Use Q", true)
TrundleMenu.LaneClear:Boolean("LCW", "Use W", true)
TrundleMenu.LaneClear:Slider("LCC", "Min Mana To LaneClear",60,1,100,1)
TrundleMenu.LaneClear:Boolean("LCTH", "Use T Hydra", true)
TrundleMenu.LaneClear:Boolean("LCRH", "Use R Hydra", true)

TrundleMenu:SubMenu("JungleClear", "JungleClear")
TrundleMenu.JungleClear:Boolean("JCQ", "Use Q", true)
TrundleMenu.JungleClear:Boolean("JCW", "Use W", true)
TrundleMenu.JungleClear:Slider("JCC", "Min Mana To JungleClear",60,1,100,1)
TrundleMenu.JungleClear:Boolean("JCTH", "Use T Hydra", true)
TrundleMenu.JungleClear:Boolean("JCRH", "Use R Hydra", true)

TrundleMenu:SubMenu("Misc", "Misc")
TrundleMenu.Misc:Boolean("AutoLevel", "AutoLevel", false)
TrundleMenu.Misc:Boolean("AR", "Auto R On X HP", true)
TrundleMenu.Misc:Slider("ARC", "Min HP To Auto R",20,1,100,1)

TrundleMenu:SubMenu("Draw", "Drawings")
TrundleMenu.Draw:Boolean("DAA", "Draw AA Range", true)
TrundleMenu.Draw:Boolean("DE", "Draw E Range", true)
TrundleMenu.Draw:Boolean("DEE", "Draw E Pos", true)
TrundleMenu.Draw:Boolean("DW", "Draw W Range", true)
TrundleMenu.Draw:Boolean("DWW", "Draw W Pos", true)
TrundleMenu.Draw:Boolean("DR", "Draw R Range", true)

TrundleMenu:SubMenu("AntiGapCloser", "AntiGapCloser")

TrundleMenu:SubMenu("Interrupter", "Interrupter")

TrundleMenu:SubMenu("Gapclose", "Gapclose")
TrundleMenu.Gapclose:Boolean("GCW", "Use W", true)
TrundleMenu.Gapclose:Boolean("GCE", "Use E", true)

TrundleMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Trundle"] = {"Classic", "Lil'Slugger", "Junkyard", "Traditional", "Constable"}}
TrundleMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
TrundleMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local target = GetCurrentTarget
local Move = { delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local EStats = { delay = 0.025, speed = math.huge, width = 225, range = 1000}	
local QDmg = nil
local nextAttack = 0
local AARange = 175 + GetHitBox(myHero)
local ERange = GetCastRange(myHero, _E) + GetHitBox(myHero)
local WRange = GetCastRange(myHero, _W) + GetHitBox(myHero)
local RRange = GetCastRange(myHero, _R) + GetHitBox(myHero)

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

function ResetAA()
    if _G.IOW_Loaded then
        return IOW:ResetAA()
        elseif _G.PW_Loaded then
        return PW:ResetAA()
        elseif _G.DAC_Loaded then
        return DAC:ResetAA()
        elseif _G.AutoCarry_Loaded then
        return DACR:ResetAA()
        elseif _G.SLW_Loaded then
        return SLW:ResetAA()
    end
end

OnTick(function()

	local target = GetCurrentTarget()
	local movePos = GetPrediction(target,Move).castPos
	QDmg = getdmg("Q",target,myHero,GetCastLevel(myHero, _Q))
	local TH = GetItemSlot(myHero, 3748)
	local T = GetItemSlot(myHero, 3077)
	local RH = GetItemSlot(myHero, 3074)

	if TrundleMenu.Misc.AutoLevel:Value() then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	--Combo
	if Mode() == "Combo" then
	
		if TrundleMenu.Combo.CW:Value() and GetPercentMP(myHero) >= TrundleMenu.Combo.CC:Value() then
			if Ready(_W) and ValidTarget(target, 380) then
				CastSkillShot(_W, target)
			end	
		end	

		if TrundleMenu.Combo.CE:Value() and GetPercentMP(myHero) >= TrundleMenu.Combo.CC:Value() then
			if Ready(_E) and ValidTarget(target, 1000) and GetDistance(movePos) > GetDistance(target) then
				if GetDistance(myHero, target) >= 300 then
					local EPredE = GetCircularAOEPrediction(target, EStats)
					CastSkillShot(_E, EPredE.castPos)
				end
			end
		end
		
		if TrundleMenu.Combo.CR:Value() and GetPercentMP(myHero) >= TrundleMenu.Combo.CC:Value()then
			if Ready(_R) and ValidTarget(target, 400) and GetPercentHP(myHero) <= TrundleMenu.Combo.CRC:Value() and GetCurrentHP(target) >= TrundleMenu.Combo.CRTC:Value() then 
				CastTargetSpell(target, _R)
			end	
		end
	end	
	
	--Harass
	if Mode() == "Harass" then
	
		if TrundleMenu.Harass.HW:Value() and GetPercentMP(myHero) >= TrundleMenu.Harass.HC:Value() then
			if Ready(_W) and ValidTarget(target, 300) then
				CastSkillShot(_W, target)
			end	
		end	

		if TrundleMenu.Harass.HE:Value() and GetPercentMP(myHero) >= TrundleMenu.Harass.HC:Value() then
			if Ready(_E) and ValidTarget(target, 1000) and GetDistance(movePos) > GetDistance(target) then
				if GetDistance(myHero, target) >= 300 then
					local EPredE = GetCircularAOEPrediction(target, EStats)
					CastSkillShot(_E, EPredE.castPos)
				end
			end
		end
	end
	
	--LaneClear
	if Mode() == "LaneClear" then
		if GetPercentMP(myHero) >= TrundleMenu.LaneClear.LCC:Value() then
			if TrundleMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 400, MINION_ENEMY) > 2 then
				CastSkillShot(_W, myHero)
			end	
		end
	end	

	--JungleClear
	if Mode() == "LaneClear" then
		if GetPercentMP(myHero) >= TrundleMenu.JungleClear.JCC:Value() then
			if TrundleMenu.JungleClear.JCW:Value() and Ready(_W) and MinionsAround(myHero, 300, MINION_JUNGLE) > 0 then
				CastSkillShot(_W, myHero)
			end
		end			
	
		if TrundleMenu.JungleClear.JCRH:Value() and RH > 0 and Ready(RH) then
			if MinionsAround(myHero, 400, MINION_JUNGLE) > 0 then
				if nextAttack < GetTickCount() then
					CastSpell(RH)
				end
			end		
		end
		
		if TrundleMenu.JungleClear.JCRH:Value() and T > 0 and Ready(T) then
			if MinionsAround(myHero, 400, MINION_JUNGLE) > 0 then
				if nextAttack < GetTickCount() then
					CastSpell(T)
				end
			end		
		end
	end
	
	--AutoR
	if TrundleMenu.Misc.AR:Value() and Ready(_R) and ValidTarget(target, 700) then
		if GetPercentHP(myHero) <= TrundleMenu.Misc.ARC:Value() then
			CastTargetSpell(target, _R)
		end
	end
	
	-- Gapclose
	if Mode() == "Combo" then	
		if TrundleMenu.Gapclose.GCW:Value() and Ready(_W) and ValidTarget(target, 1000) then
			if GetDistance(myHero, target) > 340 and GetDistance(myHero, target) < 1000 and GetDistance(movePos) > GetDistance(target) then
				CastSkillShot(_W, target)
			end	
		end
	
		if TrundleMenu.Gapclose.GCE:Value() and Ready(_E) and ValidTarget(target, 1000) then
			if GetDistance(myHero, target) > 360 and GetDistance(myHero, Target) < 800 and GetDistance(movePos) > GetDistance(target) then
				local EPredE = GetCircularAOEPrediction(target, EStats)
				CastSkillShot(_E, EPredE.castPos)
			end
		end		
	end	
end)

OnDraw(function()
	if TrundleMenu.Draw.DW:Value() then DrawCircle(myHero, WRange, 1, 25, GoS.Red) end
	if TrundleMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 1, 25, GoS.Cyan) end
	if TrundleMenu.Draw.DWW:Value() and GetDistance(myHero, GetMousePos()) <= WRange then DrawCircle(GetMousePos(), 1000, 1, 25, GoS.White) end
	if TrundleMenu.Draw.DEE:Value() and GetDistance(myHero, GetMousePos()) <= ERange then DrawCircle(GetMousePos(), 225, 1, 25, GoS.White) end
	if TrundleMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 1, 25, GoS.White) end
	if TrundleMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 1, 25, GoS.Blue) end
end)	

OnProcessSpellComplete(function(unit,spell)
	local target = GetCurrentTarget()
	local RH = GetItemSlot(myHero, 3074)
	local TH = GetItemSlot(myHero, 3748)
	local T = GetItemSlot(myHero, 3077)
	
	if TrundleMenu.Combo.CTH:Value() and unit.isMe and spell.name:lower():find("trundleq") and spell.target.isHero then
		if Mode() == "Combo" then
			local TH = GetItemSlot(myHero, 3748)
			if TH > 0 then 
				if Ready(TH) and GetCurrentHP(target) > CalcDamage(myHero, target, myHero.totalDamage + (GetMaxHP(myHero) / 10), 0) then
					CastSpell(TH)
					DelayAction(function()
						AttackUnit(spell.target)
					end, spell.windUpTime)
				end
			end
		end
	end
	
	if TrundleMenu.Combo.CTH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero and not Ready(_Q) then
		if Mode() == "Combo" then
			if TH > 0 then 
				if Ready(TH) and GetCurrentHP(target) > CalcDamage(myHero, target, myHero.totalDamage + (GetMaxHP(myHero) / 10), 0) then
					CastSpell(TH)
					DelayAction(function()
						AttackUnit(spell.target)
					end, spell.windUpTime)
				end
			end
		end
	end
	
	if TrundleMenu.Combo.CQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mode() == "Combo" then
			if Ready(_Q) and GetCurrentHP(target) > QDmg then
				CastSpell(_Q)
				DelayAction(function()
					AttackUnit(spell.target)
				end, spell.windUpTime)
			end
		end
	end
	
	if TrundleMenu.Combo.CRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mode() == "Combo" then
			if T > 0 then 
				if Ready(T) then
					CastSpell(T)
				end
			end
		end
	end	
	
	if TrundleMenu.Combo.CRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mode() == "Combo" then
			if RH > 0 then 
				if Ready(RH) then
					CastSpell(RH)
				end
			end
		end
	end

	if TrundleMenu.LaneClear.LCQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mode() == "LaneClear" then
			if Ready(_Q) then
				CastSpell(_Q)
			end
		end	
	end
	
	if TrundleMenu.LaneClear.LCRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mode() == "LaneClear" then
			if RH > 0 then
				if Ready(RH) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(RH)
				end	
			end	
		end
	end
	
	if TrundleMenu.LaneClear.LCRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion and spell.target.team == 300 - GetTeam(myHero) then
		if Mode() == "LaneClear" then
			if T > 0 then
				if Ready(T) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(T)
				end
			end
		end
	end	
	
	if TrundleMenu.JungleClear.JCQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.team == 300 then
		if Mode() == "LaneClear" then
			if GetPercentMP(myHero) >= TrundleMenu.JungleClear.JCC:Value() and Ready(_Q) then
				CastSpell(_Q)
			end	
		end
	end

	if TrundleMenu.JungleClear.JCTH:Value() and unit.isMe and spell.name:lower():find("trundleq") and spell.target.team == 300 then
		if Mode() == "LaneClear" then
			if TH > 0 and Ready(TH) then
				CastSpell(TH)
			end
		end
	end		
end)	

OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("tiamatcleave") then
		ResetAA()
	end
end)	

OnProcessSpell(function(unit,spellProc)
	if unit.isMe and spellProc.name:lower():find("attack") and spellProc.target.isHero then
		nextAttack = GetTickCount() + spellProc.windUpTime * 1000
	end
end)	

OnLoad(function()
	ChallengerCommon.Interrupter(TrundleMenu.Interrupter, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange then
			CastSkillShot(_E, unit)
		end
	end)
	
	ChallengerCommon.AntiGapcloser(TrundleMenu.AntiGapCloser, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange then
			local IQPred = GetPrediction(unit, EStats)
			if IQPred.hitChance >= 0.1 then
				CastSkillShot(_E, IQPred.castPos)
			end	
		end	
	end)
end)
