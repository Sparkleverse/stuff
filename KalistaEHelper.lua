if myHero.charName ~= "Kalista" then return end

require("DamageLib")

local kleepo = {
	[1] = {Nome = "Dragon", BNome = "SRU_Dragon"},
	[2] = {Nome = "Baron", BNome = "SRU_Baron"},
	[3] = {Nome = "RiftHerald", BNome = "SRU_RiftHerald"},
	[4] = {Nome = "Red Buff", BNome = "SRU_Red"},
	[5] = {Nome = "Blue Buff", BNome = "SRU_Blue"},
	[6] = {Nome = "ScuttleCrab", BNome = "Sru_Crab"},
	[7] = {Nome = "Gromp", BNome = "SRU_Gromp"},
	[8] = {Nome = "Krug", BNome = "SRU_Krug"},
	[9] = {Nome = "Wolves", BNome = "SRU_Murkwolf"},
	[10] = {Nome = "RazorBeaks", BNome = "SRU_Razorbeak"}
}

local Jungle = {}
local Minions = {}

local KMenu = Menu("K", "Kalista Steal")
KMenu:SubMenu("KS", "KillSteal")
DelayAction(function()
	for _, e in pairs(GetEnemyHeroes()) do
		KMenu.KS:Boolean(e.name, e.charName, true)
	end	
end, 0.01)

KMenu:SubMenu("JS", "JungleSteal")

for a = 1, 10 do
	KMenu.JS:Boolean(kleepo[a].BNome, kleepo[a].Nome, true)
end

KMenu:SubMenu("LH", "LastHit")
KMenu.LH:Boolean("LHM", "LastHit Minions", true)
KMenu.LH:Slider("LHMC", "Min Minions To LastHit", 2, 1, 8, 1)

KMenu:SubMenu("Draw", "Drawings")
KMenu.Draw:Boolean("DE", "Draw Damage On Enemies", true)			

OnObjectLoad(function(o)
	if o.team == MINION_JUNGLE then
		table.insert(Jungle, o)
	end

	if o.team == MINION_ENEMY and o.name:lower():find("minion") then
		table.insert(Minions, o)
	end	
end)

OnCreateObj(function(o)
	if o.team == MINION_JUNGLE then
		table.insert(Jungle, o)
	end	
	
	if o.team == MINION_ENEMY and o.name:lower():find("minion") then
		table.insert(Minions, o)
	end
end)

OnDeleteObj(function(o)
	for _, a in pairs(Jungle) do
		if a == o then
			table.remove(Jungle, _)
		end
	end

	for _, k in pairs(Minions) do
		if k == o then
			table.remove(Minions, _)
		end	
	end
end)

local function Damage(unit)
	if unit == nil or not unit.valid or GetBuffData(unit, "kalistaexpungemarker").Count == 0 or GetCastLevel(myHero, _E) == 0 then return 0 end
	local c = math.min(254, GetBuffData(unit, "kalistaexpungemarker").Count)
	local initial = 10 + (10 * GetCastLevel(myHero, _E)) + (myHero.totalDamage * 0.6)
	local rip = (({10, 14, 19, 25, 32})[GetCastLevel(myHero, _E)]) * c - 1
	local additional = (((0.175 + (0.025 * GetCastLevel(myHero, _E))) * myHero.totalDamage)) * c - 1
	local total = CalcPhysicalDamage(myHero, unit, additional + initial + rip)
	return total
end

local function F()
	local c = 0
	for _, m in pairs(Minions) do
		if ValidTarget(m, 800) and m.health <= Damage(m) then
			c = c + 1
		end
	end
	return c
end

OnTick(function()
	for _, e in pairs(GetEnemyHeroes()) do
		if KMenu.KS[e.name]:Value() and ValidTarget(e, 800) and Ready(_E) and not e.isSpellShielded and e.health + e.shieldAD <= Damage(e) then
			CastSpell(_E)
		end
	end
	
	for _, j in pairs(Jungle) do
		for i = 1, 10 do
			if KMenu.JS[kleepo[i].BNome]:Value() and not j.charName:lower():find("mini") and j.charName:find(kleepo[i].BNome) and ValidTarget(j, 800) and Ready(_E) and j.health <= Damage(j) then
				CastSpell(_E)
			end	
		end	
	end
	
	if KMenu.LH.LHM:Value() and Ready(_E) and F() >= KMenu.LH.LHMC:Value() then
		CastSpell(_E)
	end	
end)

OnDraw(function()
	if myHero.dead then 
		return 
	end
	
	if KMenu.Draw.DE:Value() then
		for _, e in pairs(GetEnemyHeroes()) do
			local d = Damage(e)
			local truehp = e.health + e.shieldAD
			if d > truehp then
				d = truehp
			end
			DrawDmgOverHpBar(e, truehp, d, 0, GoS.White)
		end
	end
end)	

print("Kalista Steal Loaded!")
