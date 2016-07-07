if GetObjectName(GetMyHero()) ~= "Riven" then return end

local ver = "0.15"

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Riven", "Toshibiotro", true)

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
require('MapPositionGOS')

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
RivenMenu.Combo:Boolean("CR", "Use R", true)
RivenMenu.Combo:Slider("RC", "Min Enemy HP to Cast R",60,1,100,1)
RivenMenu.Combo:Boolean("CH", "Use R Hydra", true)
RivenMenu.Combo:Boolean("CTH", "Use T Hydra", true)
RivenMenu.Combo:Boolean("YGB", "Use GhostBlade", true)

RivenMenu:SubMenu("Harass", "Harass")
RivenMenu.Harass:Boolean("HQ", "Use Q", true)
RivenMenu.Harass:Boolean("HW", "Use W", true)
RivenMenu.Harass:Boolean("HE", "Use E", true)
RivenMenu.Harass:Boolean("HH", "Use Hydra", true)

RivenMenu:SubMenu("LaneClear", "LaneClear")
RivenMenu.LaneClear:Boolean("LCQ", "Use Q")
RivenMenu.LaneClear:Boolean("LCW", "Use W")
RivenMenu.LaneClear:Boolean("LCH", "Use Hydra", true)

RivenMenu:SubMenu("JungleClear", "JungleClear")
RivenMenu.JungleClear:Boolean("JCQ", "Use Q", true)
RivenMenu.JungleClear:Boolean("JCW", "Use W", true)
RivenMenu.JungleClear:Boolean("JCE", "Use E", true)

RivenMenu:SubMenu("LastHit", "LastHit")
RivenMenu.LastHit:Boolean("LHQ", "Use Q", true)
RivenMenu.LastHit:Boolean("LHW", "Use W", true)

RivenMenu:SubMenu("KillSteal", "KillSteal")
RivenMenu.KillSteal:Boolean("KSQ", "Use Q", true)
RivenMenu.KillSteal:Boolean("KSW", "Use W", true)
RivenMenu.KillSteal:Boolean("KSR", "Use R", true)

RivenMenu:SubMenu("Misc", "Misc")
RivenMenu.Misc:SubMenu("AL", "Auto Level")
RivenMenu.Misc:Boolean("GSQ", "God Speed Q", true)
RivenMenu.Misc.AL:Boolean("UAL", "Use Auto Level", false)
RivenMenu.Misc.AL:Boolean("ALQ", "R>Q>E>W", false)
RivenMenu.Misc.AL:Boolean("ALE", "R>E>Q>W", false)
RivenMenu.Misc:Boolean("AutoI", "Auto Ignite", true)
RivenMenu.Misc:Boolean("AW", "Auto W", true)
RivenMenu.Misc:Slider("AWC", "Min Enemies To Auto W",3,1,6,1)
RivenMenu.Misc:Boolean("AR", "Auto R If Hit X Enemies", true)
RivenMenu.Misc:Slider("ARC", "Min Enemies To Auto R",4,1,6,1)

RivenMenu:SubMenu("Draw", "Drawings")
RivenMenu.Draw:Boolean("DAA", "Draw AA Range", true)
RivenMenu.Draw:Boolean("DQ", "Draw Q Range", true)
RivenMenu.Draw:Boolean("DW", "Draw W Range", true)
RivenMenu.Draw:Boolean("DE", "Draw E Range", true)
RivenMenu.Draw:Boolean("DR", "Draw R Range", true)
RivenMenu.Draw:Boolean("DD", "Draw Damage", true)

RivenMenu:SubMenu("Escape", "Escape")
RivenMenu.Escape:Boolean("EQ", "Use Q", true)
RivenMenu.Escape:Boolean("EE", "Use E", true)

RivenMenu:SubMenu("GC", "GapClose")
RivenMenu.GC:Boolean("GCQ", "Use Q", true)
RivenMenu.GC:Boolean("GCE", "Use E", true)

