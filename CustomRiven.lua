if GetObjectName(GetMyHero()) ~= "Riven" then return end

local ver = "0.06"

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Akali", "Toshibiotro")

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
RivenMenu.Combo:Boolean("CH", "Use R Hydra", true)
RivenMenu.Combo:Boolean("CTH", "Use T Hydra", true)
RivenMenu.Combo:Boolean("YGB", "Use GhostBlade", true)

RivenMenu:SubMenu("Harass", "Harass")
RivenMenu.Harass:Boolean("HQ", "Use Q", true)
RivenMenu.Harass:Boolean("HW", "Use W", true)
RivenMenu.Harass:Boolean("HE", "Use E", true)
RivenMenu.Harass:Boolean("HH", "Use Hydra")

RivenMenu:SubMenu("LaneClear", "LaneClear")
RivenMenu.LaneClear:Boolean("LCQ", "Use Q")
RivenMenu.LaneClear:Boolean("LCW", "Use W")
RivenMenu.LaneClear:Boolean("LCH", "Use Hydra")

RivenMenu:SubMenu("LastHit", "LastHit")
RivenMenu.LastHit:Boolean("LHQ", "Use Q", true)
RivenMenu.LastHit:Boolean("LHW", "Use W", true)

RivenMenu:SubMenu("KillSteal", "KillSteal")
RivenMenu.KillSteal:Boolean("KSQ", "Use Q", true)
RivenMenu.KillSteal:Boolean("KSW", "Use W", true)
RivenMenu.KillSteal:Boolean("KSR", "Use R", true)

RivenMenu:SubMenu("Misc", "Misc")
RivenMenu.Misc:Boolean("CAE", "Q Cancel with Emote", true)
RivenMenu.Misc:Boolean("WJ", "WallJump, Hold T", true)
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

RivenMenu:SubMenu("GC", "GapClose")
RivenMenu.GC:Boolean("GCQ", "Use Q", true)
RivenMenu.GC:Boolean("GCE", "Use E", true)

RivenMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"}}
RivenMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
RivenMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

function WDmg(unit) return CalcDamage(myHero,unit, 20 + 30 * GetCastLevel(myHero,_W) + GetBonusDmg(myHero) * 1, 0) end
function QDmg(unit) return CalcDamage(myHero,unit, -10 + 20 * GetCastLevel(myHero,_Q) + (myHero.totalDamage) * ((35 + 5 * GetCastLevel(myHero, _Q)) / 100), 0) end
local QCast = 0

OnTick(function ()

	local mousePos = GetMousePos()
	local target = GetCurrentTarget()
	local RStats = {delay = 0.05, range = 900, radius = 100, speed = 1600}
	local IDamage = (50 + (20 * GetLevel(myHero)))
	local RDmg = getdmg("R",target,myHero,GetCastLevel(myHero, _R))
	local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
	
	if RivenMenu.Misc.AutoLevel:Value() then
		spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end
	
	if Mix:Mode() == "Combo" then
	
		if RivenMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, 600) then
			if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
				if Ready(_Q) then
					CastSpell(_R)
				end
			end
		end	
		
		if RivenMenu.Combo.YGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 600) then
			CastSpell(YGB)
		end
		
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 125) then
				CastSpell(_W)
			end
		end
				
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, 200) then
				CastSpell(_W)
			end
		end

		if RivenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end	
	end	

	if Mix:Mode() == "Harass" then
		
		if RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, 125) then
				CastSpell(_W)
		end

		if RivenMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, 325) then
			CastSkillShot(_E, mousePos)
		end	
	end		
	
	if Mix:Mode() == "LaneClear" then
	
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 125, MINION_ENEMY) > 1 then
				CastSpell(_W)
			end
		end	
		
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.LaneClear.LCW:Value() and Ready(_W) and MinionsAround(myHero, 200, MINION_ENEMY) > 1 then
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
			if RivenMenu.LastHit.LHW:Value() and Ready(_W) and ValidTarget(closeminion, 125) then
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
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 125) then
				if GetCurrentHP(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end		

		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, 200) then
				if GetCurrentHP(enemy) < WDmg(enemy) then
					CastSpell(_W)
				end
			end
		end	
		
		if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 260) then
				if GetCurrentHP(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, target)
				end
			end
		end
			
		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 335) then
				if GetCurrentHP(enemy) < QDmg(enemy) then
					CastSkillShot(_Q, target)
				end
			end
		end

		if GetCastName(myHero, _R):lower():find("rivenizunablade") then
			if RivenMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, 900) then
				if GetCurrentHP(enemy) < RDmg then
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
		if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, 125) > RivenMenu.Misc.AWC:Value() then
			CastSpell(_W)
		end
	end

	if GetCastName(myHero, _R):lower():find("rivenizunablade") then
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
	if RivenMenu.Misc.WJ:Value() then
		if KeyIsDown(84) then
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
	end
