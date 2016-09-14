local EternalAIOVersion = 0.01
local EternalAIOChamps = {"Akali", "Malphite", "Riven", "Irelia"}

if not table.contains(EternalAIOChamps, myHero.charName) then print("EternalAIO Does Not Support: "..myHero.charName) return end

function AutoUpdate(data)
    if tonumber(data) > tonumber(EternalAIOVersion) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAIO.lua", SCRIPT_PATH .. "EternalAIO.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end
GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAIO.version", AutoUpdate)
	

local OpenPredChamps = {"Malphite", "Riven", "Irelia"}
local MapPosChamps = {"Riven"}

if table.contains(OpenPredChamps, myHero.charName) then require("OpenPredict") end
if table.contains(MapPosChamps, myHero.charName) then require("MapPositionGoS") end
require("DamageLib")
require("ChallengerCommon")

if not FileExist(COMMON_PATH.. "Analytics.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function()
	require("Analytics")	
	Analytics("EternalAIO ", "Toshibiotro")
	end)
else
	require("Analytics")
	Analytics("EternalAIO ", "Toshibiotro")
end



local EternalAIOSkins = {
["Akali"] = {"Classic", "Stinger", "Crimson", "All-Star", "Nurse", "BloodMoon", "Silverfang", "Headhunter"},
["Malphite"] = {"Classic", "Shamrock", "Coral Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"},
["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"},
["Irelia"] = {"Classic", "NightBlade", "Aviator", "Infiltrator", "FrostBlade", "Order Of The Lotus"}
}

local EternalMenu = Menu("EternalTS", "Eternal Target Selector")
EternalMenu:Info("idk", "Left Click To Pick A Target")
EternalMenu:Boolean("DT", "Draw Current Target", true)

local WindingUp = false
local WindingDown = false
local LastAttack = 0
local AnimationTime = 0
local ctarget = nil
local spellorder={
[2]={_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W},
[3]={_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E},
[4]={_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E},
[5]={_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q},
[6]={_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W},
[7]={_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
}
local CCType = {[5] = "Stun", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local AAResets = {"riventricleave"}
local EMin = {}
local AMin = {}
local JMin = {}
local EJMin = {}
local Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
local Flash = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil))
local Smite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonersmite") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonersmite") and SUMMONER_2 or nil))
function SmiteDmg() return (({[1]=390,[2]=410,[3]=430,[4]=450,[5]=480,[6]=510,[7]=540,[8]=570,[9]=600,[10]=640,[11]=680,[12]=720,[13]=760,[14]=800,[15]=850,[16]=900,[17]=950,[18]=1000})[GetLevel(myHero)]) end	

OnCreateObj(function(object)
	if object.isMinion then
		if object.team == MINION_ENEMY then
			table.insert(EMin, object)
			table.insert(EJMin, object)
		end
		
		if object.team == MINION_JUNGLE then
			table.insert(JMin, object)
			table.insert(EJMin, object)
		end
		
		if object.team == MINION_ALLY then
			table.insert(AMin, object)
		end
	end		
end)

OnObjectLoad(function(object)
	if object.isMinion then
		if object.team == MINION_ENEMY then
			table.insert(EMin, object)
			table.insert(EJMin, object)
		end
		
		if object.team == MINION_JUNGLE then
			table.insert(JMin, object)
			table.insert(EJMin, object)
		end
		
		if object.team == MINION_ALLY then
			table.insert(AMin, object)
		end
	end		
end)

OnDeleteObj(function(object)
	if object.isMinion then
		for _, EMinion in pairs(EMin) do
			if EMinion == object then
				table.remove(EMin, _)
			end
		end		

		for _, JMinion in pairs(JMin) do
			if JMinion == object then
				table.remove(JMin, _)
			end
		end	

		for _, AMinion in pairs(AMin) do
			if AMinion == object then
				table.remove(AMin, _)
			end	
		end	
		
		for _, EJMinion in pairs(EJMin) do
			if EJMinion == object then
				table.remove(EJMin, _)
			end
		end		
	end
end)	

function CanAttack()
	if not WindingUp and GetTickCount() + (GetLatency() * 0.5) >= LastAttack + (AnimationTime * 1000) then
		return true
		else
		return false
	end
end

OnTick(function()
	if CanAttack() then
		WindingDown = false
	end
end)	

