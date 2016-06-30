if GetObjectName(GetMyHero()) ~= "Riven" then return end

local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomRiven.lua", SCRIPT_PATH .. "CustomRiven.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomRiven.version", AutoUpdate)

require ("DamageLib")
require ("OpenPredict")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local RivenMenu = Menu("Riven", "Riven")
RivenMenu:SubMenu("Combo", "Combo")
RivenMenu.Combo:Boolean("CQ", "Use Q", true)
RivenMenu.Combo:Boolean("CW", "Use W", true)
RivenMenu.Combo:Boolean("CE", "Use E", true)
RivenMenu.Combo:Boolean("CH", "Use Hydra", true)

RivenMenu:SubMenu("Harass", "Harass")
RivenMenu.Harass:Boolean("HQ", "Use Q", true)
RivenMenu.Harass:Boolean("HW", "Use W", true)
RivenMenu.Harass:Boolean("HE", "Use E", true)
RivenMenu.Harass:Boolean("HH", "Use Hydra")

RivenMenu:SubMenu("LaneClear", "LaneClear")
RivenMenu.LaneClear:Boolean("LCQ", "Use Q")
RivenMenu.LaneClear:Boolean("LCW", "Use W")

RivenMenu:SubMenu("LastHit", "LastHit")
RivenMenu.LastHit:Boolean("LHQ", "Use Q", true)
RivenMenu.LastHit:Boolean("LHW", "Use W", true)

RivenMenu:SubMenu("KillSteal", "KillSteal")
RivenMenu.KillSteal:Boolean("KSQ", "Use Q", true)
RivenMenu.KillSteal:Boolean("KSW", "Use W", true)
RivenMenu.KillSteal:Boolean("KSR", "Use R", true)

RivenMenu:SubMenu("Misc", "Misc")
RivenMenu.Misc:Boolean("AutoLevel", "Auto Level")
RivenMenu.Misc:Boolean("AutoI", "Auto Ignite", true)
RivenMenu.Misc:Boolean("AW", "Auto W", true)
RivenMenu.Misc:Slider("AWC", "Min Enemies To Auto W",3,1,6,1)

RivenMenu:SubMenu("Draw", "Drawings")
RivenMenu.Draw:Boolean("DAA", "Draw AA Range", true)
RivenMenu.Draw:Boolean("DQ", "Draw Q Range", true)
RivenMenu.Draw:Boolean("DW", "Draw W Range", true)
RivenMenu.Draw:Boolean("DE", "Draw E Range", true)
RivenMenu.Draw:Boolean("DR", "Draw R Range", true)

RivenMenu:SubMenu("Escape", "Escape, Hold G")
RivenMenu.Escape:Boolean("EQ", "Use Q", true)
RivenMenu.Escape:Boolean("EE", "Use E", true)

RivenMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"}}
RivenMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
RivenMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

function WDmg(unit) return CalcDamage(myHero,unit, 20 + 30 * GetCastLevel(myHero,_W) + GetBonusDmg(myHero) * 1, 0) end
function QDmg(unit) return CalcDamage(myHero,unit, -10 + 20 * GetCastLevel(myHero,_Q) + (myHero.totalDamage) * ((35 + 5 * GetCastLevel(myHero, _Q)) / 100), 0) end