RivenMenu:SubMenu("AGC", "Anti-GapCloser")
RivenMenu.AGC:Boolean("AGCW", "Use W", true)

RivenMenu:SubMenu("JCS", "Dragon and Baron Steal")
RivenMenu.JCS:Boolean("JCSB", "Steal Baron", true)
RivenMenu.JCS:Boolean("JCSD", "Steal Dragon", true)

RivenMenu:SubMenu("SkinChanger", "SkinChanger")

RivenMenu:SubMenu("Keys", "Key Bindings")
RivenMenu.Keys:KeyBinding("WJ", "WallJump", string.byte("T"))
RivenMenu.Keys:KeyBinding("Escape", "Escape", string.byte("G"))

local skinMeta = {["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"}}
RivenMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
RivenMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

function WDmg(unit) return CalcDamage(myHero,unit, 20 + 30 * GetCastLevel(myHero,_W) + GetBonusDmg(myHero) * 1, 0) end
function QDmg(unit) return CalcDamage(myHero,unit, -10 + 20 * GetCastLevel(myHero,_Q) + (myHero.totalDamage) * ((35 + 5 * GetCastLevel(myHero, _Q)) * 0.01), 0) end
function EShield(myHero) return (60 + 30 * GetCastLevel(myHero, _E) + GetBonusDmg(myHero)) end
local RStats = {delay = 0.025, range = 1100, radius = 100, speed = 1600}
local QCast = 0
local target = GetCurrentTarget()

