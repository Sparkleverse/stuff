if GetObjectName(GetMyHero()) ~= "Akali" then return end

local ver = "0.09"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomAkali.lua", SCRIPT_PATH .. "CustomAkali.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomAkali.version", AutoUpdate)

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local AkaliMenu = Menu("Akali", "Akali")
AkaliMenu:SubMenu("Combo", "Combo")
AkaliMenu.Combo:Boolean("Q", "Use Q", true)
AkaliMenu.Combo:Boolean("E", "Use E", true)
AkaliMenu.Combo:Boolean("R", "Use R", true)
AkaliMenu.Combo:Boolean("TH", "Titanic Hydra AA Reset", true)
AkaliMenu.Combo:Boolean("HTGB", "Use Gunblade", true)
AkaliMenu.Combo:Boolean("BWC", "Use Bilgewater Cutlass", true)
AkaliMenu.Combo:Slider("HPHTGB", "Target's Hp to Use Items",85,5,100,2)
AkaliMenu.Combo:Slider("ComboEnergyManager", "Min Energy to Use Combo",0,0,200,10)

AkaliMenu:SubMenu("LaneClear", "LaneClear")
AkaliMenu.LaneClear:Boolean("Q", "Use Q", true)
AkaliMenu.LaneClear:Boolean("E", "Use E", true)
AkaliMenu.LaneClear:Slider("EnergyManager", "Min Energy to LaneClear",100,0,200,10)

AkaliMenu:SubMenu("LastHit","LastHit")
AkaliMenu.LastHit:Boolean("QLH", "Use Q", true)
AkaliMenu.LastHit:Boolean("ELH", "Use E", true)
AkaliMenu.LastHit:Slider("LHEnergyManager", "Min Energy to Use Last Hit",0,0,200,10)
AkaliMenu.LastHit:Boolean("ALHQ", "Auto Last Hit", true)
AkaliMenu.LastHit:Slider("ALHEnergyManager", "Min Energy to Use Auto Last Hit",0,0,200,10)

AkaliMenu:SubMenu("KillSteal", "KillSteal")
AkaliMenu.KillSteal:Boolean("KSQ", "KillSteal with Q", true)
AkaliMenu.KillSteal:Boolean("KSE", "KillSteal with E", true)
AkaliMenu.KillSteal:Boolean("KSR", "KillSteal with R", true)
AkaliMenu.KillSteal:Boolean("KSG", "KillSteal with Gunblade", true)
AkaliMenu.KillSteal:Boolean("KSC", "KillSteal with Cutlass", true)

AkaliMenu:SubMenu("Misc", "Misc")
AkaliMenu.Misc:SubMenu("AL", "Auto Level")
AkaliMenu.Misc.AL:Boolean("UAL", "Use Auto Level", true)
AkaliMenu.Misc.AL:Boolean("ALQ", "R>Q>E>W", false)
AkaliMenu.Misc.AL:Boolean("ALE", "R>E>Q>W", false)
AkaliMenu.Misc:Boolean("AutoW", "UseAutoW", true)
AkaliMenu.Misc:Slider("AutoWP", "Percent Health for Auto W",20,5,90,2)
AkaliMenu.Misc:Boolean("AutoWE", "Use Auto W on X Enemies", true)
AkaliMenu.Misc:Slider("AutoWX", "X Enemies to Cast AutoW",3,1,5,1)
AkaliMenu.Misc:Boolean("AutoI", "Auto Ignite", true)
AkaliMenu.Misc:Boolean("AZ", "Auto Zhonyas", true)
AkaliMenu.Misc:Slider("AZC", "HP to Auto Zhonyas",10,1,100,1)

AkaliMenu:SubMenu("Draw", "Drawings")
AkaliMenu.Draw:Boolean("DAA", "Draw AA Range", true)
AkaliMenu.Draw:Boolean("DQ", "Draw Q Range", true)
AkaliMenu.Draw:Boolean("DW", "Draw W Range", true)
AkaliMenu.Draw:Boolean("DDW", "Draw W Position", true)
AkaliMenu.Draw:Boolean("DE", "Draw E Range", true)
AkaliMenu.Draw:Boolean("DR", "Draw R Range", true)
AkaliMenu.Draw:Boolean("DrawK", "Draw if Target is Killable", true)

AkaliMenu:SubMenu("Escape", "Escape, Hold G")
AkaliMenu.Escape:Boolean("ESCR", "Use R", true)

AkaliMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Akali"] = {"Classic", "Stinger", "Crimson", "All-Star", "Nurse", "BloodMoon", "Silverfang", "Headhunter"}}
AkaliMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
AkaliMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

local nextAttack = 0
local AnimationQ = 0
local target = GetCurrentTarget()