OnTick(function ()

	local mousePos = GetMousePos()
	local target = GetCurrentTarget()
	local RStats = {delay = 0.05, range = 900, radius = 100, speed = 1600}
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local RDmg = getdmg("R",target,myHero,GetCastLevel(myHero, _R))
	
	if RivenMenu.Misc.AutoLevel:Value() then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if Mix:Mode() == "Combo" then
		
		if not GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 125) then
				CastSpell(_W)
			end
		end
				
		if GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 200) then
				CastSpell(_W)
			end
		end

		if RivenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end
		
		if RivenMenu.Combo.CH:Value() and Ready(GetItemSlot(myHero, 3074)) and ValidTarget(target, 400) then
			CastSpell(GetItemSlot(myHero, 3074))
		end			
	end	

	if Mix:Mode() == "Harass" then
		
		if RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, 125) then
				CastSpell(_W)
		end

		if RivenMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end	
		
		if RivenMenu.Combo.CH:Value() and Ready(GetItemSlot(myHero, 3074)) and ValidTarget(target, 400) then
			CastSpell(GetItemSlot(myHero, 3074))
		end			
	end	
	
	if Mix:Mode() == "LaneClear" then
		
		for _,closeminion in pairs(minionManager.objects) do
			if RivenMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 125) > 1 then
				CastSpell(_W)
			end
		end
	end	
	
	if Mix:Mode() == "LastHit" then
		for _,closeminion in pairs(minionManager.objects) do
			if RivenMenu.LastHit.LHW:Value() and Ready(_W) and ValidTarget(closeminion, 125) then
				if WDmg(closeminion) >= GetCurrentHP(closeminion) then
					CastSpell(_W)
				end
			end
			
			if RivenMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(closeminion, 260) then
				if GetCurrentHP(closeminion) < QDmg(closeminion) then
					CastSkillShot(closeminion, _Q)
				end	
			end
		end
	end

	--KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if not GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 125) then
				if GetCurrentHP(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end		

		if GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 200) then
				if GetCurrentHP(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end	
		
		if not GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 260) then
				if GetCurrentHP(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, target)
				end
			end
		end
			
		if GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 335) then
				if GetCurrentHP(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, target)
				end
			end
		end

		if GotBuff(myHero, "RivenFengShuiEngine") then
			if RivenMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 900) then
				if GetCurrentHP(enemy) < RDmg then
					local RPred = GetConicAOEPrediction(enemy,RStats)
					if RPred.hitChance >= 0.3 then
						CastSkillShot(_R, target) 
					end
				end
			end
		end	
	end	
	
	--AutoW
	if not GotBuff(myHero, "RivenFengShuiEngine") then
		if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, 125) > RivenMenu.Misc.AWC:Value() then
			CastSpell(_W)
		end
	end

	if GotBuff(myHero, "RivenFengShuiEngine") then
		if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, 200) > RivenMenu.Misc.AWC:Value() then
			CastSpell(_W)
		end
	end		
	
	--AutoIgnite
	for _, enemy in pairs(GetEnemyHeroes()) do
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if RivenMenu.Misc.AutoI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if RivenMenu.Misc.AutoI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end

	--Escape
	if KeyIsDown(71) then 
		MoveToXYZ(GetMousePos())
		if RivenMenu.Escape.EQ:Value() and Ready(_Q) then
			CastSkillShot(_Q, GetMousePos())
		end
			
		if RivenMenu.Escape.EE:Value() and Ready(_E) then
			CastSkillShot(_E, GetMousePos())
		end
	end		
end)

OnDraw(function() 
	local pos = GetOrigin(myHero)
	if RivenMenu.Draw.DQ:Value() then DrawCircle(pos, 260, 1, 25, GoS.White) end
	if RivenMenu.Draw.DAA:Value() then DrawCircle(pos, 125, 1, 25, GoS.Green) end
	if RivenMenu.Draw.DE:Value() then DrawCircle(pos, 325, 1, 25, GoS.Yellow) end
	if RivenMenu.Draw.DR:Value() then DrawCircle(pos, 900, 1, 25, GoS.Cyan) end
end)	

OnProcessSpellComplete(function(unit,spell)
	local target = GetCurrentTarget()
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then				
			if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 260) then
				CastSkillShot(_Q, target)
			end
		end	
	end
	
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Harass" then
			if RivenMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, 260) then
				CastSkillShot(_Q, target)
			end
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			for _,closeminion in pairs(minionManager.objects) do
				if RivenMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(closeminion, 260) then
					CastSkillShot(_Q, closeminion)
				end
			end
		end
	end	
end)	
