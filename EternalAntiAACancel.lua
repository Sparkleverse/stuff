local NotNeeded = {"Kalista", "Graves"}
if table.contains(NotNeeded, myHero.charName) then print(myHero.charName.."'s AA Cannot Be Cancelled") return end

local ver = "0.02"

function AutoUpdate(data)
    if GetUser() == "Toshibiotro" then return end
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAntiAACancel.lua", SCRIPT_PATH .. "EternalAntiAACancel.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAntiAACancel.version", AutoUpdate)

local AntiAACancelMenu = Menu("AAACM", "AntiAACancel")
AntiAACancelMenu:Boolean("EnabledM", "Enabled for Movements", true)
AntiAACancelMenu:Boolean("EnabledS", "Enabled for Spells", true)
AntiAACancelMenu:Boolean("EC", "Dont Use While Evading", true)
AntiAACancelMenu:Boolean("Draw", "Draw Statistics", true)

local WindingUp = false
-- Thanks Inspired
local altAttacks = { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
local sicktablename = {
	["Aatrox"] = {1},
	["Amumu"] = {1},
	["Anivia"] = {3},
	["Annie"] = {2},
	["AurelionSol"] = {2},
	["Blitzcrank"] = {1},
	["Braum"] = {1, 2},
	["Corki"] = {2},
	["Diana"] = {1},
	["DrMundo"] = {1, 3},
	["Draven"] = {1},
	["Elise"] = {3},
	["Evelynn"] = {1},
	["Fiora"] = {3},
	["Fizz"] = {1},
	["Galio"] = {1},
	["Garen"] = {1},
	["Hecarim"] = {0, 1, 2},
	["Heimerdinger"] = {3},
	["Irelia"] = {1},
	["Janna"] = {0, 2},
	["JarvanIV"] = {1},
	["Jax"] = {2, 3},
	["Jayce"] = {1, 3},
	["Jinx"] = {2},
	["Karma"] = {2, 3},
	["Katarina"] = {1},
	["Kayle"] = {1, 3},
	["KhaZix"] = {3},
	["KogMaw"] = {1},
	["Leona"] = {1},
	["Lissandra"] = {1},
	["Malphite"] = {1},
	["MasterYi"] = {2, 3},
	["MissFortune"] = {1},
	["Mordekaiser"] = {1},
	["Morgana"] = {2},
	["Nami"] = {2},
	["Nocturne"] = {1, 2, 3},
	["Olaf"] = {1, 3},
	["Orianna"] = {0, 1, 2},
	["Poppy"] = {1},
	["Rammus"] = {3},
	["Renekton"] = {0},
	["Rengar"] = {1, 3},
	["Rumble"] = {0, 1},
	["Sejuani"] = {1},
	["Shyvana"] = {1},
	["Singed"] = {0, 3},
	["Sion"] = {1},
	["Sivir"] = {2, 3},
	["Skarner"] = {0, 1},
	["Swain"] = {0, 3},
	["Syndra"] = {0, 1},
	["Teemo"] = {1},
	["Tristana"] = {0},
	["Trundle"] = {1},
	["Tryndamere"] = {0, 3},
	["Twitch"] = {0, 3},
	["Udyr"] = {1},
	["Urgot"] = {1},
	["Vayne"] = {3},
	["Viktor"] = {2},
	["Warwick"] = {1, 2},
	["XinZhao"] = {1},
	["Zac"] = {1},
	["Zed"] = {2},
	["Zilean"] = {1}
}

local AACancelsPrevented = 0

function Evading()
	if _G.CE and _G.CE.IsEvading() then
		return true
		elseif _G.GoSEvade and _G.Evading then 
		return true
		else
		return false
	end
end	

OnProcessSpell(function(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") or altAttacks[spell.name:lower()] then
			WindingUp = true
		end	
	end
end)

OnProcessSpellComplete(function(unit, spell)	
	if unit.isMe then
		if spell.name:lower():find("attack") or altAttacks[spell.name:lower()] then
			WindingUp = false
		end	
	end
end)

OnDraw(function()
	if AntiAACancelMenu.Draw:Value() then
		DrawText("AACancelsPrevented: "..AACancelsPrevented, 25, 20, 220, GoS.White)
	end
end)
	
OnAnimation(function(unit, animation)
	if unit.isMe then
		if animation:lower():find("idle") or animation:lower():find("run") then
			WindingUp = false
		end
	end
end)	

OnIssueOrder(function(order)
	if AntiAACancelMenu.EC:Value() and Evading() then return end
	if AntiAACancelMenu.EnabledM:Value() and order.flag == 2 and WindingUp == true then
		BlockOrder()
		AACancelsPrevented = AACancelsPrevented + 1
	end
end)
	
OnSpellCast(function(spell)
	if AntiAACancelMenu.EC:Value() and Evading() then return end
	if AntiAACancelMenu.EnabledS:Value() and WindingUp == true and sicktablename[myHero.charName] and not table.contains(sicktablename[myHero.charName], spell.spellID) then
		BlockCast()
		AACancelsPrevented = AACancelsPrevented + 1
	end
end)	

print("AntiAACancel Loaded")
