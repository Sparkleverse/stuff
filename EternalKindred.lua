if GetObjectName(GetMyHero()) ~= "Kindred" then return end

local ver = "0.03"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalKindred.lua", SCRIPT_PATH .. "EternalKindred.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalKindred.version", AutoUpdate)

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Kindred", "Toshibiotro", true)

require ("OpenPredict")
require("MapPositionGOS")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

--Menu
local KindredMenu = Menu("Kindred", "Kindred")
KindredMenu:SubMenu("Combo", "Combo")
KindredMenu.Combo:Boolean("CQ", "Use Q", true)
KindredMenu.Combo:Boolean("CW", "Use W", true)
KindredMenu.Combo:Boolean("CE", "Use E", true)
KindredMenu.Combo:Boolean("CR", "Use R", true)
KindredMenu.Combo:Slider("CRC", "Min HP To R",10,0,100,1)
KindredMenu.Combo:Slider("CMM", "Min Mana To Combo",25,0,100,1)
KindredMenu.Combo:Boolean("Bilge", "Use Cutlass", true)
KindredMenu.Combo:Boolean("BORK", "Use BORK", true)

KindredMenu:SubMenu("Harass", "Harass")
KindredMenu.Harass:Boolean("HQ", "Use Q", true)
KindredMenu.Harass:Boolean("HW", "Use W", true)
KindredMenu.Harass:Boolean("HE", "Use E", true)
KindredMenu.Harass:Slider("HMM", "Min Mana To Harass",25,0,100,1)

KindredMenu:SubMenu("LaneClear", "LaneClear")
KindredMenu.LaneClear:Boolean("LCQ", "Use Q", true)
KindredMenu.LaneClear:Boolean("LCW", "Use W", true)
KindredMenu.LaneClear:Boolean("LCE", "Use E", true)
KindredMenu.LaneClear:Slider("LCMM", "Min Mana To LaneClear",25,0,100,1)

KindredMenu:SubMenu("JungleClear", "JungleClear")
KindredMenu.JungleClear:Boolean("JCQ", "Use Q", true)
KindredMenu.JungleClear:Boolean("JCW", "Use W", true)
KindredMenu.JungleClear:Boolean("JCE", "Use E", true)
KindredMenu.JungleClear:Slider("JCMM", "Min Mana To JungleClear",25,0,100,1)

KindredMenu:SubMenu("KillSteal", "KillSteal")
KindredMenu.KillSteal:Boolean("KSQ", "Use Q", true)

KindredMenu:SubMenu("WJ", "WallJump")
KindredMenu.WJ:Boolean("WJQ", "Use Q", true)
KindredMenu.WJ:KeyBinding("WJ", "Wall Jump", string.byte("G"))

KindredMenu:SubMenu("GapClose", "GapClose")
KindredMenu.GapClose:Boolean("GCQ", "Use Q", true)

KindredMenu:SubMenu("Misc", "Misc")
KindredMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
KindredMenu.Misc:Boolean("AR", "Auto R When Low", true)
KindredMenu.Misc:Slider("ARC", "HP To Use R",10,0,100,1)
KindredMenu.Misc:Boolean("ARA", "Auto R Save Allies", true)
KindredMenu.Misc:Slider("ARAC", "Min Ally HP To Use R",10,0,100,1)
KindredMenu.Misc:Boolean("QSS", "Use QSS", true)

KindredMenu:SubMenu("AutoSmite", "Auto Smite")
KindredMenu.AutoSmite:Boolean("ASG", "Smite Gromp", false)
KindredMenu.AutoSmite:Boolean("ASB", "Smite Blue", true)
KindredMenu.AutoSmite:Boolean("ASR", "Smite Red", false)
KindredMenu.AutoSmite:Boolean("ASK", "Smite Big Krug", false)
KindredMenu.AutoSmite:Boolean("ASD", "Smite Dragon", true)
KindredMenu.AutoSmite:Boolean("ASBA", "Smite Baron", true)

