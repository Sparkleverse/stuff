if GetObjectName(GetMyHero()) ~= "Akali" then return end

local ver = "0.04"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomAkali.lua", SCRIPT_PATH .. "CustomAkali.lua", function() print("Update Complete, please 2x F6!") return end)
    else
        print("No updates found!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomAkali.version", AutoUpdate)

local AkaliMenu = Menu("Akali", "Akali")
AkaliMenu:SubMenu("Combo", "Combo")
AkaliMenu.Combo:Boolean("Q", "Use Q", true)
AkaliMenu.Combo:Boolean("E", "Use E", true)
AkaliMenu.Combo:Boolean("R", "Use R", true)
AkaliMenu.Combo:Boolean("HTGB", "Use Gunblade", true)
AkaliMenu.Combo:Boolean("BWC", "Use Bilgewater Cutlass", true)
AkaliMenu.Combo:Slider("HPHTGB", "Target's Hp to Use Items",85,5,100,2)
AkaliMenu.Combo:Slider("ComboEnergyManager", "Min Energy to Use Combo",0,0,200,10)

AkaliMenu:SubMenu("LaneClear", "LaneClear")
AkaliMenu.LaneClear:Boolean("Q", "Use Q", true)
AkaliMenu.LaneClear:Boolean("E", "Use E", true)
AkaliMenu.LaneClear:Slider("EnergyManager", "Min Energy to LaneClear",100,0,200,10)

AkaliMenu:SubMenu("KillSteal", "KillSteal")
AkaliMenu.KillSteal:Boolean("KSQ", "KillSteal with Q", true)
AkaliMenu.KillSteal:Boolean("KSE", "KillSteal with E", true)
AkaliMenu.KillSteal:Boolean("KSR", "KillSteal with R", true)

AkaliMenu:SubMenu("Misc", "Misc")
AkaliMenu.Misc:Boolean("AutoLevel", "UseAutoLevel", true)
AkaliMenu.Misc:Boolean("AutoW", "UseAutoW", true)
AkaliMenu.Misc:Slider("AutoWP","Percent Health for Auto W",20,5,90,2)

AkaliMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta       = {["Akali"] = {"Classic", "Stinger", "Crimson", "All-Star", "Nurse", "BloodMoon", "Silverfang", "Headhunter"}}
AkaliMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
AkaliMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

OnTick(function ()

        local target = GetCurrentTarget()
        if AkaliMenu.Misc.AutoLevel:Value() then
                   spellorder = {_Q, _E, _Q, _W, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
	           LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
	        end
	end        
	     
	if IOW:Mode() == "Combo" then
		
		if GetCurrentMana(myHero) >= AkaliMenu.Combo.ComboEnergyManager:Value() then
			if AkaliMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 600) then
			           CastTargetSpell(target, _Q)
        		end
        	end

        	if GetCurrentMana(myHero) >= AkaliMenu.Combo.ComboEnergyManager:Value() then        
         		if not IOW.isWindingUp then	
                        	if AkaliMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 325) then
		                   CastSpell(_E)
				end
			end
		end
	
		if GetDistance(target, myHero) >= 240 then
			if not IOW.isWindingUp then		
	                	if AkaliMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 700) then
		                   CastTargetSpell(target, _R)
                		end
			end
		end	
	
		if AkaliMenu.Combo.HTGB:Value() and Ready(GetItemSlot(myHero, 3146)) and ValidTarget(target, 700) then
			if GetPercentHP(target) < AkaliMenu.Combo.HPHTGB:Value() then
			   CastOffensiveItems(target)
			end
		end
	
		if AkaliMenu.Combo.BWC:Value() and Ready(GetItemSlot(myHero, 3144)) and ValidTarget(target, 550) then
			if GetPercentHP(target) < AkaliMenu.Combo.HPHTGB:Value() then
			   CastOffensiveItems(target)
			end
		end	
	end	
		
			if IOW:Mode() == "LaneClear" then
				
		        	for _,closeminion in pairs(minionManager.objects) do
		        		if GetCurrentMana(myHero) >= AkaliMenu.LaneClear.EnergyManager:Value() then
						if AkaliMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 600) then
				   	           CastTargetSpell(closeminion, _Q)
						end
					end	
					
					if GetCurrentMana(myHero) >= AkaliMenu.LaneClear.EnergyManager:Value() then
						if not IOW.isWindingUp then
							if AkaliMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 325) then
				           	           CastSpell(_E)
				        		end
						end
					end
				end
			end
	
	for _, enemy in pairs(GetEnemyHeroes()) do
		if AkaliMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 600) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 35 + 20 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.4) then
	           	   CastTargetSpell(enemy , _Q)
                        end
		end
	
		if AkaliMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 700) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 100 + 75 * GetCastLevel(myHero,_R) + GetBonusAP(myHero) * 0.5) then
	           	   CastTargetSpell(enemy , _R)
                	end
		end
	
		if AkaliMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, 325) then
			if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 30 + 25 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.4 + (myHero.totalDamage) * 0.6) then
	                   CastSpell(_E)
                	end
		end
	end

	for _, enemy in pairs(GetEnemyHeroes()) do		
		if AkaliMenu.Misc.AutoW:Value() and Ready(_W) and EnemiesAround(myHeroPos(), 1000) >= 2 and GetPercentHP(myHero) <= AkaliMenu.Misc.AutoWP:Value() then
		   CastSkillShot(_W, myHeroPos())
		        else
			if AkaliMenu.Misc.AutoW:Value() and Ready(_W) and EnemiesAround(myHeroPos(), 1000) >= 1 and GetPercentHP(myHero) <= AkaliMenu.Misc.AutoWP:Value() then
				   CastSkillShot(_W, myHeroPos())
			end
		end
	end		

end)

print("Thank You For Using Custom Akali, Have Fun :D")