OnProcessSpell(function(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") then -- or table.contains(AltAA, spell.name:lower())
			WindingUp = true
			WindingDown = false
			AnimationTime = spell.animationTime
			LastAttack = GetTickCount()
		end

		if table.contains(AAResets, spell.name:lower()) then
			LastAttack = 0
			WindingUp = false
			WindingDown = false
		end
	end
end)

OnProcessSpellComplete(function(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") then --or table.contains(AltAA, spell.name:lower())
			WindingUp = false
			WindingDown = true
		end	
	end
end)	

OnAnimation(function(unit, animation)
	if unit.isMe and WindingUp == true then
		if animation:lower():find("run") or animation:lower():find("idle") then
			WindingUp = false
			WindingDown = false
			LastAttack = 0
		end
	end
end)

OnWndMsg(function(msg, key)
	if msg == WM_LBUTTONDOWN then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 3000) and GetDistance(enemy, GetMousePos()) <= enemy.boundingRadius * 2 then
				ctarget = enemy
				break
				else ctarget = nil
			end			
		end		
	end		
end)

function truehpap(unit)
	return unit.health + unit.shieldAD + unit.shieldAP
end

function truehpad(unit)
	return unit.health + unit.shieldAD
end	

function Mode()
	if IOW_Loaded then
		return IOW:Mode()
	elseif DAC_Loaded then
		return DAC:Mode()
	elseif PW_Loaded then
		return PW:Mode()
	elseif GoSWalkLoaded and GoSWalk.CurrentMode then
		return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
	elseif AutoCarry_Loaded then
		return DACR:Mode()
	end
	return ""
end

function ResetAA()
	if _G.IOW_Loaded then
		return IOW:ResetAA()
	elseif _G.PW_Loaded then
        return PW:ResetAA()
	elseif _G.DAC_Loaded then
        return DAC:ResetAA()
	elseif _G.AutoCarry_Loaded then
        return DACR:ResetAA()
	elseif _G.SLW_Loaded then
        return SLW:ResetAA()
	elseif _G.GoSWalkLoaded then
		return _G.GoSWalk:ResetAttack()
    end
end

class "Akali"

function QDmg(unit) return getdmg("Q", unit, myHero, GetCastLevel(myHero, _Q)) end
function Q2Dmg(unit) return AADmg(unit) + CalcMagicalDamage(myHero, unit, 20 + 25 * GetCastLevel(myHero, _Q) + myHero.ap * 0.5) end
function EDmg(unit) return getdmg("E", unit, myHero, GetCastLevel(myHero, _E)) end
function RDmg(unit) return getdmg("R", unit, myHero, GetCastLevel(myHero, _R)) end
function AADmg(unit)
	local revolver = GetItemSlot(myHero, 3145)
	local revolverd = ({75,79,83,88,92,97,101,106,110,115,119,124,128,132,137,141,146,150})[myHero.level]
	local TH = GetItemSlot(myHero, 3748)
	local Shen = GetItemSlot(myHero, 3057)
	local Lich = GetItemSlot(myHero, 3100)
	if Shen > 0 and (sheen or CanUseSpell(myHero, Shen) ~= ON_COOLDOWN) then sbonus = CalcPhysicalDamage(myHero, unit, GetBaseDamage(myHero)) else sbonus = 0 end
	if Lich > 0 and (sheen or CanUseSpell(myHero, Lich) ~= ON_COOLDOWN) then lbonus = CalcMagicalDamage(myHero, unit, (GetBaseDamage(myHero) * 0.75) + (myHero.ap * 0.5)) else lbonus = 0 end
	if TH > 0 then thbonus = CalcPhysicalDamage(myHero, unit, (5 + (GetMaxHP(myHero) * 0.01))) else thbonus = 0 end
	if revolver > 0 and CanUseSpell(myHero, revolver) ~= ON_COOLDOWN then rbonus = CalcMagicalDamage(myHero, unit, revolverd) else rbonus = 0 end
	return CalcPhysicalDamage(myHero, unit, myHero.totalDamage) + CalcMagicalDamage(myHero, unit, myHero.totalDamage * (0.06 + ((myHero.ap / 6) * 0.01))) + sbonus + lbonus + thbonus + rbonus
end

function Akali:RStack() return GetSpellData(myHero, _R).ammo end	
	
local QRange = GetCastRange(myHero, _Q) + myHero.boundingRadius
local ERange = GetCastRange(myHero, _E)
local RRange = GetCastRange(myHero, _R) + myHero.boundingRadius
local AARange = GetRange(myHero) + myHero.boundingRadius * 2
local WRange = GetCastRange(myHero, _W)
local target = nil
local lastmovement = 0

function Akali:__init()
	
	AkaliMenu = Menu("Akali", "Akali")
	AkaliMenu:SubMenu("Combo", "Combo")
	AkaliMenu.Combo:Boolean("CQ", "Use Q", true)
	AkaliMenu.Combo:Boolean("CE", "Use E", true)
	AkaliMenu.Combo:Boolean("CR", "Use R", true)
	AkaliMenu.Combo:Boolean("H", "Use Hydras", true)
	AkaliMenu.Combo:Boolean("HTGB", "Use Gunblade", true)
	AkaliMenu.Combo:Boolean("BWC", "Use Bilgewater Cutlass", true)
	AkaliMenu.Combo:Slider("CMM", "Min Energy to Use Combo", 0, 0, 200, 10)
	
	AkaliMenu:SubMenu("Harass", "Harass")
	AkaliMenu.Harass:Boolean("HQ", "Use Q", true)
	AkaliMenu.Harass:Boolean("HE", "Use E", true)
	AkaliMenu.Harass:Slider("HMM", "Min Energy To Harass", 50, 0, 200, 10)
	
	AkaliMenu:SubMenu("LaneClear", "LaneClear")
	AkaliMenu.LaneClear:Boolean("LCQ", "Use Q", true)
	AkaliMenu.LaneClear:Boolean("LCE", "Use E", true)
	AkaliMenu.LaneClear:Slider("LCMM", "Min Energy to LaneClear", 100, 0, 200, 10)
	
	AkaliMenu:SubMenu("JungleClear", "JungleClear")
	AkaliMenu.JungleClear:Boolean("JCQ", "Use Q", true)
	AkaliMenu.JungleClear:Boolean("JCE", "Use E", true)
	AkaliMenu.JungleClear:Slider("JCMM", "Min Energy To JungleClear", 100, 0, 200, 10)
	
	AkaliMenu:SubMenu("LastHit","LastHit")
	AkaliMenu.LastHit:Boolean("LHQ", "Use Q", true)
	AkaliMenu.LastHit:Boolean("LHE", "Use E", true)
	AkaliMenu.LastHit:Slider("LHMM", "Min Energy to Use Last Hit",0,0,200,10)
	AkaliMenu.LastHit:Boolean("ALH", "Auto Last Hit", true)
	AkaliMenu.LastHit:Slider("ALHMM", "Min Energy to Use Auto Last Hit", 0, 0, 200, 10)
	
	AkaliMenu:SubMenu("KillSteal", "KillSteal")
	AkaliMenu.KillSteal:Boolean("KSQ", "KillSteal with Q", true)
	AkaliMenu.KillSteal:Boolean("KSE", "KillSteal with E", true)
	AkaliMenu.KillSteal:Boolean("KSR", "KillSteal with R", true)
	
	AkaliMenu:SubMenu("Misc", "Misc")
	AkaliMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
	AkaliMenu.Misc:Boolean("AW", "Use Auto W", true)	
	AkaliMenu.Misc:Slider("AWC", "Min Health for Auto W", 20, 5, 90, 2)
	AkaliMenu.Misc:Boolean("AWE", "Use Auto W on X Enemies", true)
	AkaliMenu.Misc:Slider("AWEC", "X Enemies to Cast Auto W", 3, 1, 5, 1)
	if Ignite ~= nil then
		AkaliMenu.Misc:Boolean("AI", "Auto Ignite", true)
	end	
	AkaliMenu.Misc:Boolean("AZ", "Auto Zhonyas", true)
	AkaliMenu.Misc:Slider("AZC", "HP to Auto Zhonyas", 10, 1, 100, 1)
	
	AkaliMenu:SubMenu("Draw", "Drawings")
	AkaliMenu.Draw:Boolean("DAA", "Draw AA Range", true)
	AkaliMenu.Draw:Boolean("DQ", "Draw Q Range", true)
	AkaliMenu.Draw:Boolean("DW", "Draw W Range", true)
	AkaliMenu.Draw:Boolean("DWP", "Draw W Position", true)
	AkaliMenu.Draw:Boolean("DE", "Draw E Range", true)
	AkaliMenu.Draw:Boolean("DR", "Draw R Range", true)
	AkaliMenu.Draw:Boolean("DD", "Draw Damage", true)
	
	AkaliMenu:SubMenu("Escape", "Escape")
	AkaliMenu.Escape:Boolean("ER", "Use R", true)
	
	AkaliMenu:SubMenu("Keys", "KeyBindings")
	AkaliMenu.Keys:KeyBinding("Escape", "Escape", string.byte("G"))
	
	AkaliMenu:SubMenu("SkinChanger", "SkinChanger")	
	
	AkaliMenu.SkinChanger:DropDown('Skin', myHero.charName.. " Skins", 1, EternalAIOSkins[myHero.charName], HeroSkinChanger, true)
	AkaliMenu.SkinChanger.Skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(EternalAIOSkins[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
	                
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)
	OnUpdateBuff(function(unit, buff) self:UBuff(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:RBuff(unit, buff) end)
end	

function Akali:Combo(target)
	if not WindingUp and GetCurrentMana(myHero) >= AkaliMenu.Combo.CMM:Value() then
		if AkaliMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end

		if AkaliMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) and target.distance > AARange then
			CastSpell(_E)
		end
	end	
	
	if not WindingUp and (target.distance > AARange or GetCurrentMana(myHero) < 50 or GetPercentHP(myHero) <= 30) then
		if AkaliMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, RRange) then
			CastTargetSpell(target, _R)
		end
	end

	if GetPercentHP(myHero) > 15 and GetPercentHP(target) <= 85 and GetPercentHP(target) >= 15 then
		self:CastShit(target)
	end
end

function Akali:Harass(target)
	if not WindingUp and GetCurrentMana(myHero) >= AkaliMenu.Harass.HMM:Value() then
		if AkaliMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end
	
		if AkaliMenu.Harass.HQ:Value() and Ready(_E) and ValidTarget(target, ERange) and target.distance > AARange then
			CastSpell(_E)
		end	
	end	
end

function Akali:LaneClear()
	self:LastHit()
	if not WindingUp and GetCurrentMana(myHero) >= AkaliMenu.LaneClear.LCMM:Value() then
		for _, minion in pairs(EMin) do
			if AkaliMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				CastTargetSpell(minion, _Q)
			end
		
			if AkaliMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
				CastSpell(_E)
			end
		end
	end		
end

function Akali:JungleClear()
	for _, camp in pairs(JMin) do
		if not WindingUp and GetCurrentMana(myHero) >= AkaliMenu.JungleClear.JCMM:Value() then
			if AkaliMenu.JungleClear.JCQ:Value() and Ready(_Q) and ValidTarget(camp, QRange) and not camp.name:lower():find("mini") then
				CastTargetSpell(camp, _Q)
			end

			if AkaliMenu.JungleClear.JCE:Value() and Ready(_E) and ValidTarget(camp, ERange) then
				CastSpell(_E)
			end
		end
	end		
end

function Akali:LastHit()
	for _, minion in pairs(EMin) do
		if GetCurrentMana(myHero) >= AkaliMenu.LastHit.LHMM:Value() then
			if AkaliMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				if minion.health - GetDamagePrediction(minion, 0.175 + (minion.distance / 1000) - (GetLatency() * 0.001)) <= QDmg(minion) then
					if WindingDown or not WindingUp and minion.distance > AARange then
						CastTargetSpell(minion, _Q)
					end
				end
			end
			
			if AkaliMenu.LastHit.LHE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
				if minion.health - GetDamagePrediction(minion, 0.25) <= EDmg(minion) then
					if WindingDown or not WindingUp and minion.distance > AARange then
						CastSpell(_E)
					end	
				end
			end		
		end	
	end		
end

function Akali:AutoLastHit()
	if not AkaliMenu.LastHit.ALH:Value() or Mode() ~= "" then return end
	for _, minion in pairs(EMin) do
		if not WindingUp and GetCurrentMana(myHero) >= AkaliMenu.LastHit.ALHMM:Value() then
			if Ready(_Q) and ValidTarget(minion, QRange) then
				if minion.health - GetDamagePrediction(minion, (0.175 + (minion.distance / 1000)) - (GetLatency() * 0.001)) <= QDmg(minion) then
					CastTargetSpell(minion, _Q)
				end
			end
				
			if Ready(_E) and ValidTarget(minion, ERange) then
				if minion.health - GetDamagePrediction(minion, 0.25 - (GetLatency() * 0.001)) <= EDmg(minion) then
					CastSpell(_E)
				end
			end
		end
	end
end	
	
function Akali:Escape()
	MoveToXYZ(GetMousePos())
	if AkaliMenu.Escape.ER:Value() and Ready(_R) then
		for _, enemy in pairs(GetEnemyHeroes()) do
			for _, minion in pairs(EMin) do
				if ValidTarget(enemy, 1000) and ValidTarget(minion, RRange) then
					if GetDistance(minion, enemy) > enemy.distance then
						CastTargetSpell(minion, _R)
					end
				end
			end
		end
	end			
end

function Akali:KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if AkaliMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, QRange) then
			if truehpap(enemy) <= QDmg(enemy) then
				CastTargetSpell(enemy, _Q)
			end
		end
		
		if AkaliMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, ERange) then
			if truehpad(enemy) <= EDmg(enemy) then
				CastSpell(_E)
			end	
		end
		
		if AkaliMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, RRange) then
			if truehpap(enemy) <= RDmg(enemy) then
				CastTargetSpell(enemy, _R)
			end		
		end
		
		if AkaliMenu.KillSteal.KSQ:Value() and AkaliMenu.KillSteal.KSE:Value() and ValidTarget(enemy, ERange) and Ready(_Q) and Ready(_E) then
			if truehpap(enemy) <= EDmg(enemy) + QDmg(enemy) then
				CastTargetSpell(enemy, _Q)
				DelayAction(function()
					CastSpell(_E)
				end, 0.175 - (GetLatency() * 0.001))	
			end
		end

		if AkaliMenu.KillSteal.KSR:Value() and AkaliMenu.KillSteal.KSE:Value() and ValidTarget(enemy, RRange) and Ready(_E) and Ready(_R) then
			if truehpap(enemy) <= EDmg(enemy) + RDmg(enemy) then
				CastTargetSpell(enemy, _R)
				DelayAction(function()
					CastSpell(_E)
				end, (enemy.distance / 2000) - (GetLatency() * 0.001))
			end
		end		
				
		
		if AkaliMenu.KillSteal.KSQ:Value() and AkaliMenu.KillSteal.KSE:Value() and AkaliMenu.KillSteal.KSR:Value() and Ready(_Q) and Ready(_R) and Ready(_E) and ValidTarget(enemy, RRange) then
			if truehpap(enemy) <= QDmg(enemy) + Q2Dmg(enemy) + EDmg(enemy) + RDmg(enemy) then
				CastTargetSpell(enemy, _R)
				DelayAction(function()
					CastTargetSpell(enemy, _Q)
					DelayAction(function()
						CastSpell(_E)
					end, 0.175 - (GetLatency() * 0.001))	
				end, (enemy.distance / 2000) - (GetLatency() * 0.001))	
			end	
		end
		
		if Ignite ~= nil and AkaliMenu.Misc.AI:Value() and Ready(Ignite) and ValidTarget(enemy, 600) then
			if truehpad(enemy) <= (50 + (20 * GetLevel(myHero))) + (GetHPRegen(enemy) * 3) then
				CastTargetSpell(enemy, Ignite)
			end
		end	
	end		
end		

function Akali:CastHydras()
	local T = GetItemSlot(myHero, 3077)
	local RH = GetItemSlot(myHero, 3074)
	local TH = GetItemSlot(myHero, 3748)
	if T > 0 and Ready(T) and ValidTarget(target, 350) then
		CastSpell(T)
		elseif RH > 0 and Ready(RH) and ValidTarget(target, 350) then
		CastSpell(RH)
		elseif TH > 0 and Ready(TH) and ValidTarget(target, AARange) then
		CastSpell(TH)
	end
end	

function Akali:CastShit()
	local Bilge = GetItemSlot(myHero, 3144)
	local HTGB = GetItemSlot(myHero, 3146)
	if AkaliMenu.Combo.BWC:Value() and Ready(Bilge) and ValidTarget(target, 550) then
		CastTargetSpell(target, Bilge)
		elseif AkaliMenu.Combo.HTGB:Value() and Ready(HTGB) and ValidTarget(target, 650) then
		CastTargetSpell(target, HTGB)
	end	
end

function Akali:CastZ()
	local Zh = GetItemSlot(myHero, 3157)
	if Zh > 0 and Ready(Zh) then
		CastSpell(Zh)
	end	
end

function Akali:Stuff()
	if AkaliMenu.Misc.AutoLevel:Value() ~= 1 and GetLevelPoints(myHero) > 0 then
		LevelSpell(spellorder[AkaliMenu.Misc.AutoLevel:Value()][GetLevel(myHero)])
	end
	
	if AkaliMenu.Misc.AZ:Value() and GetPercentHP(myHero) <= AkaliMenu.Misc.AZC:Value() and EnemiesAround(myHero, 800) > 0 then
		self:CastZ()
	end
	
	if AkaliMenu.Misc.AW:Value() and Ready(_W) and GetPercentHP(myHero) <= AkaliMenu.Misc.AWC:Value() and EnemiesAround(myHero, 800) > 0 then
		CastSkillShot(_W, myHero)
	end

	if AkaliMenu.Misc.AWE:Value() and Ready(_W) and EnemiesAround(myHero, 650) >= AkaliMenu.Misc.AWEC:Value() then
		CastSkillShot(_W, myHero)
	end
end

