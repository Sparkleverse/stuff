if GetObjectName(GetMyHero()) ~= "Trundle" then return end
	
local ver = "0.01"

require("DamageLib")
require("OpenPredict")

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

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

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

TrundleMenu:SubMenu("AntiGapclose", "AntiGapclose")
TrundleMenu.AntiGapclose:Boolean("AGE", "Use E", true)

TrundleMenu:SubMenu("Gapclose", "Gapclose")
TrundleMenu.Gapclose:Boolean("GCW", "Use W", true)
TrundleMenu.Gapclose:Boolean("GCE", "Use E", true)

TrundleMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Trundle"] = {"Classic", "Lil'Slugger", "Junkyard", "Traditional", "Constable"}}
TrundleMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
TrundleMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local target = GetCurrentTarget
local Move = { delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local EStats = { delay = 0.4, speed = math.huge, width = 225, range = 1000}
local QDmg = nil
local nextAttack = 0

OnTick(function()

	local target = GetCurrentTarget()
	local backspot = target.pos + (myHero.pos - target.pos):normalized() * -200
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
	if Mix:Mode() == "Combo" then
	
		if TrundleMenu.Combo.CW:Value() and GetPercentMP(myHero) >= TrundleMenu.Combo.CC:Value() then
			if Ready(_W) and ValidTarget(target, 380) then
				CastSkillShot(_W, target)
			end	
		end	

		if TrundleMenu.Combo.CE:Value() and GetPercentMP(myHero) >= TrundleMenu.Combo.CC:Value() then
			if Ready(_E) and ValidTarget(target, 1000) and GetDistance(movePos) > GetDistance(target) then
				if GetDistance(myHero, target) >= 300 then
					CastSkillShot(_E, backspot)
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
	if Mix:Mode() == "Harass" then
	
		if TrundleMenu.Harass.HW:Value() and GetPercentMP(myHero) >= TrundleMenu.Harass.HC:Value() then
			if Ready(_W) and ValidTarget(target, 300) then
				CastSkillShot(_W, target)
			end	
		end	

		if TrundleMenu.Harass.HE:Value() and GetPercentMP(myHero) >= TrundleMenu.Harass.HC:Value() then
			if Ready(_E) and ValidTarget(target, 1000) and GetDistance(movePos) > GetDistance(target) then
				if GetDistance(myHero, target) >= 300 then
					CastSkillShot(_E, backspot)
				end
			end
		end
	end
	
	--LaneClear
	if Mix:Mode() == "LaneClear" then
		if GetPercentMP(myHero) >= TrundleMenu.LaneClear.LCC:Value() then
			if TrundleMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 400, MINION_ENEMY) > 2 then
				CastSkillShot(_W, myHero)
			end	
		end
	end	

	--JungleClear
	if Mix:Mode() == "LaneClear" then
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
	if Mix:Mode() == "Combo" then	
		if TrundleMenu.Gapclose.GCW:Value() and Ready(_W) and ValidTarget(target, 1000) then
			if GetDistance(myHero, target) > 340 and GetDistance(myHero, target) < 1000 and GetDistance(movePos) > GetDistance(target) then
				CastSkillShot(_W, target)
			end	
		end
	
		if TrundleMenu.Gapclose.GCE:Value() and Ready(_E) and ValidTarget(target, 1000) then
			if GetDistance(myHero, target) > 360 and GetDistance(myHero, Target) < 800 and GetDistance(movePos) > GetDistance(target) then
				CastSkillShot(_E, backspot)
			end
		end		
	end	
end)

OnProcessSpellComplete(function(unit,spell)
	local target = GetCurrentTarget()
	local RH = GetItemSlot(myHero, 3074)
	local TH = GetItemSlot(myHero, 3748)
	local T = GetItemSlot(myHero, 3077)
	
	if TrundleMenu.Combo.CTH:Value() and unit.isMe and spell.name:lower():find("trundleq") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
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
		if Mix:Mode() == "Combo" then
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
		if Mix:Mode() == "Combo" then
			if Ready(_Q) and GetCurrentHP(target) > QDmg then
				CastSpell(_Q)
				DelayAction(function()
					AttackUnit(spell.target)
				end, spell.windUpTime)
			end
		end
	end
	
	if TrundleMenu.Combo.CRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if T > 0 then 
				if Ready(T) then
					CastSpell(T)
				end
			end
		end
	end	
	
	if TrundleMenu.Combo.CRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if RH > 0 then 
				if Ready(RH) then
					CastSpell(RH)
				end
			end
		end
	end

	if TrundleMenu.LaneClear.LCQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			if Ready(_Q) then
				CastSpell(_Q)
			end
		end	
	end
	
	if TrundleMenu.LaneClear.LCRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			if RH > 0 then
				if Ready(RH) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(RH)
				end	
			end	
		end
	end
	
	if TrundleMenu.LaneClear.LCRH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion and spell.target.team == 300 - GetTeam(myHero) then
		if Mix:Mode() == "LaneClear" then
			if T > 0 then
				if Ready(T) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
					CastSpell(T)
				end
			end
		end
	end	
	
	if TrundleMenu.JungleClear.JCQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.team == 300 then
		if Mix:Mode() == "LaneClear" then
			if GetPercentMP(myHero) >= TrundleMenu.JungleClear.JCC:Value() and Ready(_Q) then
				CastSpell(_Q)
			end	
		end
	end

	if TrundleMenu.JungleClear.JCTH:Value() and unit.isMe and spell.name:lower():find("trundleq") and spell.target.team == 300 then
		if Mix:Mode() == "LaneClear" then
			if TH > 0 and Ready(TH) then
				CastSpell(TH)
			end
		end
	end		
end)	

OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("tiamatcleave") then
		Mix:ResetAA()
	end
end)	

OnProcessSpell(function(unit,spellProc)
	if unit.isMe and spellProc.name:lower():find("attack") and spellProc.target.isHero then
		nextAttack = GetTickCount() + spellProc.windUpTime * 1000
	end
end)	

OnProcessWaypoint(function(unit, waypointProc)
	if unit.isHero and waypointProc.dashspeed > unit.ms and not unit.isMe and unit.team == 300 - myHero.team then
		local dashTargetPos = waypointProc.position
        	if TrundleMenu.AntiGapclose.AGE:Value() then    
			local EPred = GetCircularAOEPrediction(unit, EStats) 
			if GetDistance(myHero, EPred.castPos) < GetCastRange(myHero, _E) and Ready(_E) then
                		CastSkillShot(_E, EPred.castPos)    
            		end    
        	end
    	end
end)