OnTick(function ()
	
	local mousePos = GetMousePos()
	target = GetCurrentTarget()
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local RDmg = getdmg("R",target,myHero,GetCastLevel(myHero, _R))
	local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
	
	if RivenMenu.Misc.AL.UAL:Value() and RivenMenu.Misc.AL.ALQ:Value() and not RivenMenu.Misc.AL.ALE:Value() then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if RivenMenu.Misc.AL.UAL:Value() and RivenMenu.Misc.AL.ALE:Value() and not RivenMenu.Misc.AL.ALQ:Value() then
		spellorder = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end	
	
	if Mix:Mode() == "Combo" then
	
		if RivenMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 600) then
			if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
				if Ready(_Q) and GetCurrentHP(target) >= RivenMenu.Combo.RC:Value() or EnemiesAround(myHero, 700) > 1 then
					CastSpell(_R)
				end
			end
		end	
		
		if RivenMenu.Combo.YGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 600) then
			CastSpell(YGB)
		end
		
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 275) then
				CastSpell(_W)
			end
		end
				
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 345) then
				CastSpell(_W)
			end
		end

		if RivenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end	
	end	

	if Mix:Mode() == "Harass" then
		
		if RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, 275) then
				CastSpell(_W)
		end

		if RivenMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end	
	end		
	
	if Mix:Mode() == "LaneClear" then
	
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 275, MINION_ENEMY) > 1 then
				CastSpell(_W)
			end
		end	
		
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 345, MINION_ENEMY) > 1 then
				CastSpell(_W)
			end
		end
		
		if RivenMenu.LaneClear.LCH:Value() and Tiamat > 0 and Ready(Tiamat) and MinionsAround(myHero, 350, MINION_ENEMY) > 1 then
			CastSpell(Tiamat)
		end
	
		if RivenMenu.LaneClear.LCH:Value() and RHydra > 0 and Ready(RHydra) and MinionsAround(myHero, 400, MINION_ENEMY) > 1 then
			CastSpell(RHydra)
		end			
	end
	
	if Mix:Mode() == "LastHit" then
	
		for _,closeminion in pairs(minionManager.objects) do
			if RivenMenu.LastHit.LHW:Value() and Ready(_W) and ValidTarget(closeminion, 275) then
				if WDmg(closeminion) >= GetCurrentHP(closeminion) then
					CastSpell(_W)
				end
			end
			
			if RivenMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(closeminion, 260) then
				if GetCurrentHP(closeminion) < QDmg(closeminion) then
					CastSkillShot(_Q, closeminion)
				end	
			end
		end
	end

	--KillSteal
	for _, enemy in pairs(GetEnemyHeroes()) do
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 275) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end		

		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 345) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end	
		
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 260) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, enemy)
				end
			end
		end
			
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 335) then
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, enemy)
				end
			end
		end

		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 900) and WindWall == nil then 
				if GetCurrentHP(enemy) + GetDmgShield(enemy) + GetHPRegen(enemy) < RDmg then
					local RPred = GetConicAOEPrediction(enemy,RStats)
					if RPred.hitChance >= 0.3 then
						CastSkillShot(_R, RPred.castPos) 
					end
				end
			end
		end	
	end	
	
	--AutoW
	if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
		if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, 275) > RivenMenu.Misc.AWC:Value() then
			CastSpell(_W)
		end
	end

	if GetCastName(myHero, _R):lower():find("rivenizunablade") then
		if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, 345) > RivenMenu.Misc.AWC:Value() then
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
	if RivenMenu.Keys.Escape:Value() then
		MoveToXYZ(GetMousePos())
		if RivenMenu.Escape.EQ:Value() and Ready(_Q) then
			CastSkillShot(_Q, GetMousePos())
		end
			
		if RivenMenu.Escape.EE:Value() and Ready(_E) then
			CastSkillShot(_E, GetMousePos())
		end
	end		
	
	--GapClose
	if Mix:Mode() == "Combo" then
		if GetDistance(myHero, target) < 700 and GetDistance(myHero, target) > 300 then
			if RivenMenu.GC.GCE:Value() and Ready(_E) then
				CastSkillShot(_E, target) 
			end
		end
		
		if GetDistance(myHero, target) < 700 and GetDistance(myHero, target) > 300 then
			if RivenMenu.GC.GCQ:Value() and Ready(_Q) then
				CastSkillShot(_Q, target)
			end
		end			
	end	
	
	--WallJump
	if RivenMenu.Keys.WJ:Value() then
		local movePos1  = GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 75
		local movePos2 =  GetOrigin(myHero) + (Vector(mousePos) - GetOrigin(myHero)):normalized() * 450
		if QCast < 2 and Ready(_Q) then
			CastSkillShot(_Q, GetMousePos())
		end
		
		if not MapPosition:inWall(movePos1) then
			MoveToXYZ(GetMousePos())
			else
			if not MapPosition:inWall(movePos2) and Ready(_Q) then
				CastSkillShot(_Q, movePos2)
			end				
		end				
	end

	--Jungle Clear
	if Mix:Mode() == "LaneClear" then
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.JungleClear.JCW:Value() and Ready(_W) and MinionsAround(myHero, 275, MINION_JUNGLE) > 0 then
				CastSpell(_W)
			end
		end	
	
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then 
			if RivenMenu.JungleClear.JCW:Value() and Ready(_W) and MinionsAround(myHero, 345, MINION_JUNGLE) > 0 then
				CastSpell(_W)
			end
		end
	end
	
	--Auto R
	for _, enemy in pairs(GetEnemyHeroes()) do
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.Misc.AR:Value() and EnemiesAround(enemy, 100) >= RivenMenu.Misc.ARC:Value() and Ready(_R) then
				local RPred = GetConicAOEPrediction(enemy,RStats)
				if RPred.hitChance >= 0.3 then
					CastSkillShot(_R, RPred.castPos) 
				end
			end	
		end
	end	
	
	--Dragon and Baron Steal
	if GetCastName(myHero, _R):lower():find("rivenizunablade") then
		for i,camp in pairs(minionManager.objects) do
			local RDragDmg = getdmg("R",camp,myHero,GetCastLevel(myHero, _R))
			if RivenMenu.JCS.JCSB:Value() then
				if GetTeam(camp) == 300 and IsObjectAlive(camp) then
					if GetObjectName(camp) == "SRU_Baron" then
						if Ready(_R) and ValidTarget(camp, 1000) then
							if GetHealthPrediction(camp, (GetDistance(myHero, camp) / 1600)) < RDragDmg then
								CastSkillShot(_R, camp)
							end
						end
					end
				end
			end	
			
			if RivenMenu.JCS.JCSD:Value() then
				if GetTeam(camp) == 300 and IsObjectAlive(camp) then
					if GetObjectName(camp):lower():find("sru_dragon") then
						if Ready(_R) and ValidTarget(camp, 1000) then
							if GetHealthPrediction(camp, (GetDistance(myHero, camp) / 1600)) < RDragDmg then
								CastSkillShot(_R, camp)
							end
						end
					end
				end		
			end
		end	
	end