function Akali:Tick()
	if myHero.dead then return end
	if ctarget ~= nil and ctarget.valid then
		target = ctarget
	end
	
	if ctarget == nil or ctarget.dead then
		ctarget = nil
		target = GetCurrentTarget()
	end
		
	if Mode() == "Combo" then
		self:Combo(target)
	end
	
	if Mode() == "Harass" then
		self:Harass(target)
	end	
	
	if Mode() == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	end

	if Mode() == "LastHit" then
		self:LastHit()
	end
	
	if AkaliMenu.Keys.Escape:Value() then
		self:Escape()
	end	
	
	self:KillSteal()
	self:Stuff()
	self:AutoLastHit()
end	

function Akali:Draw()
	local Bilge = GetItemSlot(myHero, 3144)
	local HTGB = GetItemSlot(myHero, 3146)
	local Damage, QDamage, EDamage, RDamage = 0, 0, 0, 0
	if AkaliMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 2, 25, GoS.White) end
	if AkaliMenu.Draw.DQ:Value() then DrawCircle(myHero, QRange, 2, 25, GoS.Cyan) end
	if AkaliMenu.Draw.DW:Value() then DrawCircle(myHero, WRange, 2, 25, GoS.Cyan) end
	if AkaliMenu.Draw.DWP:Value() and GetDistance(myHero, GetMousePos()) < WRange then DrawCircle(GetMousePos(), 400, 2, 25, GoS.Cyan) end
	if AkaliMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 2, 25, GoS.Cyan) end
	if AkaliMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 2, 25, GoS.Cyan) end
	if EternalMenu.DT:Value() and target ~= nil then DrawCircle(target, target.boundingRadius * 2, 2, 25, GoS.Red) end
	
	if AkaliMenu.Draw.DD:Value() then
		for _, enemies in pairs(GetEnemyHeroes()) do
			if Bilge > 0 and Ready(Bilge) then BDamage = CalcMagicalDamage(myHero, enemies, 100) else BDamage = 0 end
			if HTGB > 0 and Ready(HTGB) then GBDamage = CalcMagicalDamage(myHero, enemies, 250 + (myHero.ap * 0.3)) else GBDamage = 0 end
			if Ignite ~= nil and Ready(Ignite) then IDamage = (50 + (20 * GetLevel(myHero))) + (GetHPRegen(enemies) * 3) else IDamage = 0 end
			if Ready(_Q) then QDamage = QDmg(enemies) + Q2Dmg(enemies) else QDamage = 0 end
			if Ready(_E) then EDamage = EDmg(enemies) else EDamage = 0 end
			if Ready(_R) then RDamage = RDmg(enemies) * self:RStack() else RDamage = 0 end
			Damage = QDamage*2 + EDamage*2 + RDamage + BDamage + GBDamage + IDamage
			if Damage > enemies.health then Damage = enemies.health end
			DrawDmgOverHpBar(enemies, enemies.health, Damage, 0, GoS.White)
		end	
	end
end	

function Akali:SpellComplete(unit, spell)
	if unit.isMe and spell.target.isHero and spell.target.valid then 
		if spell.name:lower():find("attack") and AADmg(spell.target) < truehpad(spell.target) then
			if Mode() == "Combo" then
				if AkaliMenu.Combo.H:Value() then
					self:CastHydras()
				end
		
				if AkaliMenu.Combo.CE:Value() and Ready(_E) then
					CastSpell(_E)
				end	
			end
			
			if Mode() == "Harass" then
				if AkaliMenu.Harass.HE:Value() and Ready(_E) then
					CastSpell(_E)
				end
			end		
		end	
	end	
end

function Akali:UBuff(unit, buff)
	if unit.isMe and buff.Name:lower():find("sheen") then
		sheen = true
	end	
end

function Akali:RBuff(unit, buff)
	if unit.isMe and buff.Name:lower():find("sheen") then
		sheen = false
	end	
end

function Akali:IssueOrder(order)
	if order.flag == 2 and AkaliMenu.Keys.EK:Value() then
		if GetGameTimer() - lastmovement < 1/6 then
			BlockOrder()
			else
			lastmovement = GetGameTimer()
		end
	end
end

class "Malphite"

function QDmg(unit) return getdmg("Q", unit, myHero, GetCastLevel(myHero, _Q)) end
function EDmg(unit) return getdmg("E", unit, myHero, GetCastLevel(myHero, _E)) end
function RDmg(unit) return getdmg("R", unit, myHero, GetCastLevel(myHero, _R)) end

local QRange = GetCastRange(myHero, _Q) + myHero.boundingRadius
local AARange = GetRange(myHero) + (myHero.boundingRadius * 2) 
local ERange = GetCastRange(myHero, _E)
local RRange = GetCastRange(myHero, _R) + myHero.boundingRadius

function Malphite:__init()
	MalphiteMenu = Menu("Malphite", "Malphite")
	MalphiteMenu:SubMenu("Combo","Combo")
	MalphiteMenu.Combo:Boolean("CQ", "Use Q", true)
	MalphiteMenu.Combo:Boolean("CW", "Use W", true)
	MalphiteMenu.Combo:Boolean("CE", "Use E", true)
	MalphiteMenu.Combo:Boolean("CR", "Use R", true)
	MalphiteMenu.Combo:Slider("CRC", "Min Target HP To R", 70, 0, 100, 1)
	MalphiteMenu.Combo:Slider("CMM", "Min Mana % To Combo",60,0,100,1)

	MalphiteMenu:SubMenu("Harass", "Harass")
	MalphiteMenu.Harass:Boolean("HQ", "Use Q")
	MalphiteMenu.Harass:Boolean("HW", "Use W")
	MalphiteMenu.Harass:Boolean("HE", "Use E")
	MalphiteMenu.Harass:Slider("HMM", "Min Mana % To Harass",60,0,100,1)

	MalphiteMenu:SubMenu("LastHit", "LastHit")
	MalphiteMenu.LastHit:Boolean("LHQ", "Use Q", true)
	MalphiteMenu.LastHit:Boolean("LHE", "Use E", true)
	MalphiteMenu.LastHit:Slider("LHMM", "Min Mana % To LastHit",60,0,100,1)

	MalphiteMenu:SubMenu("LaneClear", "LaneClear")
	MalphiteMenu.LaneClear:Boolean("LCQ", "Use Q", true)
	MalphiteMenu.LaneClear:Boolean("LCW", "Use W", true)
	MalphiteMenu.LaneClear:Boolean("LCE", "Use E", true)
	MalphiteMenu.LaneClear:Slider("LCMM", "Min Mana % To LaneClear",60,0,100,1)
	
	MalphiteMenu:SubMenu("JungleClear", "JungleClear")
	MalphiteMenu.JungleClear:Boolean("JCQ", "Use Q", true)
	MalphiteMenu.JungleClear:Boolean("JCW", "Use W", true)
	MalphiteMenu.JungleClear:Boolean("JCE", "Use E", true)
	MalphiteMenu.JungleClear:Slider("JCMM", "Min Mana To JungleClear", 50, 0, 100, 1)

	MalphiteMenu:SubMenu("KillSteal", "Killsteal")
	MalphiteMenu.KillSteal:Boolean("KSQ", "Use Q", true)
	MalphiteMenu.KillSteal:Boolean("KSE", "Use E", true)
	MalphiteMenu.Killsteal:Boolean("KSR", "Use R", true)

	MalphiteMenu:SubMenu("Misc", "Misc")
	MalphiteMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
	if Ignite ~= nil then
		MalphiteMenu.Misc:Boolean("AI", "Use Auto Ignite", true)
	end	
	MalphiteMenu.Misc:Boolean("AR", "Auto R on X Enemies", true)
	MalphiteMenu.Misc:Slider("ARC", "Min Enemies to Auto R",3,1,6,1)

	MalphiteMenu:SubMenu("Draw", "Drawings")
	MalphiteMenu.Draw:Boolean("DAA", "Draw AA Range", true)
	MalphiteMenu.Draw:Boolean("DQ", "Draw Q Range", true)
	MalphiteMenu.Draw:Boolean("DW", "Draw W Range", true)
	MalphiteMenu.Draw:Boolean("DE", "Draw E Range", true)
	MalphiteMenu.Draw:Boolean("DR", "Draw R Range", true)
	MalphiteMenu.Draw:Boolean("DRP", "Draw R Position", true)
	MalphiteMenu.Draw:Boolean("DD", "Draw Damage", true)

	MalphiteMenu:SubMenu("SkinChanger", "SkinChanger")
	
	MalphiteMenu.SkinChanger:DropDown('Skin', myHero.charName.. " Skins", 1, EternalAIOSkins[myHero.charName], HeroSkinChanger, true)
	MalphiteMenu.SkinChanger.Skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(EternalAIOSkins[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
	
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpell(function(unit, spell) self:Spell(unit, spell) end)
end

function Malphite:CastR(unit)
	local RStats = {delay = 0.05, range = 1000, radius = 300, speed = 1500 + myHero.ms}
	local RPred = GetCircularAOEPrediction(unit, RStats)
	if RPred.hitChance >= 0.3 then
		CastSkillShot(_R, RPred.castPos)
	end	
end

function Malphite:Combo(target)
	if not WindingUp and GetPercentMP(myHero) >= MalphiteMenu.Combo.CMM:Value() then
		if MalphiteMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end

		if MalphiteMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			CastSpell(_E)
		end
		
		if MalphiteMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, RRange) then
			if GetPercentHP(target) >= MalphiteMenu.Combo.CRC:Value() then
				self:CastR(target)
			end	
		end	
	end		
end

function Malphite:Harass(target)
	if not WindingUp and GetPercentMP(myHero) >= MalphiteMenu.Harass.HMM:Value() then
		if MalphiteMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end

		if MalphiteMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			CastSpell(_E)
		end
	end		
end

function Malphite:LaneClear()
	self:LastHit()
	for _, minion in pairs(EMin) do
		if not WindingUp and GetPercentMP(myHero) >= MalphiteMenu.LaneClear.LCMM:Value() then
			if MalphiteMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				CastTargetSpell(minion, _Q)
			end
			
			if MalphiteMenu.LaneClear.LCW:Value() and Ready(_E) and ValidTarget(minion, AARange) then
				CastSpell(_W)
			end
			
			if MalphiteMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
				CastSpell(_E)
			end	
		end	
	end
end

function Malphite:JungleClear()
	for _, camp in pairs(JMin) do
		if not camp.name:lower():find("mini") and not WindingUp and GetPercentMP(myHero) >= MalphiteMenu.JungleClear.JCMM:Value() then
			if MalphiteMenu.JungleClear.JCQ:Value() and Ready(_Q) and ValidTarget(camp, QRange) then	
				CastTargetSpell(camp, _Q)
			end

			if MalphiteMenu.JungleClear.JCW:Value() and Ready(_W) and ValidTarget(camp, AARange) then
				CastSpell(_W)
			end
				
			if MalphiteMenu.JungleClear.JCE:Value() and Ready(_E) and ValidTarget(camp, ERange) then
				CastSpell(_E)
			end
		end		
	end
end

function Malphite:LastHit()
	for _, minion in pairs(EMin) do
		if GetPercentMP(myHero) >= MalphiteMenu.LastHit.LHMM:Value() then
			if MalphiteMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
				if WindingDown or not WindingUp and minion.distance > AARange then
					if minion.health - GetDamagePrediction(minion, 0.25 + (minion.distance / 2000)) <= QDmg(minion) then
						CastTargetSpell(minion, _Q)
					end
				end
			end
			
			if MalphiteMenu.LastHit.LHE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
				if WindingDown or not WindingUp and minion.distance > AARange then
					if minion.health - GetDamagePrediction(minion, 0.25) <= EDmg(minion) then
						CastSpell(_E)
					end
				end		
			end
		end		
	end
end

function Malphite:KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MalphiteMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, QRange) then
			if QDmg(enemy) >= truehpap(enemy) then
				CastTargetSpell(enemy, _Q)
			end
		end

		if MalphiteMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, ERange) then
			if EDmg(enemy) >= truehpad(enemy) then
				CastSpell(_E)
			end
		end

		if MalphiteMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, RRange) then
			if RDmg(enemy) >= truehpap(enemy) then
				CastR(enemy)
			end	
		end
		
		if Ignite ~= nil and MalphiteMenu.Misc.AI:Value() and Ready(Ignite) and ValidTarget(enemy, 600) then
			if truehpad(enemy) <= (50 + (20 * GetLevel(myHero))) + (GetHPRegen(enemy) * 3) then
				CastTargetSpell(enemy, Ignite)
			end
		end		
	end
