if GetObjectName(GetMyHero()) ~= "Malphite" then return end

local ver = "0.01"

require("OpenPredict")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomMalphite.lua", SCRIPT_PATH .. "CustomMalphite.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomMalphite.version", AutoUpdate)

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local MalphiteMenu = Menu("Malphite", "Malphite")
MalphiteMenu:SubMenu("Combo","Combo")
MalphiteMenu.Combo:Boolean("CQ", "Use Q", true)
MalphiteMenu.Combo:Boolean("CW", "Use W", true)
MalphiteMenu.Combo:Boolean("CE", "Use E", true)
MalphiteMenu.Combo:Boolean("CR", "Use R", true)
MalphiteMenu.Combo:Boolean("CI", "Use Items", true)
MalphiteMenu.Combo:Slider("MMC", "Min Mana % To Combo",60,0,100,1)

MalphiteMenu:SubMenu("Harass", "Harass")
MalphiteMenu.Harass:Boolean("HQ", "Use Q")
MalphiteMenu.Harass:Boolean("HW", "Use W")
MalphiteMenu.Harass:Boolean("HE", "Use E")
MalphiteMenu.Harass:Slider("MMH", "Min Mana % To Harass",60,0,100,1)

MalphiteMenu:SubMenu("LastHit", "LastHit")
MalphiteMenu.LastHit:Boolean("LHQ", "Use Q", true)
MalphiteMenu.LastHit:Boolean("LHE", "Use E", true)
MalphiteMenu.LastHit:Slider("MMLH", "Min Mana % To LastHit",60,0,100,1)

MalphiteMenu:SubMenu("LaneClear", "LaneClear")
MalphiteMenu.LaneClear:Boolean("LCQ", "Use Q", true)
MalphiteMenu.LaneClear:Boolean("LCW", "Use W", true)
MalphiteMenu.LaneClear:Boolean("LCE", "Use E", true)
MalphiteMenu.LaneClear:Slider("MMLC", "Min Mana % To LaneClear",60,0,100,1)

MalphiteMenu:SubMenu("KillSteal", "Killsteal")
MalphiteMenu.KillSteal:Boolean("KSQ", "Use Q", true)
MalphiteMenu.KillSteal:Boolean("KSE", "Use E", true)
MalphiteMenu.Killsteal:Boolean("KSR", "Use R", true)

MalphiteMenu:SubMenu("Misc", "Misc")
MalphiteMenu.Misc:Boolean("AutoLevel", "Use Auto Level", true)
MalphiteMenu.Misc:Boolean("AutoI", "Use Auto Ignite", true)
MalphiteMenu.Misc:Boolean("AR", "Auto R on X Enemies", true)
MalphiteMenu.Misc:Slider("ARC", "Min Enemies to Auto R",3,1,6,1)

MalphiteMenu:SubMenu("Draw", "Drawings")
MalphiteMenu.Draw:Boolean("DAA", "Draw AA Range", true)
MalphiteMenu.Draw:Boolean("DQ", "Draw Q Range", true)
MalphiteMenu.Draw:Boolean("DW", "Draw W Range", true)
MalphiteMenu.Draw:Boolean("DE", "Draw E Range", true)
MalphiteMenu.Draw:Boolean("DR", "Draw R Range", true)
MalphiteMenu.Draw:Boolean("DDR", "Draw R Position", true)

MalphiteMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Malphite"] = {"Classic", "Shamrock", "Coral-Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"}}
MalphiteMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
MalphiteMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local nextAttack = 0
function QDmg(unit) return CalcDamage(myHero,unit, 20 + 50 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.6) end
function EDmg(unit) return CalcDamage(myHero, unit, 0, 25 + 35 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.2 + (GetArmor(myHero) * 0.3)) end
function RDmg(unit) return CalcDamage(myHero, unit, 0, 100 + 100 * GetCastLevel(myHero,_R) + GetBonusAP(myHero) * 1) end