OnTick(function ()

	local IDamage = (50 + (20 * GetLevel(myHero)))
	local target = GetCurrentTarget()
	
	if AkaliMenu.Misc.AL.UAL:Value() and AkaliMenu.Misc.AL.ALQ:Value() and not AkaliMenu.Misc.AL.ALE:Value() then
		spellorder = {_Q, _E, _Q, _W, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end    

	if AkaliMenu.Misc.AL.UAL:Value() and AkaliMenu.Misc.AL.ALE:Value() and not AkaliMenu.Misc.AL.ALQ:Value() then
		spellorder = {_E, _Q, _E, _W, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end	

	if Mix:Mode() == "Combo" then
		
		if GetCurrentMana(myHero) >= AkaliMenu.Combo.ComboEnergyManager:Value() then
			if AkaliMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 600) then
					CastTargetSpell(target, _Q)
        	end

        	if GetCurrentMana(myHero) >= AkaliMenu.Combo.ComboEnergyManager:Value() then        
         		if GetTickCount() > nextAttack then	
					if AkaliMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 325) then
						CastSpell(_E)
					end
				end
			end
	
			if GetDistance(target, myHero) >= 325 or GetCurrentMana(myHero) < 40 then
				if GetTickCount() > nextAttack then	
					if AkaliMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 700) then
						CastTargetSpell(target, _R)
                	end
				end
			end	
	
			if AkaliMenu.Combo.HTGB:Value() and ValidTarget(target, 700) then
				if Ready(GetItemSlot(myHero, 3146)) then
					if GetPercentHP(target) < AkaliMenu.Combo.HPHTGB:Value() then
						CastSpell(GetItemSlot(myHero, 3146))
					end
				end	
			end
	
			if AkaliMenu.Combo.BWC:Value() and Ready(GetItemSlot(myHero, 3144)) and ValidTarget(target, 550) then
				if GetPercentHP(target) < AkaliMenu.Combo.HPHTGB:Value() then
					CastSpell(GetItemSlot(myHero, 3144))
				end
			end	
		end	
	end
	
	if Mix:Mode() == "LaneClear" then
	
		for _,closeminion in pairs(minionManager.objects) do
			if GetCurrentMana(myHero) >= AkaliMenu.LaneClear.EnergyManager:Value() then
				if AkaliMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 600) then
					CastTargetSpell(closeminion, _Q)
				end
			end	
					
			if GetCurrentMana(myHero) >= AkaliMenu.LaneClear.EnergyManager:Value() then
				if AkaliMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 325) and MinionsAround(myHero, 325) > 1 then
				    CastSpell(_E)
				end
			end
		end
	end

	if Mix:Mode() == "LastHit" then
	
		for _,closeminion in pairs(minionManager.objects) do
			if GetCurrentMana(myHero) > AkaliMenu.LastHit.LHEnergyManager:Value() then
				if AkaliMenu.LastHit.QLH:Value() and Ready(_Q) and ValidTarget(closeminion, 600) then
					if GetDistance(closeminion, myHero) > 125 then
						if GetCurrentHP(closeminion) < CalcDamage(myHero, closeminion, 0, 15 + 20 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.4) then
							CastTargetSpell(closeminion, _Q) 
						end
					end
				end
			end	
			
			if GetCurrentMana(myHero) > AkaliMenu.LastHit.LHEnergyManager:Value() then
				if GetTickCount() > nextAttack then
					if AkaliMenu.LastHit.ELH:Value() and Ready(_E) and ValidTarget(closeminion, 325) then
						if GetCurrentHP(closeminion) < CalcDamage(myHero, closeminion, 0, 5 + 25 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.4 + (myHero.totalDamage) * 0.6) then
							CastSpell(_E)
						end	
					end
				end
			end
		end	
	end
	
	--AutoLastHit
	for _,closeminion in pairs(minionManager.objects) do
		if not KeyIsDown(32) then
			if AkaliMenu.LastHit.ALHQ:Value() then
				if GetCurrentMana(myHero) > AkaliMenu.LastHit.ALHEnergyManager:Value() and Ready(_Q) and ValidTarget(closeminion, 600) then
					if GetTickCount() > nextAttack then
						if GetCurrentHP(closeminion) < CalcDamage(myHero, closeminion, 0, 15 + 20 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.4) then
							CastTargetSpell(closeminion, _Q)
						end
					end
				end
			end
		end
	end	
	
	--Killsteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if AkaliMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 600) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 15 + 20 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.4) then
	           		CastTargetSpell(enemy , _Q)
			end
		end
	
		if AkaliMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 700) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 25 + 75 * GetCastLevel(myHero,_R) + GetBonusAP(myHero) * 0.5) then
				CastTargetSpell(enemy , _R)
			end
		end
	
		if AkaliMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, 325) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 5 + 25 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.4 + (myHero.totalDamage) * 0.6) then
				CastSpell(_E)
			end
		end
		
		if AkaliMenu.KillSteal.KSC:Value() and Ready(GetItemSlot(myHero, 3144)) and ValidTarget(enemy, 550) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 100) then
				CastSpell(GetItemSlot(myHero, 3144))
			end
		end
	
		if AkaliMenu.KillSteal.KSG:Value() and Ready(GetItemSlot(myHero, 3146)) and ValidTarget(enemy, 700) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 250 + GetBonusAP(myHero) * 0.3) then
			   CastSpell(GetItemSlot(myHero, 3146))
			end
		end	
	end
	
	--AutoW
	if AkaliMenu.Misc.AutoW:Value() and Ready(_W) and EnemiesAround(myHeroPos(), 1000) >= 1 and (EnemiesAround(myHeroPos(), 1000) >= AkaliMenu.Misc.AutoWX:Value() or GetPercentHP(myHero) <= AkaliMenu.Misc.AutoWP:Value()) then
		CastSkillShot(_W, myHeroPos())
	end
	
	--Escape
	if KeyIsDown(71) then 
			MoveToXYZ(GetMousePos())
		for _,closeminion in pairs(minionManager.objects) do	
			if AkaliMenu.Escape.ESCR:Value() and Ready(_R) and ValidTarget(closeminion,700) then	
				if EnemiesAround(closeminion, 700) < 1 then
						CastTargetSpell(closeminion, _R)
				end	
			end
		end	
	end
	
	--AutoIgnite
	for _, enemy in pairs(GetEnemyHeroes()) do
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if AkaliMenu.Misc.AutoI:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if AkaliMenu.Misc.AutoI:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < IDamage then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end
	
	--Auto Zhonyas
	if AkaliMenu.Misc.AZ:Value() and Ready(GetItemSlot(myHero,3157)) then
		if GetPercentHP(myHero) <= AkaliMenu.Misc.AZC:Value() then
			if EnemiesAround(myHero, 1000) > 0 then
				CastSpell(GetItemSlot(myHero, 3157))
			end
		end
	end		