end

function Malphite:Stuff()
	if MalphiteMenu.Misc.AutoLevel:Value() ~= 1 and GetLevelPoints(myHero) > 0 then
		LevelSpell(spellorder[MalphiteMenu.Misc.AutoLevel:Value()][GetLevel(myHero)])
	end
	
	if MalphiteMenu.Misc.AR:Value() and Ready(_R) then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, RRange) then
				local RStats = {delay = 0.05, range = 1000, radius = 300, speed = 1500 + myHero.ms}
				local RPred = GetCircularAOEPrediction(enemy, RStats)
				if EnemiesAround(RPred.castPos, 300) >= MalphiteMenu.Misc.ARC:Value() then
					CastSkillShot(_R, RPred.castPos)
				end
			end
		end		
	end	
end

function Malphite:Tick()
	if myHero.dead then return end
	if ctarget ~= nil and ctarget.valid then
		target = ctarget
	end
	
	if ctarget == nil or ctarget.dead then
		ctarget = nil
		target = GetCurrentTarget()
	end
		
	if Mode() == "Combo" then
		self:Combo(target)
	end
	
	if Mode() == "Harass" then
		self:Harass(target)
	end	
	
	if Mode() == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	end

	if Mode() == "LastHit" then
		self:LastHit()
	end
	
	self:KillSteal()
	self:Stuff()
end	

function Malphite:Draw()
	local QDamage, EDamage, RDamage, Damage = 0, 0, 0, 0
	if MalphiteMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 2, 25, GoS.White) end
	if MalphiteMenu.Draw.DQ:Value() then DrawCircle(myHero, QRange, 2, 25, GoS.Cyan) end
	if MalphiteMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 2, 25, GoS.Cyan) end
	if MalphiteMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 2, 25, GoS.Cyan) end
	if MalphiteMenu.Draw.DRP:Value() then DrawCircle(GetMousePos(), 300, 2, 25, GoS.Cyan) end
	if EternalMenu.DT:Value() and target ~= nil then DrawCircle(target, target.boundingRadius * 2, 2, 25, GoS.Red) end
	
	if MalphiteMenu.Draw.DD:Value() then
		for _, enemies in pairs(GetEnemyHeroes()) do
			if Ready(_Q) then QDamage = QDmg(enemies) else QDamage = 0 end
			if Ready(_E) then EDamage = EDmg(enemies) else EDamage = 0 end
			if Ready(_R) then RDamage = RDmg(enemies) else RDamage = 0 end
			Damage = QDamage + EDamage + RDamage
			if Damage > truehpap(enemies) then Damage = truehpap(enemies) end
			DrawDmgOverHpBar(enemies, truehpap(enemies), Damage, 0, GoS.White)
		end
	end			
end

function Malphite:Spell(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mode() == "Combo" and GetPercentMP(myHero) >= MalphiteMenu.Combo.CMM:Value() then
			if MalphiteMenu.Combo.CW:Value() and Ready(_W) then
				DelayAction(function()
					CastSpell(_W)
				end, (spell.windUpTime * 0.5) - (GetLatency() * 0.001))
			end
		end

		if Mode() == "Harass" and GetPercentMP(myHero) >= MalphiteMenu.Harass.HMM:Value() then
			if MalphiteMenu.Harass.HW:Value() and Ready(_W) then
				DelayAction(function()
					CastSpell(_W)
				end, (spell.windUpTime * 0.5) - (GetLatency() * 0.001))
			end
		end
	end		
end

class "Irelia"

function Sheen2()
	local Sheen = GetItemSlot(myHero, 3057)
	local TriForce = GetItemSlot(myHero, 3078)
	local IceBorn = GetItemSlot(myHero, 3025)
	if Sheen > 0 and CanUseSpell(myHero, Sheen) ~= ON_COOLDOWN then
		return GetBaseDamage(myHero)
		elseif TriForce > 0 and CanUseSpell(myHero, TriForce) ~= ON_COOLDOWN then
		return GetBaseDamage(myHero) * 2
		elseif IceBorn > 0 and CanUseSpell(myHero, IceBorn) ~= ON_COOLDOWN then
		return GetBaseDamage(myHero) * 1.25
	end
	return 0	
end	

function AADmg(unit)
	if WOn then
		return CalcPhysicalDamage(myHero, unit, myHero.totalDamage + Sheen2()) + 15 * GetCastLevel(myHero, _W)
		else
		return CalcPhysicalDamage(myHero, unit, myHero.totalDamage + Sheen2())
	end
end	

function QDmg(unit)
	if WOn then
		return CalcPhysicalDamage(myHero, unit, -10 + 30 * GetCastLevel(myHero, _Q) + (myHero.totalDamage * 1.2) + Sheen2()) + 15 * GetCastLevel(myHero, _W)
		else
		return CalcPhysicalDamage(myHero, unit, -10 + 30 * GetCastLevel(myHero, _Q) + (myHero.totalDamage * 1.2) + Sheen2())
	end	
end

function EDmg(unit)
	return CalcMagicalDamage(myHero, unit, 40 + 40 * GetCastLevel(myHero, _E) + myHero.ap * 0.5)
end

function RDmg(unit)
	return CalcPhysicalDamage(myHero, unit, 40 + 40 * GetCastLevel(myHero, _R) + myHero.ap * 0.5 + GetBonusDmg(myHero) * 0.7)
end	

function IDmg()
	return (50 + (20 * GetLevel(myHero)))
end
	
local CCType = {[5] = "Stun", [8] = "Taunt", [9] = "Polymorph", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression"}
local SheenOn = false
local target = GetCurrentTarget()
local kek = false
local lastmovement = 0
local RStats = {speed = 1600, range = 1065, radius = 120, delay = 0}
local MoveStats = {speed = math.huge, range = math.huge, radius = 1, delay = 1}
local AARange = GetRange(myHero) + (myHero.boundingRadius * 2)
local QRange = GetCastRange(myHero, _Q) + myHero.boundingRadius
local ERange = GetCastRange(myHero, _E) + myHero.boundingRadius
local RRange = GetCastRange(myHero, _R) + myHero.boundingRadius

function Irelia:RLeft() return GetBuffData(myHero, "IreliaTranscendentBladesSpell").Count end

function Irelia:__init()
	
	IreliaMenu = Menu("Irelia", "Irelia")
	IreliaMenu:SubMenu("Combo", "Combo")
	IreliaMenu.Combo:Boolean("CQ", "Use Q", true)
	IreliaMenu.Combo:Boolean("CW", "Use W", true)
	IreliaMenu.Combo:Boolean("CE", "Use E", true)
	IreliaMenu.Combo:DropDown("CEC", "E Logic", 2, {"Always", "Only To Stun"})
	IreliaMenu.Combo:Boolean("I", "Use Items", true)
	IreliaMenu.Combo:Boolean("CR", "Use R", true)
	IreliaMenu.Combo:Slider("CMM", "Min Mana To Combo", 25, 0, 100, 1)

	IreliaMenu:SubMenu("Harass", "Harass")
	IreliaMenu.Harass:Boolean("HQ", "Use Q", true)
	IreliaMenu.Harass:Boolean("HW", "Use W", true)
	IreliaMenu.Harass:Boolean("HE", "Use E", true)
	IreliaMenu.Harass:DropDown("HEC", "E Logic", 2, {"Always", "Only To Stun"})
	IreliaMenu.Harass:Boolean("I", "Use Items", true)
	IreliaMenu.Harass:Slider("HMM", "Min Mana To Harass", 25, 0, 100, 1)

	IreliaMenu:SubMenu("LaneClear", "LaneClear")
	IreliaMenu.LaneClear:Boolean("LCQ", "Use Q", true)
	IreliaMenu.LaneClear:Boolean("LCW", "Use W", true)
	IreliaMenu.LaneClear:Boolean("LCE", "Use E", true)
	IreliaMenu.LaneClear:Boolean("I", "Use Items", true)
	IreliaMenu.LaneClear:Slider("LCMM", "Min Mana To LaneClear", 60, 0, 100, 1)

	IreliaMenu:SubMenu("JungleClear", "JungleClear")
	IreliaMenu.JungleClear:Boolean("JCQ", "Use Q", true)
	IreliaMenu.JungleClear:Boolean("JCW", "Use W", true)
	IreliaMenu.JungleClear:Boolean("JCE", "Use E", true)
	IreliaMenu.JungleClear:Boolean("I", "Use Items", true)
	IreliaMenu.JungleClear:Slider("JCMM", "Min Mana To JungleClear", 50, 0, 100, 1)

	IreliaMenu:SubMenu("LastHit", "LastHit")
	IreliaMenu.LastHit:Boolean("LHQ", "Use Q", true)
	IreliaMenu.LastHit:Boolean("LHE", "Use E", true)
	IreliaMenu.LastHit:Slider("LHMM", "Min Mana To LastHit", 50, 0, 100, 1)

	IreliaMenu:SubMenu("KillSteal", "KillSteal")
	IreliaMenu.KillSteal:Boolean("KSQ", "Use Q", true)
	IreliaMenu.KillSteal:Boolean("KSE", "Use E", true)
	IreliaMenu.KillSteal:Boolean("KSR", "Use R", true)

	IreliaMenu:SubMenu("Misc", "Misc")
	IreliaMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})

	if Ignite ~= nil then
		IreliaMenu.Misc:Boolean("AI", "Auto Ignite", true)
	end
	IreliaMenu.Misc:Boolean("QSS", "Auto QSS", true)
	IreliaMenu.Misc:Slider("QSSC", "Min HP To QSS", 90, 0, 100, 1)

	if Smite ~= nil then
		local SmiteThings = {"Baron", "Dragon", "Krug", "Gromp", "Wolves", "Razorbeak", "Blue", "Red", "Crab", "RiftHerald"}
		IreliaMenu.Misc:SubMenu("AS", "Auto Smite")
		IreliaMenu.Misc.AS:Boolean("ASC", "Enabled", true)
			DelayAction(function()
			for _, camp in pairs(SmiteThings) do
				IreliaMenu.Misc.AS:Boolean(camp, camp, true)
			end
		end, 0.001)
	end	

	IreliaMenu:SubMenu("Draw", "Drawings")
	IreliaMenu.Draw:Boolean("DAA", "Draw AA Range", true)
	IreliaMenu.Draw:Boolean("DQ", "Draw Q Range", true)
	IreliaMenu.Draw:Boolean("DE", "Draw E Range", true)
	IreliaMenu.Draw:Boolean("DR", "Draw R Range", true)
	IreliaMenu.Draw:Boolean("DD", "Draw Damage", true)

	IreliaMenu:SubMenu("Escape", "Escape")
	IreliaMenu.Escape:Boolean("EQ", "Use Q", true)
	IreliaMenu.Escape:Boolean("EE", "Use E", true)
	IreliaMenu.Escape:KeyBinding("EK", "Escape Key", string.byte("G"))

	IreliaMenu:SubMenu("GapClose", "GapClose")
	IreliaMenu.GapClose:Boolean("GCQ", "Use Q", true)
	IreliaMenu.GapClose:Boolean("GCE", "Use E", true)

	IreliaMenu:SubMenu("AGC", "Anti-GapCloser")

	IreliaMenu:SubMenu("Interrupter", "Interrupter")

	IreliaMenu:SubMenu("SkinChanger", "SkinChanger")

	IreliaMenu.SkinChanger:DropDown('Skin', myHero.charName.. " Skins", 1, EternalAIOSkins[myHero.charName], HeroSkinChanger, true)
	IreliaMenu.SkinChanger.Skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(EternalAIOSkins[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
	
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnUpdateBuff(function(unit, buff) self:UBuff(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:RBuff(unit, buff) end)
	OnIssueOrder(function(order) self:IssueOrder(order) end)
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)
	OnLoad(function() self:Load() end)
end	

function Irelia:CastQSS()
	local QSS = GetItemSlot(myHero, 3140)
	local MercSkimm = GetItemSlot(myHero, 3139)
	if QSS > 0 and Ready(QSS) then
		CastSpell(QSS)
		elseif MercSkimm > 0 and Ready(MercSkimm) then
		CastSpell(MercSkimm)
	end
end	

function Irelia:Combo()
	if GetPercentMP(myHero) >= IreliaMenu.Combo.CMM:Value() and WindingUp == false then
		if IreliaMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end
	
		if IreliaMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, AARange) then
			CastSpell(_W)
		end		
	
		if IreliaMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if IreliaMenu.Combo.CEC:Value() == 2 and not target.IsSpellShielded and GetPercentHP(target) >= GetPercentHP(myHero) then
				CastTargetSpell(target, _E)
				elseif IreliaMenu.Combo.CEC:Value() == 1 then
				CastTargetSpell(target, _E)
			end
		end

		if IreliaMenu.Combo.CR:Value() and Ready(_R) then
			local RPred = GetLinearAOEPrediction(target, RStats)
			if RPred.hitChance >= 0.3 and SheenOn == false then
				CastSkillShot(_R, RPred.castPos)
			end	
		end	
	end	
end

function Irelia:Harass()
	if GetPercentMP(myHero) >= IreliaMenu.Harass.HMM:Value() and WindingUp == false then
		if IreliaMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, QRange) then
			CastTargetSpell(target, _Q)
		end	
		
		if IreliaMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, AARange) then
			CastSpell(_W)
		end

		if IreliaMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, ERange) then
			if IreliaMenu.Harass.HEC:Value() == 2 and GetPercentHP(target) > GetPercentHP(myHero) and not target.IsSpellShielded then
				CastTargetSpell(target, _E)
				elseif IreliaMenu.Harass.HEC:Value() == 1 then
				CastTargetSpell(target, _E)
			end		
		end
	end
