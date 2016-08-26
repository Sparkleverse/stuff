local SkinChangerMenu = Menu("SkinChanger", "SkinChanger")
SkinChangerMenu:Slider("Skin", "Skin", 0, 0, 10, 1)

OnTick(function(myHero)
	HeroSkinChanger(myHero, SkinChangerMenu.Skin:Value())
end)