OnTick(function ()
	
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local RStats = {delay = 0.050, range = 1000, radius = 300, speed = 1500 + GetMoveSpeed(myHero)}
	local GetPercentMana = (GetCurrentMana(myHero) / GetMaxMana(myHero)) * 100
	local target = GetCurrentTarget()
	
	if MalphiteMenu.Misc.AutoLevel:Value() then
		spellorder = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if Mix:Mode() == "Combo" then
		
		if MalphiteMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 625) then
			if MalphiteMenu.Combo.MMC:Value() <= GetPercentMana then 
				CastTargetSpell(target, _Q)	
			end
		end
		
		if MalphiteMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, 400) then
			if MalphiteMenu.Combo.MMC:Value() <= GetPercentMana then
				if GetTickCount() > nextAttack then	
					CastSpell(_E)
				end	
			end
		end	
		
		if MalphiteMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 125) then
			if MalphiteMenu.Combo.MMC:Value() <= GetPercentMana then
				CastSpell(_W)
			end
		end
		
		if MalphiteMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 1000) then
			if MalphiteMenu.Combo.MMC:Value() <= GetPercentMana then
				local RPred = GetCircularAOEPrediction(target,RStats)
				if RPred.hitChance >= 0.3 then
					CastSkillShot(_R,RPred.castPos)
				end
			end
		end		
	end
	
	if Mix:Mode() == "Harass" then
		
		if MalphiteMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, 625) then
			if MalphiteMenu.Harass.MMH:Value() <= GetPercentMana then
				CastTargetSpell(target, _Q)
			end
		end		
		
		for _,closeminion in pairs(minionManager.objects) do	
			if MalphiteMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(closeminion, 125) and EnemiesAround(closeminion,225) > 0 then
				if MalphiteMenu.Harass.MMH:Value() <= GetPercentMana then
					CastSpell(_W)
				end
			end
		end
		
		if MalphiteMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(closeminion, 125) then
			if MalphiteMenu.Harass.MMH:Value() <= GetPercentMana then
				CastSpell(_W)
			end
		end	

		if MalphiteMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(closeminion, 400) then
			if MalphiteMenu.Harass.MMH:Value() <= GetPercentMana then
				if GetTickCount() > nextAttack then	
					CastSpell(_E)
				end
			end	
		end
	end

	if Mix:Mode() == "LaneClear" then
		
		for _,closeminion in pairs(minionManager.objects) do
			if MalphiteMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(closeminion, 625) then
				if MalphiteMenu.LaneClear.MMLC:Value() <= GetPercentMana then
					CastTargetSpell(closeminion, _Q)
				end
			end
				
			if MalphiteMenu.LaneClear.LCW:Value() and Ready(_W) and ValidTarget(closeminion, 125) and MinionsAround(closeminion, 225) > 1 then
				if MalphiteMenu.LaneClear.MMLC:Value() <= GetPercentMana then
					CastSpell(_W)
				end
			end
					
			if MalphiteMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(closeminion, 400) and MinionsAround(myHero, 400) > 1 then
				if MalphiteMenu.LaneClear.MMLC:Value() <= GetPercentMana then
					CastSpell(_E)
				end
			end
		end	
	end
	
	if Mix:Mode() == "LastHit" then
		for _,closeminion in pairs(minionManager.objects) do
			if MalphiteMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(closeminion, 625) then 
				if MalphiteMenu.LastHit.MMLH:Value() <= GetPercentMana then
					if GetDistance(closeminion, myHero) > 125 then	
						if QDmg(closeminion) >= GetCurrentHP(closeminion) then
							CastTargetSpell(closeminion, _Q)
						end
					end		
				end
			end

			if MalphiteMenu.LastHit.LHE:Value() and Ready(_E) and ValidTarget(closeminion, 400) then
				if MalphiteMenu.LastHit.MMLH:Value() <= GetPercentMana then
					if EDmg(closeminion) >= GetCurrentHP(closeminion) then
						CastSpell(_E)
					end
				end
			end		
		end
	end	
	
	--KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MalphiteMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 625) then
			if QDmg(enemy) >= GetCurrentHP(enemy) then
				CastTargetSpell(enemy, _Q)
			end
		end

		if MalphiteMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, 200) then
			if EDmg(enemy) >= GetCurrentHP(enemy) then
				CastSpell(_E)
			end
		end
		
		if MalphiteMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 1000) then
			local RPred = GetCircularAOEPrediction(target,RStats)
			if RPred.hitChance >= 0.3 then
				if RDmg(enemy) >= GetCurrentHP(enemy) then
					CastSkillShot(_R,RPred.castPos)
				end
			end		
		end
	end

	--AutoR
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MalphiteMenu.Misc.AR:Value() and Ready(_R) and ValidTarget(enemy, 1000) and EnemiesAround(enemy, 300) >= MalphiteMenu.Misc.ARC:Value() then
			local RPred = GetCircularAOEPrediction(target,RStats)
			if RPred.hitChance >= 0.3 then 
				CastSkillShot(_R,RPred.castPos)
			end	
		end
	end

	--AutoIgnite
	for _, enemy in pairs(GetEnemyHeroes()) do
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if MalphiteMenu.Misc.AutoI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if MalphiteMenu.Misc.AutoI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end
end)

OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	local mpos = GetMousePos()
	if MalphiteMenu.Draw.DQ:Value() then DrawCircle(pos, 625, 1, 25, GoS.White) end
	if MalphiteMenu.Draw.DAA:Value() then DrawCircle(pos, 125, 1, 25, GoS.Green) end
	if MalphiteMenu.Draw.DE:Value() then DrawCircle(pos, 200, 1, 25, GoS.Yellow) end
	if MalphiteMenu.Draw.DR:Value() then DrawCircle(pos, 1000, 1, 25, GoS.Cyan) end
	if MalphiteMenu.Draw.DDR:Value() then DrawCircle(mpos, 300, 1, 25, GoS.Red) end
end)	

OnProcessSpell(function(unit,spellProc)
	if unit.isMe and spellProc.name:lower():find("attack") and spellProc.target.isHero then
		nextAttack = GetTickCount() + spellProc.windUpTime * 1000
	end
end)	