end	

function Irelia:LaneClear()
	for _, minion in pairs(minionManager.objects) do
		if minion.team == MINION_ENEMY then
			if GetPercentMP(myHero) >= IreliaMenu.LaneClear.LCMM:Value() and WindingUp == false then
				if IreliaMenu.LaneClear.LCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
					if minion.health <= QDmg(minion) then
						CastTargetSpell(minion, _Q)
					end
				end
					
				if IreliaMenu.LaneClear.LCW:Value() and Ready(_W) and ValidTarget(minion, AARange) then
					CastSpell(_W)
				end

				if IreliaMenu.LaneClear.LCE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
					CastTargetSpell(minion, _E)
				end
			end		
		end		
	end
end

function Irelia:JungleClear()
	for _, camp in pairs(minionManager.objects) do
		if camp.team == MINION_JUNGLE and not camp.name:lower():find("mini") then
			if GetPercentMP(myHero) >= IreliaMenu.JungleClear.JCMM:Value() and WindingUp == false then
				if IreliaMenu.JungleClear.JCQ:Value() and Ready(_Q) and ValidTarget(camp, QRange) then
					CastTargetSpell(camp, _Q)
				end
				
				if IreliaMenu.JungleClear.JCW:Value() and Ready(_W) and ValidTarget(camp, AARange) then
					CastSpell(_W)
				end

				if IreliaMenu.JungleClear.JCE:Value() and Ready(_E) and ValidTarget(camp, ERange) then
					CastTargetSpell(camp, _E)
				end
			end
		end
	end		
end

function Irelia:LastHit()
	for _, minion in pairs(minionManager.objects) do
		if minion.team == MINION_ENEMY then
			if GetPercentMP(myHero) >= IreliaMenu.LastHit.LHMM:Value() and WindingUp == false then
				if IreliaMenu.LastHit.LHQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) then
					if minion.health < QDmg(minion) then
						CastTargetSpell(minion, _Q)
					end
				end		
			
				if IreliaMenu.LastHit.LHE:Value() and Ready(_E) and ValidTarget(minion, ERange) then
					if minion.health <= EDmg(minion) then
						CastTargetSpell(minion, _E)
					end	
				end	
			end
		end
	end		
end	

function Irelia:CastIgnite(unit)
	if Ready(Ignite) and ValidTarget(unit, 600) and IDmg() >= truehpad(unit) + (GetHealthRegen(unit) * 3) then
		CastTargetSpell(unit, Ignite)
	end
end	

function Irelia:Loops()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if truehpap(enemy) <= EDmg(enemy) then
			idk = enemy
		end	
		
		if Ignite and IreliaMenu.Misc.AI:Value() then
			self:CastIgnite(enemy)
		end	
		
		if IreliaMenu.KillSteal.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, QRange) then
			if truehpad(enemy) <= QDmg(enemy) then
				CastTargetSpell(enemy, _Q)
			end
		end
		
		if IreliaMenu.KillSteal.KSE:Value() and Ready(_E) and ValidTarget(enemy, ERange) then
			if truehpap(enemy) <= EDmg(enemy) then
				CastTargetSpell(enemy, _E)
			end	
		end
		
		if IreliaMenu.KillSteal.KSE:Value() and IreliaMenu.KillSteal.KSQ:Value() and Ready(_Q) and Ready(_E) and ValidTarget(enemy, QRange) then
			if truehpad(enemy) <= EDmg(enemy) + QDmg(enemy) then
				CastTargetSpell(enemy, _Q)
				DelayAction(function()
					CastTargetSpell(enemy, _E)
				end, 0.5)	
			end
		end
		
		if IreliaMenu.KillSteal.KSQ:Value() and IreliaMenu.KillSteal.KSE:Value() and Ready(_E) and Ready(_Q) and idk ~= nil and enemy ~= idk and idk.valid and ValidTarget(enemy, QRange) and idk.distance > QRange and GetDistance(enemy, idk) <= ERange then
			CastTargetSpell(enemy, _Q)
			DelayAction(function()
				CastTargetSpell(_E, idk)
			end, 0.5)	
		end
		
		if IreliaMenu.KillSteal.KSR:Value() and Ready(_R) and ValidTarget(enemy, RRange) then
			if truehpad(enemy) <= RDmg(enemy) then
				local RPred = GetLinearAOEPrediction(enemy, RStats)
				if RPred.hitChance >= 0.3 then
					CastSkillShot(_R, RPred.castPos)
				end
			end
		end		
		
		for _, minion in pairs(minionManager.objects) do
			if minion.team ~= myHero.team then
				if IreliaMenu.KillSteal.KSQ:Value() and IreliaMenu.KillSteal.KSE:Value() and Ready(_Q) and Ready(_E) then
					if ValidTarget(minion, QRange) and ValidTarget(enemy) and GetDistance(myHero, enemy) > QRange and GetDistance(enemy, minion) <= ERange and truehpap(enemy) <= EDmg(enemy) then
						CastTargetSpell(minion, _Q)
						DelayAction(function()
							CastTargetSpell(enemy, _E)
						end, 0.5)
					end		
				end
			end
		end		
	end
end	

function Irelia:GapClose()
	local MovePos = GetPrediction(target, MoveStats)
	for _, minion in pairs(minionManager.objects) do
		if minion.team ~= myHero.team then
			if IreliaMenu.GapClose.GCQ:Value() and Ready(_Q) and ValidTarget(minion, QRange) and ValidTarget(target) and GetDistance(minion, target) <= ERange and WindingUp == false and minion.health <= QDmg(minion) then
				CastTargetSpell(minion, _Q)
			end
		end
	end
	
	if IreliaMenu.GapClose.GCE:Value() and Ready(_E) and ValidTarget(target, ERange) and GetDistance(MovePos.castPos) > GetDistance(target) and WindingUp == false then
		CastTargetSpell(target, _E)
	end
end

function Irelia:CastItems1()
local T = GetItemSlot(myHero, 3077)
local RH = GetItemSlot(myHero, 3074)
local TH = GetItemSlot(myHero, 3748)
	if T > 0 and Ready(T) then
		CastSpell(T)
		elseif RH > 0 and Ready(RH) then
		CastSpell(RH)
		elseif TH > 0 and Ready(TH) then
		CastSpell(TH)
	end	
end

function Irelia:CastSmite(unit)
	if Smite and Ready(Smite) and ValidTarget(unit, 500) and SmiteDmg() >= unit.health then
		CastTargetSpell(unit, Smite)
	end
end

function Irelia:AutoSmite()
	if Smite and IreliaMenu.Misc.AS.ASC:Value() then
		for _, camp in pairs(minionManager.objects) do
			if camp.team == MINION_JUNGLE then
				if IreliaMenu.Misc.AS.Red:Value() and camp.name:lower():find("sru_red") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Blue:Value() and camp.name:lower():find("sru_blue") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Dragon:Value() and camp.name:lower():find("sru_dragon") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Baron:Value() and camp.name:lower():find("sru_baron") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Gromp:Value() and camp.name:lower():find("sru_gromp") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Crab:Value() and camp.name:lower():find("sru_crab") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Wolves:Value() and camp.name:lower():find("sru_murkwolf") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.RiftHerald:Value() and camp.name:lower():find("sru_riftherald") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Krug:Value() and camp.name:lower():find("sru_krug") then
					self:CastSmite(camp)
					elseif IreliaMenu.Misc.AS.Razorbeak:Value() and camp.name:lower():find("sru_razorbeak") then
					self:CastSmite(camp)
				end
			end
		end
	end		