end)

OnProcessSpell(function(unit,spellProc)
	if unit.isMe and spellProc.name:lower():find("attack") and spellProc.target.isHero then
		nextAttack = GetTickCount() + spellProc.windUpTime * 1000
	end
	
	if unit.isMe and spellProc.name:lower():find("akalimota") and spellProc.target.isminion then
			AnimationQ = GetTickCount() + spellProc.windUpTime * 1000
	end
end)

OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	local mpos = GetMousePos()
	if AkaliMenu.Draw.DQ:Value() then DrawCircle(pos, 600, 1, 25, GoS.White) end
	if AkaliMenu.Draw.DAA:Value() then DrawCircle(pos, 125, 1, 25, GoS.Green) end
	if AkaliMenu.Draw.DE:Value() then DrawCircle(pos, 325, 1, 25, GoS.Yellow) end
	if AkaliMenu.Draw.DR:Value() then DrawCircle(pos, 700, 1, 25, GoS.Cyan) end
	if AkaliMenu.Draw.DW:Value() then DrawCircle(pos, 700, 1, 25, GoS.Blue) end
	if AkaliMenu.Draw.DDW:Value() then DrawCircle(mpos, 400, 1, 25, GoS.Red) end

	for _, enemy in pairs(GetEnemyHeroes()) do
		local epos = GetOrigin(enemy)
		local drawpos = WorldToScreen(1,epos.x, epos.y, epos.z)
		local QDamage = CalcDamage(myHero, enemy, 0, 15 + 20 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.4)
		local QPDamage = CalcDamage(myHero, enemy, 0, 20 + 25 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.5)
		local EDamage = CalcDamage(myHero, enemy, (myHero.totalDamage) * 0.6, 5 + 25 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.4, 0)
		local RDamage = CalcDamage(myHero, enemy, 0, 25 + 75 * GetCastLevel(myHero,_R) + GetBonusAP(myHero) * 0.5)
		local HTGBDamage = CalcDamage(myHero, enemy, 0, 250 + GetBonusAP(myHero) * 0.3)
		if AkaliMenu.Draw.DrawK:Value() then
			if enemy.valid then
				if Ready(_Q) and Ready(_E) and Ready (_R) and Ready(GetItemSlot(myHero, 3146)) then
					if GetCurrentHP(enemy) < QDamage + QPDamage + EDamage + (RDamage * GetSpellData(myHero,_R).ammo) + HTGBDamage then
						DrawText("Killable", 30, drawpos.x-60, drawpos.y, GoS.White)
						else
						DrawText("Not Killable", 30, drawpos.x-60, drawpos.y, GoS.White)
					end
				end
			end
		end	
	end	
end)

OnProcessSpellComplete(function(unit,spell)
	if AkaliMenu.Combo.TH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			local TH = GetItemSlot(myHero,3748)
			if TH > 0 then 
				if Ready(TH) and GetCurrentHP(target) > CalcDamage(myHero, target, myHero.totalDamage + (GetMaxHP(myHero) / 10), ((myHero.totalDamage / 100) * 6) + (GetBonusAP(myHero) / 6)) then
					CastSpell(TH)
					DelayAction(function()
						AttackUnit(spell.target)
					end, spell.windUpTime)
				end
			end
        	end
	end
end)	
	
print("Thank You For Using Custom Akali, Have Fun :D")