KindredMenu:SubMenu("Draw", "Drawings")
KindredMenu.Draw:Boolean("DAA", "Draw AA Range", true)
KindredMenu.Draw:Boolean("DQ", "Draw Q Range", true)
KindredMenu.Draw:Boolean("DW", "Draw W Range", true)
KindredMenu.Draw:Boolean("DE", "Draw E Range", true)
KindredMenu.Draw:Boolean("DR", "Draw R Range", true)
KindredMenu.Draw:Boolean("DQD", "Draw Q Dash Range", true)

KindredMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Kindred"] = {"Classic", "Shadowfire", "Super Galaxy", "Test"}}
KindredMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
KindredMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local mark = 0
local target = GetCurrentTarget()
function QDmg(unit) return CalcDamage(myHero, unit, 35 + 20 * GetCastLevel(myHero, _Q) + (myHero.totalDamage * 0.2) + (5 * mark), 0) end
local Move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local nextAttack = 0
local CCType = {[5] = "Stun", [7] = "Silence", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local QSS = nil
local MercSkimm = nil
local WRange = GetCastRange(myHero, _W) + GetHitBox(myHero)
local ERange = GetCastRange(myHero, _E) + GetHitBox(myHero)
local QRange = GetCastRange(myHero, _Q) + GetHitBox(myHero)
local RRange = GetCastRange(myHero, _R) + GetHitBox(myHero)

OnTick(function()

	target = GetCurrentTarget()
	local BORK = GetItemSlot(myHero, 3153)
	local Bilge = GetItemSlot(myHero, 3144)
	QSS = GetItemSlot(myHero, 3140)
	MercSkimm = GetItemSlot(myHero, 3139)
	local movePos = GetPrediction(target, Move).castPos
	mark = GetBuffData(myHero, "kindredmarkofthekindredstackcounter").Stacks
	QSS = GetItemSlot(myHero, 3140)
	MercSkimm = GetItemSlot(myHero, 3139)
	local smd = (({[1]=390,[2]=410,[3]=430,[4]=450,[5]=480,[6]=510,[7]=540,[8]=570,[9]=600,[10]=640,[11]=680,[12]=720,[13]=760,[14]=800,[15]=850,[16]=900,[17]=950,[18]=1000})[GetLevel(myHero)])
	
	--Auto Level
	if KindredMenu.Misc.AutoLevel:Value() == 2 then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	if KindredMenu.Misc.AutoLevel:Value() == 3 then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if KindredMenu.Misc.AutoLevel:Value() == 4 then
		spellorder = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if KindredMenu.Misc.AutoLevel:Value() == 5 then
		spellorder = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if KindredMenu.Misc.AutoLevel:Value() == 6 then
		spellorder = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if KindredMenu.Misc.AutoLevel:Value() == 7 then
		spellorder = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	--Combo
	if Mix:Mode() == "Combo" then
		
		if KindredMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, WRange) then
			if GetPercentMP(myHero) >= KindredMenu.Combo.CMM:Value() then
				CastSpell(_W)
			end
		end

		if KindredMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if GetPercentMP(myHero) >= KindredMenu.Combo.CMM:Value() then
				if GetTickCount() > nextAttack then
					CastTargetSpell(target, _E)
				end	
			end
		end

		if KindredMenu.Combo.CR:Value() and Ready(_R) and GetCurrentHP(myHero) <= KindredMenu.Combo.CRC:Value() then
			if EnemiesAround(myHero, 850) > 0 then
				CastSpell(_R)
			end
		end

		if KindredMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 90 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end
		
		if KindredMenu.Combo.BORK:Value() and Ready(BORK) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 90 and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, BORK)
			end
		end		

		if KindredMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 90 and GetDistance(movePos) > GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end

		if KindredMenu.Combo.Bilge:Value() and Ready(Bilge) and ValidTarget(target, 550) then
			if GetPercentHP(myHero) <= 90 and GetDistance(movePos) < GetDistance(target) then
				CastTargetSpell(target, Bilge)
			end
		end
	end
	
	--Harass
	if Mix:Mode() == "Harass" then
	
		if KindredMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, WRange) then
			if GetPercentMP(myHero) >= KindredMenu.Harass.HMM:Value() then
				CastSpell(_W)
			end
		end
		
		if KindredMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if GetPercentMP(myHero) >= KindredMenu.Harass.HMM:Value() then
				if GetTickCount() > nextAttack then
					CastTargetSpell(target, _E)
				end	
			end
		end
	end

	--LaneClear	
	if Mix:Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if KindredMenu.LaneClear.LCW:Value() and Ready(_W) and ValidTarget(minion, WRange) then
					if GetPercentMP(myHero) >= KindredMenu.LaneClear.LCMM:Value() then
						CastSpell(_W)
					end
				end
			
				if KindredMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
					if GetPercentMP(myHero) >= KindredMenu.LaneClear.LCMM:Value() then
						CastTargetSpell(minion, _E)
					end	
				end
			end
	
	--JungleClear
			if GetTeam(minion) == MINION_JUNGLE and GetObjectName(minion):lower():find("sru") and not GetObjectName(minion):lower():find("mini") then
				if KindredMenu.JungleClear.JCW:Value() and Ready(_W) and ValidTarget(minion, WRange) then
					if GetPercentMP(myHero) >= KindredMenu.JungleClear.JCMM:Value() then
						CastSpell(_W)
					end
				end
		
				if KindredMenu.JungleClear.JCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
					if GetPercentMP(myHero) >= KindredMenu.JungleClear.JCMM:Value() then
						CastTargetSpell(minion, _E)
					end
				end	
			end
		end
	end		
	
	--KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if KindredMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 840) then
			if GetCurrentHP(enemy) <= QDmg(enemy) then
				CastSkillShot(_Q, enemy)
			end
		end		
	end
	
	-- Auto R
	if KindredMenu.Misc.AR:Value() and Ready(_R) and GetPercentHP(myHero) <= KindredMenu.Misc.ARC:Value() then
		if EnemiesAround(myHero, 850) > 0 then
			CastSpell(_R)
		end
	end

	for _, ally in pairs(GetAllyHeroes()) do
		if KindredMenu.Misc.ARA:Value() and Ready(_R) and ValidTarget(ally, RRange) and GetPercentHP(ally) <= KindredMenu.Misc.ARAC:Value() then
			if EnemiesAround(ally, 800) > 0 then
				CastSpell(_R)
			end	
		end
	end

	--GapClose
	if KindredMenu.GapClose.GCQ:Value() and Ready(_Q) and ValidTarget(target, 1000) and GetDistance(myHero, target) > 500 then
		if GetDistance(movePos) > GetDistance(target) then
			if Mix:Mode() == "Combo" or Mix:Mode() == "Harass" then
				CastSkillShot(_Q, target)
			end	
		end
	end

	--WallJump :/
	if KindredMenu.WallJump.WJ:Value() then
		local jump1 = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 75
		local jump2 =  GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 450
		if KindredMenu.WallJump.WJQ:Value() then
			if not MapPosition:inWall(jump1) then
				MoveToXYZ(GetMousePos())
				else
				if not MapPosition:inWall(jump2) and Ready(_Q) then
					CastSkillShot(_Q, jump2)
				end
			end
		end	
	end

	-- Auto Smite
	for _, jung in pairs(minionManager.objects) do
		if GetCastName(myHero, SUMMONER_1):lower():find("summonersmite") then
			if KindredMenu.AutoSmite.ASG:Value() and GetObjectName(jung):lower():find("sru_gromp") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			elseif KindredMenu.AutoSmite.ASK:Value() and GetObjectName(jung):lower():find("sru_krug") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			elseif KindredMenu.AutoSmite.ASD:Value() and GetObjectName(jung):lower():find("sru_dragon") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			elseif KindredMenu.AutoSmite.ASB:Value() and GetObjectName(jung):lower():find("sru_blue") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			elseif KindredMenu.AutoSmite.ASR:Value() and GetObjectName(jung):lower():find("sru_red") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			elseif KindredMenu.AutoSmite.ASBA:Value() and GetObjectName(jung):lower():find("sru_baron") and Ready(SUMMONER_1) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_1)
			end
		end
		
		if GetCastName(myHero, SUMMONER_2):lower():find("summonersmite") then
			if KindredMenu.AutoSmite.ASG:Value() and GetObjectName(jung):lower():find("sru_gromp") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			elseif KindredMenu.AutoSmite.ASK:Value() and GetObjectName(jung):lower():find("sru_krug") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			elseif KindredMenu.AutoSmite.ASD:Value() and GetObjectName(jung):lower():find("sru_dragon") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			elseif KindredMenu.AutoSmite.ASB:Value() and GetObjectName(jung):lower():find("sru_blue") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			elseif KindredMenu.AutoSmite.ASR:Value() and GetObjectName(jung):lower():find("sru_red") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			elseif KindredMenu.AutoSmite.ASBA:Value() and GetObjectName(jung):lower():find("sru_baron") and Ready(SUMMONER_2) and ValidTarget(jung, 500) and GetCurrentHP(jung) <= smd then
				CastTargetSpell(jung, SUMMONER_2)
			end
		end
	end	