end

function Irelia:Escape()
	MoveToXYZ(GetMousePos())
	if IreliaMenu.Escape.EQ:Value() and Ready(_Q) then
		for _, enemy in pairs(GetEnemyHeroes()) do
			for _, minion in pairs(EMin) do
				if ValidTarget(enemy, 1000) and ValidTarget(minion, QRange) then
					if GetDistance(minion, enemy) > enemy.distance then
						CastTargetSpell(minion, _Q)
					end
				end
			end		
		end
	end

	if IreliaMenu.Escape.EE:Value() and Ready(_E) and ValidTarget(target, ERange) and not target.IsSpellShielded then
		CastTargetSpell(target, _E)
	end
end

function Irelia:Tick()
	if ctarget ~= nil and ctarget.valid then
		target = ctarget
	end
	
	if ctarget == nil or ctarget.dead then
		ctarget = nil
		target = GetCurrentTarget()
	end
	
	if IreliaMenu.Misc.AutoLevel:Value() ~= 1 and GetLevelPoints(myHero) > 0 then
		LevelSpell(spellorder[IreliaMenu.Misc.AutoLevel:Value()][GetLevel(myHero)])
	end
	target = GetCurrentTarget()
	
	self:Loops()
	self:AutoSmite()
	
	if Mode() == "Combo" then
		self:Combo()
		self:GapClose()
	end

	if Mode() == "Harass" then 
		self:Harass()
		self:GapClose()
	end
	
	if Mode() == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	end	

	if Mode() == "LastHit" then
		self:LastHit()	
	end
	
	if IreliaMenu.Escape.EK:Value() then
		self:Escape()
	end
end

function Irelia:Draw()
	local Damage, QDamage, EDamage, RDamage, AADamage = 0, 0, 0, 0, 0 
	if myHero.dead then return end
	if IreliaMenu.Draw.DAA:Value() then DrawCircle(myHero, AARange, 2, 25, GoS.White) end
	if IreliaMenu.Draw.DQ:Value() then DrawCircle(myHero, QRange, 2, 25, GoS.Cyan) end
	if IreliaMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 2, 25, GoS.Cyan) end
	if IreliaMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 2, 25, GoS.Cyan) end	
	if EternalMenu.DT:Value() and target ~= nil then DrawCircle(target, target.boundingRadius * 2, 2, 25, GoS.Red) end
	
	if IreliaMenu.Draw.DD:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if Ready(_Q) then QDamage = QDmg(enemy) else QDamage = 0 end
			if Ready(_E) then EDamage = EDmg(enemy) else EDamage = 0 end
			if Ready(_R) then RDamage = RDmg(enemy) * self:RLeft() else RDamage = 0 end
			AADamage = AADmg(enemy) * myHero.attackSpeed
			Damage = AADamage + QDamage + EDamage + RDamage

			if Damage > truehpap(enemy) then Damage = truehpap(enemy) end

			DrawDmgOverHpBar(enemy, truehpap(enemy), Damage, 0, GoS.White)
		end	
	end	
end	

function Irelia:SpellComplete(unit, spell)
	if myHero.dead then return end
	
	if Mode() == "Combo" then
		if IreliaMenu.Combo.I:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero and spell.target.valid then
			self:CastItems1()
		end
	end	

	if Mode() == "Harass" then
		if IreliaMenu.Harass.I:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero and spell.target.valid then
			self:CastItems1()
		end
	end
	
	if Mode() == "LaneClear" then
		if IreliaMenu.LaneClear.I:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion and spell.target.team == MINION_ENEMY and spell.target.valid then
			self:CastItems1()
		end
		
		if IreliaMenu.JungleClear.I:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isMinion and spell.target.team == MINION_JUNGLE and spell.target.valid then
			self:CastItems1()
		end
	end
end

function Irelia:UBuff(unit, buff)
	if IreliaMenu.Misc.QSS:Value() and unit.isMe and CCType[buff.Type] and GetPercentHP(myHero) <= IreliaMenu.Misc.QSSC:Value() then
		self:CastQSS()
	end

	if unit.isMe and buff.Name:lower():find("ireliahitenstylecharged") then
		WOn = true
	end	
	
	if unit.isMe and buff.Name:lower():find("sheen") then
		SheenOn = true
	end	
end

function Irelia:RBuff(unit, buff)
	if unit.isMe and buff.Name:lower():find("ireliahitenstylecharged") then
		WOn = false
	end
	
	if unit.isMe and buff.Name:lower():find("sheen") then
		SheenOn = false
	end
end

function Irelia:IssueOrder(order)
	if order.flag == 2 and IreliaMenu.Escape.EK:Value() then
		if GetGameTimer() - lastmovement < 1/6 then
			BlockOrder()
			else
			lastmovement = GetGameTimer()
		end
	end
end	

function Irelia:Load()
	ChallengerCommon.Interrupter(IreliaMenu.Interrupter, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange and unit.valid and GetPercentHP(unit) > GetPercentHP(myHero) then
			CastTargetSpell(unit, _E)
		end
	end)
	
	ChallengerCommon.AntiGapcloser(IreliaMenu.AGC, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_E) and GetDistance(myHero, unit) <= ERange and unit.valid and GetPercentHP(unit) > GetPercentHP(myHero) then
			CastTargetSpell(unit, _E)
		end	
	end)
end

class "Riven"

function WDmg(unit) return getdmg("W", unit, myHero, GetCastLevel(myHero, _W)) end
function QDmg(unit) return getdmg("Q", unit, myHero, GetCastLevel(myHero, _Q)) end

function Pas() return GetBuffData(myHero, "rivenpassiveaaboost").Count end

function AADmg(unit)
	if Pas() > 0 then
		return CalcPhysicalDamage(myHero, unit, myHero.totalDamage + (myHero.totalDamage * Passive()))
		else
		return CalcPhysicalDamage(myHero, unit, myHero.totalDamage)
	end	
end

function AAB(unit) return CalcPhysicalDamage(myHero, unit, myHero.totalDamage + (myHero.totalDamage * Passive())) end

function RDmg(unit) return getdmg("R", unit, myHero, GetCastLevel(myHero, _R)) end

function Passive() return ({0.25,0.25,0.25,0.25,0.25,0.3,0.3,0.3,0.35,0.35,0.35,0.4,0.45,0.45,0.45,0.45,0.45,0.5})[myHero.level] end

function Riven:QsLeft()
	if QCast == 0 and Ready(_Q) then 
		return 3	
		elseif QCast == 1 then
		return 2
		elseif QCast == 2 then
		return 1
	end
	return 0 
end

function Riven:IDontKnow()
	if Mode() ~= "" then --or RivenMenu.Keys.BK:Value()
		return true	
		else 
		return false
	end
end	

function Riven:UltOn()
	if GetCastName(myHero, _R):lower():find("rivenizunablade") then
		return true
		else
		return false
	end	
end	

function Riven:AARange()
	if self:UltOn() then
		return GetRange(myHero) + myHero.boundingRadius + 75
		else
		return GetRange(myHero) + (myHero.boundingRadius * 2)
	end	
end

function Riven:QRange()
	if self:UltOn() then
		return GetCastRange(myHero, _Q) + 75 + myHero.boundingRadius * 0.5
		else
		return GetCastRange(myHero, _Q) + myHero.boundingRadius * 0.5
	end	
end

function Riven:WRange()
	if self:UltOn() then
		return GetCastRange(myHero, _W) + 75 + myHero.boundingRadius * 0.5
		else
		return GetCastRange(myHero, _W) + myHero.boundingRadius * 0.5
	end	
end

function Riven:HydraCheck()
	local T = GetItemSlot(myHero, 3077)
	local RH = GetItemSlot(myHero, 3074)
	if (RH > 0 and Ready(RH)) or (T > 0 and Ready(T)) then
		return true
	end
	return false
end

function Riven:HydraCheck2()
	local TH = GetItemSlot(myHero, 3748)
	if TH > 0 and Ready(TH) then
		return true
	end
	return false
end

local RRange = 1100 + myHero.boundingRadius
local QCast = 0
local target = nil	
local RStats = {delay = 0.025, range = RRange, width = 200, speed = 1600, angle = 15}
local lastmovement = 0
local ERange = 325 + myHero.boundingRadius * 0.5

function Riven:__init()
	RivenMenu = Menu("Riven", "Riven")
	RivenMenu:SubMenu("Combo", "Combo")
	RivenMenu.Combo:Boolean("CQ", "Use Q", true)
	RivenMenu.Combo:Boolean("CW", "Use W", true)
	RivenMenu.Combo:Boolean("CE", "Use E", true)
	RivenMenu.Combo:Boolean("CR", "Use R", true)
	RivenMenu.Combo:Slider("CRC", "Min Enemy HP to Activate R",60,1,100,1)
	RivenMenu.Combo:Boolean("CR2", "Use R2", true)
	RivenMenu.Combo:Boolean("CRH", "Use R Hydra", true)
	RivenMenu.Combo:Boolean("CTH", "Use T Hydra", true)
	RivenMenu.Combo:Boolean("YGB", "Use GhostBlade", true)

	RivenMenu:SubMenu("Harass", "Harass")
	RivenMenu.Harass:Boolean("HQ", "Use Q", true)
	RivenMenu.Harass:Boolean("HW", "Use W", true)
	RivenMenu.Harass:Boolean("HE", "Use E", true)
	RivenMenu.Harass:Boolean("HRH", "Use R Hydra", true)

	RivenMenu:SubMenu("LaneClear", "LaneClear")
	RivenMenu.LaneClear:Boolean("LCQ", "Use Q")
	RivenMenu.LaneClear:Boolean("LCW", "Use W")
	RivenMenu.LaneClear:Boolean("LCH", "Use Hydra", true)

	RivenMenu:SubMenu("JungleClear", "JungleClear")
	RivenMenu.JungleClear:Boolean("JCQ", "Use Q", true)
	RivenMenu.JungleClear:Boolean("JCW", "Use W", true)
	RivenMenu.JungleClear:Boolean("JCE", "Use E", true)

	RivenMenu:SubMenu("LastHit", "LastHit")
	RivenMenu.LastHit:Boolean("LHW", "Use W", true)

	RivenMenu:SubMenu("KillSteal", "KillSteal")
	RivenMenu.KillSteal:Boolean("KSW", "Use W", true)
	RivenMenu.KillSteal:Boolean("KSR", "Use R", true)

	RivenMenu:SubMenu("Misc", "Misc")
	RivenMenu.Misc:DropDown("AutoLevel", "AutoLevel", 1, {"Off", "QEW", "QWE", "WQE", "WEQ", "EQW", "EWQ"})
	RivenMenu.Misc:Boolean("GSQ", "God Speed Q", true)
	RivenMenu.Misc:Boolean("AutoI", "Auto Ignite", true)
	RivenMenu.Misc:Boolean("AW", "Auto W", true)
	RivenMenu.Misc:Slider("AWC", "Min Enemies To Auto W",3,1,6,1)
	RivenMenu.Misc:Boolean("AR", "Auto R If Hit X Enemies", true)
	RivenMenu.Misc:Slider("ARC", "Min Enemies To Auto R",4,1,6,1)
	RivenMenu.Misc:Boolean("QSS", "Auto QSS", true)
	RivenMenu.Misc:Slider("QSSC", "HP To QSS", 90, 0, 100, 1)

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
	RivenMenu.GC:Slider("GCD", "Distance To GapClose", 650, 350, 1500, 50)

	RivenMenu:SubMenu("Burst", "Burst Combos")
	RivenMenu.Burst:Info("123", "SOONTM")
	--[[RivenMenu.Burst:DropDown("BurstC", "Burst Combos", 1, {"Off", "ShyBurst", "E-R-F-W-AA-Q-AA-Q-AA-Q-R", "E-R-F-Q-W-AA-Hydra-R-Q-AA", "E-R-F-Q-W-AA-R-Hydra-Q-AA", "E-R-F-Hydra-W-Q-AA-R-Q-AA-Q-AA"})
	RivenMenu.Burst:KeyBinding("BurstCK", "Change Burst Combo", string.byte("A"))]]--

	RivenMenu:SubMenu("AGC", "Anti-GapCloser")

	RivenMenu:SubMenu("Interrupter", "Interrupter")
	
	RivenMenu:SubMenu("SkinChanger", "SkinChanger")

	RivenMenu:SubMenu("Keys", "Key Bindings")
	RivenMenu.Keys:KeyBinding("WJ", "Wall Jump", string.byte("T"))
	RivenMenu.Keys:KeyBinding("EK", "Escape", string.byte("G"))
	--RivenMenu.Keys:KeyBinding("BK", "Burst Key", string.byte("N"))

	RivenMenu.SkinChanger:DropDown('Skin', myHero.charName.. " Skins", 1, EternalAIOSkins[myHero.charName], HeroSkinChanger, true)
	RivenMenu.SkinChanger.Skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(EternalAIOSkins[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
	
	OnAnimation(function(unit, animation) self:Animation(unit, animation) end)
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)
	OnTick(function() self:Tick() end)
	OnDraw(function() self:Draw() end)
	OnProcessSpell(function(unit, spell) self:Spell(unit, spell) end)
	OnUpdateBuff(function(unit, buff) self:UBuff(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:RBuff(unit, buff) end)
	OnIssueOrder(function(order) self:Order(order) end)
	OnLoad(function() self:Load() end)
end

function Riven:Combo()
	if not WindingUp then
		if RivenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, 500) then
			CastSkillShot(_E, target)
		end
		
		if RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) and GetDistance(myHero, target) > self:AARange() then
			CastSpell(_W)
		end	
	end