end)

OnDraw(function()
	local pos = GetOrigin(myHero)
	if RivenMenu.Draw.DQ:Value() then DrawCircle(pos, 260, 1, 25, GoS.White) end
	if RivenMenu.Draw.DAA:Value() then DrawCircle(pos, 125, 1, 25, GoS.Green) end
	if RivenMenu.Draw.DW:Value() then DrawCircle(pos, 275, 1, 25, GoS.Blue) end
	if RivenMenu.Draw.DE:Value() then DrawCircle(pos, 325, 1, 25, GoS.Yellow) end
	if RivenMenu.Draw.DR:Value() then DrawCircle(pos, 900, 1, 25, GoS.Cyan) end
	
	for _, enemy in pairs(GetEnemyHeroes()) do
		local RRDmg = getdmg("R",enemy,myHero,GetCastLevel(myHero, _R))
		if RivenMenu.Draw.DD:Value() and Ready(_Q) and Ready(_W) and Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), QDmg(enemy) * 3 + (WDmg(enemy)) + (RRDmg), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_W) and Ready(_Q) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), WDmg(enemy) + (QDmg(enemy) * 3), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_Q) and not Ready(_W) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), (QDmg(enemy) * 3), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_R) and not Ready(_W) and not Ready(_Q) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), RRDmg, 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_Q) and Ready(_W) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), (QDmg(enemy) * 3) + (WDmg(enemy)), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_W) and not Ready(_Q) and not Ready(_R) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), WDmg(enemy), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_W) and Ready(_R) and not Ready(_Q) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), WDmg(enemy) + RRDmg, 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_R) and Ready(_Q) and not Ready(_W) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), RRDmg + (QDmg(enemy) * 3), 0, GoS.White) end
		if RivenMenu.Draw.DD:Value() and Ready(_R) and Ready(_W) and not Ready(_Q) then DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), RRDmg + WDmg(enemy), 0, GoS.White) end
	end
end)	

OnProcessSpell(function(unit, spell)
	local target = GetCurrentTarget()
	if RivenMenu.Combo.YGB:Value() and unit.isMe and spell.name:lower():find("rivenfengshuiengine") then
		if Mix:Mode() == "Combo" then
			local YGB = GetItemSlot(myHero, 3142)
			if YGB > 0 then
				if Ready(YGB) then
					CastSpell(YGB)
				end
			end
		end
	end

	if GetTeam(unit) == 300 and spell.name:lower():find("attack") and spell.target.isMe then
		if Mix:Mode() == "LaneClear" then
			if RivenMenu.JungleClear.JCE:Value() and Ready(_E) then
				CastSkillShot(_E, GetMousePos())
			end
		end	
	end
	
	if RivenMenu.Combo.CH:Value() and unit.isMe and spell.name:lower():find("attack") then
		if Mix:Mode() == "Combo" then
			local RH = GetItemSlot(myHero, 3074)
			if RH > 0 then
				if Ready(RH) and ValidTarget(target, 400) then
					CastSpell(RH)
				end
			end
		end	
	end
	
	if RivenMenu.Combo.CH:Value() and unit.isMe and spell.name:lower():find("attack") then
		if Mix:Mode() == "Combo" then
			local Tiamat = GetItemSlot(myHero, 3077)
			if Tiamat > 0 then
				if Ready(Tiamat) and ValidTarget(target, 350) then
					CastSpell(Tiamat)
				end
			end
		end	
	end

	if unit.isMe and spell.name:lower():find("itemtiamatcleave") then
		Mix:ResetAA()
	end	
end)