end)

OnDraw(function() 
	local pos = GetOrigin(myHero)
	if RivenMenu.Draw.DQ:Value() then DrawCircle(pos, 260, 1, 25, GoS.White) end
	if RivenMenu.Draw.DAA:Value() then DrawCircle(pos, 125, 1, 25, GoS.Green) end
	if RivenMenu.Draw.DW:Value() then DrawCircle(pos, 125, 1, 25, GoS.Blue) end
	if RivenMenu.Draw.DE:Value() then DrawCircle(pos, 325, 1, 25, GoS.Yellow) end
	if RivenMenu.Draw.DR:Value() then DrawCircle(pos, 900, 1, 25, GoS.Cyan) end
end)	

OnProcessSpell(function(unit, spell)
	local target = GetCurrentTarget()
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
				DelayAction(function()
					if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 260) then
						CastSkillShot(_Q, spell.target)	
					end
				end, spell.windUpTime)
			end
		end
	end	
	
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if GetCastName(myHero, _R):lower():find("rivenizunablade") then
				DelayAction(function()			
					if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, 335) then
						CastSkillShot(_Q, spell.target)
					end
				end, spell.windUpTime)
			end
		end
	end	

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Harass" then
			DelayAction(function()
				if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
					if RivenMenu.Harass.HQ:Value() then
						if Ready(_Q) and ValidTarget(target, 260) then
							CastSkillShot(_Q, spell.target)
						end	
					end
				end
			end, spell.windUpTime)
		end
	end	

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			DelayAction(function()
				if RivenMenu.LaneClear.LCQ:Value() then
					if not GetCastName(myHero, _R):lower():find("rivenizunablade") then
						for _,closeminion in pairs(minionManager.objects) do
							if Ready(_Q) and ValidTarget(closeminion, 260) then
								CastSkillShot(_Q, closeminion)
							end
						end
					end					
				end
			end, spell.windUpTime)
		end
	end

	if unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion then
		if Mix:Mode() == "LaneClear" then
			DelayAction(function()
				if RivenMenu.LaneClear.LCQ:Value() then
					if GetCastName(myHero, _R):lower():find("rivenizunablade") then
						for _,closeminion in pairs(minionManager.objects) do
							if Ready(_Q) and ValidTarget(closeminion, 335) then
								CastSkillShot(_Q, closeminion)
							end
						end
					end					
				end
			end, spell.windUpTime)
		end
	end
	
	if unit.isMe and spell.name:lower():find("riventricleave") then 
		Mix:ResetAA()	
	end
	
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
end)

OnAnimation(function(unit,animation)
	if unit.isMe and RivenMenu.Misc.CAE:Value() and animation:find("Spell1") then
		DelayAction(function()
			CastEmote(EMOTE_DANCE)
		end, 0.02)
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

print("Thank You For Using Custom Riven, Have Fun :D")