end

function Riven:Harass()
	if not WindingUp then
		if RivenMenu.Harass.HE:Value() and Ready(_E) and ValidTarget(target, 500) then
			CastSkillShot(_E, target)
		end

		if RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) and GetDistance(myHero, target) > self:AARange() then
			CastSpell(_W)
		end
	end		
end

function Riven:CastHydras()
	local T = GetItemSlot(myHero, 3077)
	local RH = GetItemSlot(myHero, 3074)
	if T > 0 and Ready(T) then
		CastSpell(T)
		elseif RH > 0 and Ready(RH) then
		CastSpell(RH)
	end	
end

function Riven:CastHydras2()
	local TH = GetItemSlot(myHero, 3748)
	if TH > 0 and Ready(TH) then
		CastSpell(TH)
	end	
end

function Riven:LaneClear()
	self:LastHit()
	if not WindingUp and MinionsAround(myHero, self:WRange(), MINION_ENEMY) > 1 then
		if RivenMenu.LaneClear.LCH:Value() and self:HydraCheck() then
			self:CastHydras()
			elseif RivenMenu.LaneClear.LCW:Value() and Ready(_W) then
			CastSpell(_W)
		end
	end		
end

function Riven:LastHit()
	for _, minion in pairs(EMin) do
		if RivenMenu.LastHit.LHW:Value() and Ready(_W) and ValidTarget(minion, self:WRange()) then
			if WindingDown or (not WindingUp and minion.distance > self:AARange()) then
				if minion.health - GetDamagePrediction(minion, 0.265 - (GetLatency() * 0.001)) <= WDmg(minion) then
					CastSpell(_W)
				end	
			end
		end		
	end	
end

function Riven:Escape()
	MoveToXYZ(GetMousePos())
	if RivenMenu.Escape.EQ:Value() and Ready(_Q) then
		CastSkillShot(_Q, GetMousePos())
	end
	
	if RivenMenu.Escape.EE:Value() and Ready(_E) then
		CastSkillShot(_E, GetMousePos())
	end
end

function Riven:CastR(unit)
	local RPred = GetConicAOEPrediction(unit, RStats)
	if Ready(_R) and self:UltOn() and RPred.hitChance >= 0.4 then
		CastSkillShot(_R, RPred.castPos)
	end		
end

--[[function Riven:Burst()
	if not WindingUp then
		if ValidTarget(target, self:AARange()) then
			MoveToXYZ(target)
			else
			MoveToXYZ(GetMousePos())
		end	
	end

	if CanAttack() and ValidTarget(target, self:AARange()) then
		AttackUnit(target)
	end	
end]]--

function Riven:WallJump()
	local kek = myHero.pos + Vector(GetDirection(myHero)):normalized() * 420
	local kek2 = myHero.pos + Vector(GetDirection(myHero)):normalized() * 100
	if not MapPosition:inWall(kek2) or MapPosition:inWall(kek) then
		MoveToXYZ(GetMousePos())
	end	
	if QCast < 2 and Ready(_Q) then
		CastSkillShot(_Q, GetMousePos())
	end	

	if MapPosition:inWall(kek2) and not MapPosition:inWall(kek) and Ready(_Q) then
		CastSkillShot(_Q, kek2)
	end
end

function Riven:CastQSS()
	local QSS = GetItemSlot(myHero, 3140)
	local MercSkimm = GetItemSlot(myHero, 3139)	
	if RivenMenu.Misc.QSS:Value() and GetPercentHP(myHero) <= RivenMenu.Misc.QSSC:Value() then
		if QSS > 0 and Ready(QSS) then 
			CastSpell(QSS)
			elseif MercSkimm > 0 and Ready(MercSkimm) then
				CastSpell(MercSkimm)
		end
	end	
end	

function Riven:KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if RivenMenu.KillSteal.KSW:Value() and Ready(_W) and ValidTarget(enemy, self:WRange()) then
			if WDmg(enemy) >= truehpad(enemy) then
				CastSpell(_W)
			end
		end

		if RivenMenu.KillSteal.KSR:Value() and self:UltOn() and Ready(_R) and ValidTarget(enemy, RRange) then
			if RDmg(enemy) >= truehpad(enemy) then
				self:CastR(enemy)
			end	
		end
	end
end

function Riven:Stuff()
	if RivenMenu.Misc.AutoLevel:Value() ~= 1 and GetLevelPoints(myHero) > 0 then
		LevelSpell(spellorder[RivenMenu.Misc.AutoLevel:Value()][GetLevel(myHero)])
	end

	if RivenMenu.Misc.AW:Value() and Ready(_W) and EnemiesAround(myHero, self:WRange()) >= RivenMenu.Misc.AWC:Value() then
		CastSpell(_W)
	end
	
	if RivenMenu.Misc.AR:Value() and self:UltOn() and Ready(_R) then
		for _, enemy in pairs(GetEnemyHeroes()) do
			local RPred = GetConicAOEPrediction(enemy, RStats)
			if ValidTarget(enemy, RRange) and CountObjectsOnLineSegment(myHero, RPred.castPos, 200, GetEnemyHeroes()) >= RivenMenu.Misc.ARC:Value() then
				CastSkillShot(_R, RPred.castPos)
			end	
		end
	end			
end

function Riven:GapClose()
	local Move = {delay = 1, speed = math.huge, range = math.huge, width = 1}
	local MovePos = GetPrediction(target, Move)
	if target.distance < ERange + self:AARange() + self:WRange() and target.distance < RivenMenu.GC.GCD:Value() and target.distance < GetDistance(MovePos.castPos) then
		if RivenMenu.GC.GCQ:Value() and Ready(_Q) then 
			CastSkillShot(_Q, target)
		end

		if RivenMenu.GC.GCE:Value() and Ready(_E) then
			CastSkillShot(_E, target)
		end
	end		
end

function Riven:CastGhost()
	local YGB = GetItemSlot(myHero, 3142)
	if YGB > 0 and Ready(YGB) then
		CastSpell(YGB)
	end	
end

function Riven:Tick()
	if myHero.dead then return end
	if ctarget ~= nil and ctarget.valid then
		target = ctarget
	end
	
	if ctarget == nil or ctarget.dead then
		ctarget = nil
		target = GetCurrentTarget()
	end
	
	if Mode() == "Combo" then
		self:Combo()
	end
	
	if Mode() == "Harass" then
		self:Harass()
	end
	
	if Mode() == "Harass" or Mode() == "Combo" then
		self:GapClose()
	end	

	if Mode() == "LaneClear" then
		self:LaneClear()
	end

	if Mode() == "LastHit" then
		self:LastHit()
	end
	
	if RivenMenu.Keys.EK:Value() then
		self:Escape()
	end
	
	--[[if RivenMenu.Keys.BK:Value() then
		self:Burst()
	end]]--
	
	if RivenMenu.Keys.WJ:Value() then
		self:WallJump()
	end
	
	self:KillSteal()
	self:Stuff()
end

function Riven:Draw()
	local QDamage, WDamage, RDamage, EDamage, Damage = 0, 0, 0, 0, 0
	if myHero.dead then return end
	if target ~= nil and EternalMenu.DT:Value() then DrawCircle(target, target.boundingRadius * 2, 2, 25, GoS.Red) end
	if RivenMenu.Draw.DAA:Value() then DrawCircle(myHero, self:AARange(), 2, 25, GoS.White) end
	if RivenMenu.Draw.DQ:Value() then DrawCircle(myHero, self:QRange(), 2, 25, GoS.Cyan) end
	if RivenMenu.Draw.DW:Value() then DrawCircle(myHero, self:WRange(), 2, 25, GoS.Cyan) end
	if RivenMenu.Draw.DE:Value() then DrawCircle(myHero, ERange, 2, 25, GoS.Cyan) end
	if RivenMenu.Draw.DR:Value() then DrawCircle(myHero, RRange, 2, 25, GoS.Cyan) end
	
	if RivenMenu.Draw.DD:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if Ready(_Q) or QCast > 0 then QDamage = (QDmg(enemy) * self:QsLeft()) + (AAB(enemy) * (self:QsLeft() + 1)) else QDamage = 0 end
			if Ready(_W) then WDamage = WDmg(enemy) + AAB(enemy) else WDamage = 0 end
			if Ready(_E) then EDamage = AAB(enemy) else EDamage = 0 end
			if Ready(_R) then RDamage = RDmg(enemy) + AAB(enemy) else RDamage = 0 end		
			Damage = QDamage + WDamage + EDamage + RDamage			
			if Damage > truehpad(enemy) then Damage = truehpad(enemy) end
			DrawDmgOverHpBar(enemy, truehpad(enemy), Damage, 0, GoS.White)
		end
	end		
end

