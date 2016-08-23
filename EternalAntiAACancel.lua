local NotNeeded = {"Kalista", "Graves"}
if table.contains(NotNeeded, myHero.charName) then print(myHero.charName.."'s AA Cannot Be Cancelled") return end

local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAntiAACancel.lua", SCRIPT_PATH .. "EternalAntiAACancel3.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalAntiAACancel.version", AutoUpdate)

local AntiAACancelMenu = Menu("AAACM", "AntiAACancel")
AntiAACancelMenu:Boolean("EnabledM", "Enabled for Movements", true)
--AntiAACancelMenu:Boolean("EnabledS", "Enabled for Spells", true)
AntiAACancelMenu:Boolean("Draw", "Draw Statistics", true)

local WindingUp = false
-- Thanks Inspired
local altAttacks = { "caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3" }
local AACancelsPrevented = 0

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
	if AntiAACancelMenu.EnabledM:Value() and order.flag == 2 and WindingUp == true then
		BlockOrder()
		AACancelsPrevented = AACancelsPrevented + 1
	end
end)
	
--[[
OnSpellCast(function(spell)
	if AntiAACancelMenu.EnabledS:Value() and WindingUp == true then
		BlockCast()
		AACancelsPrevented = AACancelsPrevented + 1
	end
end)	
--]]

print("AntiAACancel Loaded")
