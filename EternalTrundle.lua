if GetObjectName(GetMyHero()) ~= "Trundle" then return end
	
local ver = "0.01"

if not FileExist(COMMON_PATH.. "Analytics.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

require("Analytics")

Analytics("Eternal Trundle", "Toshibiotro", true)

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalTrundle.lua", SCRIPT_PATH .. "EternalTrundle.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalTrundle.version", AutoUpdate)

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

local TrundleMenu = Menu("Trundle", "Trundle")
TrundleMenu:SubMenu("Combo", "Combo")
TrundleMenu.Combo:Boolean("CQ", "Use Q", true)
TrundleMenu.Combo:Boolean("CW", "Use W", true)		
TrundleMenu.Combo:Boolean("CE", "Use E", true)
TrundleMenu.Combo:Boolean("CR", "Use R", true)
TrundleMenu.Combo:Boolean("CTH", "Use T Hydra", true)

local target = GetCurrentTarget

OnTick(function()
	local target = GetCurrentTarget()
end)

OnProcessSpellComplete(function(unit,spell)
	local target = GetCurrentTarget()
	if TrundleMenu.Combo.CTH:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero and not Ready(_Q) then
		if Mix:Mode() == "Combo" then
			local TH = GetItemSlot(myHero, 3748)
			if TH > 0 then 
				if Ready(TH) then
					CastSpell(TH)
					DelayAction(function()
						AttackUnit(spell.target)
					end, spell.windUpTime)
				end
			end
		end
	end
	
	if TrundleMenu.Combo.CQ:Value() and unit.isMe and spell.name:lower():find("attack") and spell.target.isHero then
		if Mix:Mode() == "Combo" then
			if Ready(_Q) then
				CastTargetSpell(_Q, target)
				DelayAction(function()
					AttackUnit(spell.target)
				end, spell.windUpTime)
			end
		end
	end
end)		
