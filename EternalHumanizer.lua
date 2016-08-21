local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalHumanizer.lua", SCRIPT_PATH .. "EternalHumanizer.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end
GetWebResultAsync("https://raw.githubusercontent.com/Toshibiotro/stuff/master/EternalHumanizer.lua", AutoUpdate)

local HumanizerMenu = Menu("Humanizer", "Eternal Humanizer")
HumanizerMenu:Boolean("Enabled", "Enabled", true)
HumanizerMenu:Slider("MPS", "Movements Per Second", 6, 0, 30, 1)
HumanizerMenu:Slider("SPS", "Spells Per Second", 3, 0, 10, 1)
HumanizerMenu:Boolean("Draw", "Draw Statistics", true)

local lastorder = 0
local totalmovements = 0
local allowedmovements = 0
local blockedmovements = 0
local lastspell = 0
local totalspells = 0
local allowedspells = 0
local blockedspells = 0

function Mode()
    if _G.IOW_Loaded and IOW:Mode() then
        return IOW:Mode()
        elseif _G.PW_Loaded and PW:Mode() then
        return PW:Mode()
        elseif _G.DAC_Loaded and DAC:Mode() then
        return DAC:Mode()
        elseif _G.AutoCarry_Loaded and DACR:Mode() then
        return DACR:Mode()
        elseif _G.SLW_Loaded and SLW:Mode() then
        return SLW:Mode()
	elseif _G.GoSWalkLoaded and _G.GoSWalk.CurrentMode == 0 then
	return "Combo"
	elseif _G.GoSWalkLoaded and _G.GoSWalk.CurrentMode == 1 then
	return "Harass"
	elseif _G.GoSWalkLoaded and _G.GoSWalk.CurrentMode == 2 then
	return "LaneClear"
	elseif _G.GoSWalkLoaded and _G.GoSWalk.CurrentMode == 3 then
	return "LastHit"
	else
	return ""
    end
end

function Orbing()
	if Mode() ~= "" then
		return true
		else
		return false
	end
end		

OnDraw(function()
	if HumanizerMenu.Draw:Value() then
		DrawText("TotalMovements: "..totalmovements, 20, 40, 280, GoS.White)
		DrawText("BlockedMovements: "..blockedmovements, 20, 40, 300, GoS.White)
		DrawText("AllowedMovements: "..allowedmovements, 20, 40, 320, GoS.White)
		DrawText("TotalSpells: "..totalspells, 20, 40, 360, GoS.White)
		DrawText("BlockedSpells: "..blockedspells, 20, 40, 380, GoS.White)
		DrawText("AllowedSpells: "..allowedspells, 20, 40, 400, GoS.White)
	end	
end)	

OnIssueOrder(function(order)
	if order.flag == 2 then
		if HumanizerMenu.Enabled:Value() and Orbing() then
			if GetGameTimer() - lastorder < 1/HumanizerMenu.MPS:Value() then
				BlockOrder()
				blockedmovements = blockedmovements + 1 
				else
				lastorder = GetGameTimer()
				allowedmovements = allowedmovements + 1
			end	
		end
		totalmovements = totalmovements + 1
	end	
end)

OnSpellCast(function(spell)
	if HumanizerMenu.Enabled:Value() and Orbing() then
		if GetGameTimer() - lastspell < 1/HumanizerMenu.SPS:Value() then
			BlockCast()
			blockedspells = blockedspells + 1
			else
			lastspell = GetGameTimer()
			allowedspells = allowedspells + 1
		end		
	end
	totalspells = totalspells + 1
end)