function Riven:Animation(unit, animation)
	if	RivenMenu.Misc.GSQ:Value() and unit.isMe and self:IDontKnow() then
		if animation == "Spell1a" or animation == "Spell1b" then
			DelayAction(function()
				CastEmote(EMOTE_TOGGLE)
				ResetAA()
			end, 0.28 - (GetLatency() * 0.001))
		end
		
		if animation == "Spell1c" then
			DelayAction(function()
				CastEmote(EMOTE_TOGGLE)
				ResetAA()
			end, 0.35 - (GetLatency() * 0.001))	
		end
	end
end

function Riven:Spell(unit, spell)
	if unit.isMe and spell.name == "RivenFeint" then
		if Mode() == "Combo" then
			if RivenMenu.Combo.CR:Value() and not self:UltOn() and Ready(_R) and ValidTarget(target, self:WRange() + ERange + self:AARange()) and GetPercentHP(target) >= RivenMenu.Combo.CRC:Value() then
				CastSpell(_R)
				elseif RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
					self:CastHydras()
				elseif RivenMenu.Combo.CR2:Value() and self:UltOn() and Ready(_R) and ValidTarget(target, RRange) and (GetPercentHP(target) <= 25 or truehpad(target) <= RDmg(target)) then
					self:CastR(target)
				elseif RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
					CastSpell(_W)
				elseif RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
					CastSkillShot(_Q, target)
			end
		end
		
		if Mode() == "Harass" then
			if RivenMenu.Harass.HRH:Value() and self:HydraCheck() then
				self:CastHydras()
				elseif RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, self:WRange()	) then
					CastSpell(_W)
				elseif RivenMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()()) then
					CastSkillShot(_Q, target)	
			end
		end
	end

	if unit.isMe and spell.name:lower():find("rivenfengshuiengine") then
		DelayAction(function()
			if RivenMenu.Combo.CR2:Value() and not myHero.isRecalling and Ready(_R) and self:UltOn() and ValidTarget(target, RRange) then
				self:CastR(target)
				elseif RivenMenu.Combo.CR2:Value() and not myHero.isRecalling and Ready(_R) and self:UltOn() and not ValidTarget(target, RRange) then
					CastSkillShot(_R, GetMousePos())
			end
		end, 15 - GetLatency() * 0.002)
		
		if Mode() == "Combo" then
			if RivenMenu.Combo.YGB:Value() then self:CastGhost() end
			if RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
				self:CastHydras()
				elseif RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
					CastSpell(_W)
				elseif RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
					CastSkillShot(_Q, target)
			end	
		end
	end

	if unit.isMe and spell.name:lower():find("rivenizunablade") then
		DelayAction(function()
			if RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
				CastSkillShot(_Q, target)
				elseif RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
					self:CastHydras()
				elseif RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
					CastSpell(_W)
			end		
		end, spell.windUpTime - (GetLatency() * 0.001))
	end
	
	if unit.isMe and spell.name == "RivenTriCleave" then
		if Mode() == "Combo" then
			DelayAction(function()
				if RivenMenu.Combo.CR:Value() and not self:UltOn() and Ready(_R) and target.health >= RivenMenu.Combo.CRC:Value() then
					CastSpell(_R)
					elseif RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
						self:CastHydras()
					elseif RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
						CastSpell(_W)
				end	
			end, spell.windUpTime - (GetLatency() * 0.001))
		end
		
		if Mode() == "Harass" then
			DelayAction(function()
				if RivenMenu.Harass.HRH:Value() and self:HydraCheck() then
					self:CastHydras()
					elseif RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
						CastSpell(_W)
				end	
			end, spell.windUpTime - (GetLatency() * 0.001))
		end
	end
	
	if unit.isMe and spell.name:lower():find("rivenmartyr") then
		if Mode() == "Combo" then
			DelayAction(function()
				if self:UltOn() and Ready(_R) and ValidTarget(target, RRange) and (GetPercentHP(target) <= 25 or truehpad(target) <= RDmg(target)) then
					self:CastR(target)
					elseif RivenMenu.Combo.CR:Value() and not Ready(_E) and Ready(_R) and not self:UltOn() and ValidTarget(target, ERange + self:AARange()) and GetPercentHP(target) >= RivenMenu.Combo.CRC:Value() then
						CastSpell(_R)
					elseif RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
						self:CastHydras()
				end
			end, spell.windUpTime - (GetLatency() * 0.001))	
		end
			 
		if Mode() == "Harass" then
			DelayAction(function()
				if RivenMenu.Harass.HRH:Value() and self:HydraCheck() then
					self:CastHydras()
					elseif RivenMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
						CastSkillShot(_Q, target)
				end	
			end, spell.windUpTime - (GetLatency() * 0.001))
		end
	end	
	
	if unit.isMe and spell.name == "ItemTiamatCleave" then
		if Mode() == "Combo" then
			DelayAction(function()
				if RivenMenu.Combo.CR:Value() and Ready(_R) and ValidTarget(target, self:WRange() + self:AARange() + ERange) and not self:UltOn() then
					CastSpell(_R)
				elseif RivenMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target, self:WRange()) then
					CastSpell(_W)
				elseif self:UltOn() and Ready(_R) and ValidTarget(target, RRange) and (GetPercentHP(target) <= 25 or truehpad(target) <= RDmg(target)) then
					self:CastR(target)
				elseif RivenMenu.Combo.CQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
					CastSkillShot(_Q, target)
				elseif RivenMenu.Combo.CE:Value() and Ready(_E) and ValidTarget(target, ERange) then
					CastSkillShot(_E, target)
				end		
			end, spell.windUpTime - GetLatency() * 0.001)	
		end

		if Mode() == "Harass" then
			DelayAction(function()
				if RivenMenu.Harass.HW:Value() and Ready(_W) and ValidTarget(target, self:WRange()()) then
					CastSpell(_W)
					elseif RivenMenu.Harass.HQ:Value() and Ready(_Q) and ValidTarget(target, self:QRange()) then
					CastSkillShot(_Q, target)
				end
			end, spell.windUpTime - GetLatency() * 0.001)
		end
	end
	
	if Mode() == "LaneClear" then
		if GetTeam(unit) == MINION_JUNGLE and not GetObjectName(unit):lower():find("mini") and spell.name:lower():find("attack") and spell.target.isMe then
			if RivenMenu.JungleClear.JCE:Value() and Ready(_E) then
				DelayAction(function()
					CastSkillShot(_E, GetMousePos())
				end, spell.windUpTime / 1.5 - GetLatency() * 0.001)
			end		
			
			if RivenMenu.JungleClear.JCW:Value() and Ready(_W) and not Ready(_E) then
				DelayAction(function()
					CastSpell(_W)
				end, spell.windUpTime / 1.5 - GetLatency() * 0.001)
			end
		end	
	end
end

function Riven:SpellComplete(unit, spell)	
	if unit.isMe and spell.name:lower():find("attack") and truehpad(spell.target) > AADmg(spell.target) then
		if spell.target.isHero then
			if Mode() == "Combo" then
				if RivenMenu.Combo.CRH:Value() and self:HydraCheck() then
					self:CastHydras()
					elseif RivenMenu.Combo.CTH:Value() and self:HydraCheck2() then
						self:CastHydras2()
					elseif RivenMenu.Combo.CR2:Value() and self:UltOn() and Ready(_R) and GetPercentHP(spell.target) <= 30 then
						self:CastR(spell.target)
					elseif RivenMenu.Combo.CW:Value() and Ready(_W) then
						CastSpell(_W)
					elseif RivenMenu.Combo.CQ:Value() and Ready(_Q) then
						CastSkillShot(_Q, spell.target)
					elseif RivenMenu.Combo.CE:Value() and Ready(_E) then
						CastSkillShot(_E, spell.target)
				end		
			end

			if Mode() == "Harass" then
				if RivenMenu.Harass.HRH:Value() and self:HydraCheck() then
					self:CastHydras()
					elseif RivenMenu.Harass.HW:Value() and Ready(_W) then
						CastSpell(_W)
					elseif RivenMenu.Harass.HQ:Value() and Ready(_Q) then
						CastSkillShot(_Q, spell.target)
					elseif RivenMenu.Harass.HE:Value() and Ready(_E) then
						CastSkillShot(_E, spell.target)	
				end				
			end
		end
		
		if spell.target.isMinion then
			if Mode() == "LaneClear" then
				if spell.target.team == MINION_ENEMY then
					if RivenMenu.LaneClear.LCQ:Value() and Ready(_Q) then
						CastSkillShot(_Q, spell.target)
					end
				end

				if spell.target.team == MINION_JUNGLE then
					if RivenMenu.JungleClear.JCQ:Value() and Ready(_Q) then
						CastSkillShot(_Q, spell.target)
					end	
				end		
			end
		end		
	end
end

function Riven:UBuff(unit, buff)
	if unit.isMe and buff.Name == "RivenTriCleave" then 
		QCast = buff.Count
	end
	
	if unit.isMe and CCType[buff.Type] and EnemiesAround(myHero, 800) > 0 then
		self:CastQSS()
	end	
end

function Riven:RBuff(unit, buff)
	if unit.isMe and buff.Name == "RivenTriCleave" then 
		QCast = 0
	end
end

function Riven:Order(order)
	if RivenMenu.Keys.EK:Value() or RivenMenu.Keys.WJ:Value() then --or RivenMenu.Keys.BK:Value() 
		if order.flag == 2 then
			if GetGameTimer() - lastmovement < 1/5 then
				BlockOrder()
				else
				lastmovement = GetGameTimer()
			end
		end
	end		
end

function Riven:Load()
	ChallengerCommon.Interrupter(RivenMenu.Interrupter, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_W) and ValidTarget(unit, self:WRange()) then
			CastSpell(_W)
			elseif unit.team == MINION_ENEMY and Ready(_Q) and QCast == 2 and ValidTarget(unit, self:QRange()) then
				CastSkillShot(_Q, unit)
		end
	end)
	
	ChallengerCommon.AntiGapcloser(RivenMenu.AGC, function(unit, spell)
		if unit.team == MINION_ENEMY and Ready(_W) and ValidTarget(unit, self:WRange()) then
			CastSpell(_W)
		end	
	end)
end	
		
--[[class "Lucian"

function Lucian:__init()

	LucianMenu = Menu("Lucian", "Lucian")
	LucianMenu:SubMenu("Combo", "Combo")
	LucianMenu.Combo:Boolean("CQ", "Use Q", true)
	LucianMenu.Combo:Boolean("CW", "Use W", true)
	LucianMenu.Combo:Boolean("CE", "Use E", true)
	
	OnProcessSpellComplete(function(unit, spell) self:SpellComplete(unit, spell) end)

end
		
function Lucian:SpellComplete(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and spell.target.valid then
		if spell.target.isHero then
			if Mode() == "Combo" then
				if LucianMenu.Combo.CQ:Value() and Ready(_Q) then
					CastTargetSpell(spell.target, _Q)
					elseif LucianMenu.Combo.CW:Value() and Ready(_W) then
						CastSkillShot(_W, spell.target)
					elseif LucianMenu.Combo.CE:Value() and Ready(_E) then
						CastSkillShot(_E, GetMousePos())
				end
			end
		end
	end
end]]--

_G[myHero.charName]()	
print("Thanks For Using EternalAIO: "..myHero.charName.." Have Fun "..GetUser().." :D")
