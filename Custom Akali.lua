if GetObjectName(GetMyHero()) ~= "Akali" then return end

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
AkaliMenu.Misc:Boolean("UseHTGB", "Use Hextech Gunblade", true)
AkaliMenu.Misc:Boolean("AutoLevel", true)

RumbleMenu:SubMenu("SkinChanger", "SkinChanger")
RumbleMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
RumbleMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 0, 1, 2, 3, 4, 5, 6, 7, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

function AutoUpdate()
	if tonumber(data) > tonumber(ver) then
		print("There is a newer version, please wait for download to complete")
		DownloadFileAsync('https://raw.githubusercontent.com/Toshibiotro/stuff/master/Custom%20Akali.lua', SCRIPT_PATH .. 'CustomAkali.lua', function() Print("Update Completed, please 2x F6") return end)	
		else print("No Updates")
		end
	end

OnTick(function ()

        local target = GetCurrentTarget()
        if AkaliMenu.Misc.AutoLevel:Value() then
                   spellorder = {_Q, _E, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
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
		           CastSpell(_E , targetPos)
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
	                   CastSpell(_E , targetPos)
                	end
		end
	end	
end)

local function SkinChanger()
	if AkaliMenu.Skin.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end
print("Thank You For Using Custom Akali, Have Fun :D")
