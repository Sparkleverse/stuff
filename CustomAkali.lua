if GetObjectName(GetMyHero()) ~= "Akali" then return end

local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/CustomAkali.lua", SCRIPT_PATH .. "CustomAkali.lua", function() print("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end

local AkaliMenu = Menu("Akali", "Akali")
AkaliMenu:SubMenu("Combo", "Combo")
AkaliMenu.Combo:Boolean("Q", "Use Q", true)
AkaliMenu.Combo:Boolean("E", "Use E", true)
AkaliMenu.Combo:Boolean("R", "Use R", true)

AkaliMenu:SubMenu("KillSteal", "KillSteal")
AkaliMenu.KillSteal:Boolean("KSQ", "KillSteal with Q", true)
AkaliMenu.KillSteal:Boolean("KSE", "KillSteal with E", true)
AkaliMenu.KillSteal:Boolean("KSR", "KillSteal with R", true)

AkaliMenu:SubMenu("Misc", "Misc")
AkaliMenu.Misc:Boolean("AutoLevel", "UseAutoLevel", true)

AkaliMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta       = {["Akali"] = {"Classic", "Stinger", "Crimson", "All-Star", "Nurse", "BloodMoon", "Silverfang", "Headhunter"}} --fix these
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
		
		        if AkaliMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 600) then
			   CastTargetSpell(target, _Q)
                        end
         
                        if AkaliMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 325) then
	                   local targetPos = GetOrigin(target)
		           CastSpell(_E)
			end
				
	                if AkaliMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 700) then
		           CastTargetSpell(target, _R)
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
	                   local targetPos = GetOrigin(target)
	                   CastSpell(_E)
                	end
		end
	end	
end)

print("Thank You For Using Custom Akali, Have Fun :D")