end)

--Drawings
OnDraw(function()
	if KindredMenu.Draw.DAA:Value() then DrawCircle(myHero, GetRange(myHero) + GetHitBox(myHero), 1, 25, GoS.White) end
	if KindredMenu.Draw.DQ:Value() then DrawCircle(myHero, GetRange(myHero) + GetHitBox(myHero), 1, 25, GoS.Red) end
	if KindredMenu.Draw.DW:Value() then DrawCircle(myHero, WRange, 1, 25, GoS.Blue) end
	if KindredMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 1, 25, GoS.Green) end
	if KindredMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 1, 25, GoS.Pink) end
	if KindredMenu.Draw.DQD:Value() then DrawCircle(myHero, 340, 1, 25, GoS.Cyan) end
end)

--Auto Attack Resets
OnProcessSpellComplete(function(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if KindredMenu.Combo.CQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) then
				CastSkillShot(_Q, GetMousePos())
			end
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Harass" then
			if KindredMenu.Harass.HQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) then
				CastSkillShot(_Q, GetMousePos())
			end
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			if KindredMenu.LaneClear.LCQ:Value() and Ready(_Q) and IsObjectAlive(spell.target) then
				CastSkillShot(_Q, GetMousePos())
			end
		end	
	end
	
	if unit.isMe and spell.name:lower():find("kindredq") then
		Mix:ResetAA()
	end	
end)

--Auto QSS
OnUpdateBuff(function(unit, buff)
	if unit.isMe and CCType[buff.Type] and KindredMenu.Misc.QSS:Value() and QSS > 0 and Ready(QSS) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(QSS)
		end	
	end
	
	if unit.isMe and CCType[buff.Type] and KindredMenu.Misc.QSS:Value() and MercSkimm > 0 and Ready(MercSkimm) then
		if GetPercentHP(myHero) <= 90 and EnemiesAround(myHero, 900) >= 1 then
			CastSpell(MercSkimm)
		end
	end
end)

--Auto Attack Cancels
OnProcessSpell(function(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") then
		nextAttack = GetTickCount() + spell.windUpTime * 1000
	end
	
--Animation Cancel	
	if unit.isMe and spell.name:lower():find("kindredq") then
		CastEmote(EMOTE_DANCE)
	end
end)	

print("Thanks For Using Eternal Kindred, Have Fun " ..myHero.name.. " :)")				
