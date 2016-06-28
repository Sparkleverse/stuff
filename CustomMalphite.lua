if GetObjectName(GetMyHero()) ~= "Malphite" then return end

local ver = "0.01"

require("openpredict")

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
MalphiteMenu.Harass:Slider("MMH", "Min Mana To Harass",60,0,100,1)

MalphiteMenu:SubMenu("LastHit", "LastHit")
MalphiteMenu.LastHit:Boolean("LHQ", "Use Q", true)
MalphiteMenu.LastHit:Boolean("LHE", "Use E", true)

MalphiteMenu:SubMenu("LaneClear", "LaneClear")
MalphiteMenu.LaneClear:Boolean("LCQ", "Use Q", true)
MalphiteMenu.LaneClear:Boolean("LCW", "Use W", true)
MalphiteMenu.LaneClear:Boolean("LCE", "Use E", true)
MalphiteMenu.LaneClear:Slider("MMH", "Min Mana To LaneClear",60,0,100,1)

MalphiteMenu:SubMenu("KillSteal", "Killsteal")
MalphiteMenu.KillSteal:Boolean("KSQ", "Use Q", true)
MalphiteMenu.KillSteal:Boolean("KSE", "Use E", true)
MalphiteMenu.Killsteal:Boolean("KSR", "Use R", true)

MalphiteMenu:SubMenu("Misc", "Misc")
MalphiteMenu.Misc:Boolean("AutoLevel", "Use Auto Level", true)
MalphiteMenu.Misc:Boolean("AR", "Auto R on X Enemies", true)
MalphiteMenu.Misc:Slider("ARC", "Min Enemies to Auto R",3,1,6,1)

MalphiteMenu:SubMenu("Draw", "Drawings")
MalphiteMenu.Draw:Boolean("DAA", "Draw AA Range", true)
MalphiteMenu.Draw:Boolean("DQ", "Draw Q Range", true)
MalphiteMenu.Draw:Boolean("DW", "Draw W Range", true)
MalphiteMenu.Draw:Boolean("DDW", "Draw W Position", true)
MalphiteMenu.Draw:Boolean("DE", "Draw E Range", true)
MalphiteMenu.Draw:Boolean("DR", "Draw R Range", true)
MalphiteMenu.Draw:Boolean("DrawK", "Draw if Target is Killable", true)

MalphiteMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Malphite"] = {"Classic", "Shamrock", "Coral-Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"}}
MalphiteMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
MalphiteMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end


OnTick(function ()

	local QDmg = CalcDamage(myHero, enemy, 0, 20 + 50 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.6)
	local EDmg = CalcDamage(myHero, enemy, 0, 25 + 35 * GetCastLevel(myHero,_E) + GetBonusAP(myHero) * 0.2 + (GetArmor(myHero) * 0.3))
	local RDmg = CalcDamage(myHero, enemy, 0, 100 + 100 * GetCastLevel(myHero,_R) + GetBonusAP(myHero))
	local RStats = {delay = 50, range = 1000, radius = 300, speed = 1835}
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
			if MalphiteMenu.Combo.MMC:Value() >= GetPercentMana(myHero) then 
				CastTargetSpell(target, _Q)	
			end
		end
	end
end)

OnProcessSpell(function(unit,spellProc)	
	if unit.isMe then 
		print(spellProc)
	end		
end)
