--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "X36-9mm";
	ITEM.cost = 240;
	ITEM.model = "models/items/combine_rifle_ammo01.mdl";
	ITEM.weight = 1;
	ITEM.access = "V";
	ITEM.business = true;
	ITEM.ammoClass = "ar2altfire";
	ITEM.ammoAmount = 90;
	ITEM.description = "A small capsule that is used to charge weapons that use laser technology.";
	ITEM.requiresGunsmith = true;
ITEM:Register();