OnProcessSpellComplete(function(unit,spell)
	local target = GetCurrentTarget()
	if RivenMenu.Combo.CTH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
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
	
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if Mix:Mode() == "Combo" then
				if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 260) then
					CastSkillShot(_Q, target)	
				end
			end
		end
	end	
	
	
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if Mix:Mode() == "Combo" then					
				if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 335) then
					CastSkillShot(_Q, target)
				end
			end
		end
	end	

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if Mix:Mode() == "Harass" then		
				if RivenMenu.Harass.HQ:Value() then
					if Ready(_Q) and ValidTarget(target, 260) then
						CastSkillShot(_Q, target)
					end
				end
			end
		end
	end	

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if Mix:Mode() == "LaneClear" then
				if RivenMenu.LaneClear.LCQ:Value() then			
					for _,closeminion in pairs(minionManager.objects) do
						if Ready(_Q) and ValidTarget(closeminion, 260) then
							CastSkillShot(_Q, closeminion)
						end
					end					
				end
			end
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if Mix:Mode() == "LaneClear" then
				if RivenMenu.LaneClear.LCQ:Value() then
					for _,closeminion in pairs(minionManager.objects) do
						if Ready(_Q) and ValidTarget(closeminion, 335) then
							CastSkillShot(_Q, closeminion)
						end
					end					
				end
			end
		end
	end
	
	if unit.isMe and spell.name:lower():find("rivenfengshuiengine") then
		DelayAction(function()
			if WindWall == nil then
				CastSkillShot(_R, target)
			end		
		end, 14.85)
	end	
end) 


OnCreateObj(function(object)
	if RivenMenu.Misc.GSQ:Value() then
		if object and GetObjectBaseName(object) and GetOrigin(object) and GetDistance(object) < 1000 then
			if GetObjectBaseName(object):find("Riven_Base_Q_") and GetObjectBaseName(object):find("_detonate") and GetDistance(object) < 225 then
				if Mix:Mode() == "Combo" or	Mix:Mode() == "Harass" or Mix:Mode() == "LaneClear" then
					CastEmote(EMOTE_DANCE)
					for delay = 15,(GetLatency()*2.5) do
						DelayAction(function()
							Mix:ResetAA()
						end, delay)
					end	
				end	
			end
		end
	end
	
	if object.isSpell and object.spellName:lower():find("yasuowmovingwallmisl") and object.spellOwner.team == 300 - GetTeam(myHero) then
        WindWall = object
    end
end)

OnDeleteObj(function(object)
	if object.isSpell and object.spellName:lower():find("yasuowmovingwallmisl") and object.spellOwner.team == 300 - GetTeam(myHero) then
        WindWall = nil
	end
end)	

OnUpdateBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower():find("riventricleave") then 
		QCast = buff.Count
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower():find("riventricleave") then 
		QCast = 0
	end
end)		

OnProcessWaypoint(function(unit, waypointProc)
	if unit.isHero and waypointProc.dashspeed > unit.ms and not unit.isMe and unit.team == 300 - myHero.team then
		local dashTargetPos = waypointProc.position
		if RivenMenu.AGC.AGCW:Value() then	
			if GetDistance(myHero, dashTargetPos) < GetCastRange(myHero, _W) and Ready(_W) then
				DelayAction(function()
					CastSpell(_W)
				end, (GetDistance(myHero, unit) / waypointProc.dashspeed) - 0.2)	
			end	
		end
	end
end)

print("Thank You For Using Eternal Riven, Have Fun :D")
