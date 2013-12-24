--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("custom_clothes");
	ITEM.cost = 1000;
	ITEM.name = "Combat Uniform";
	ITEM.group = "group03";
	ITEM.weight = 1;
	ITEM.access = "m";
	ITEM.business = true;
	ITEM.armorScale = 0.1;
	ITEM.description = "A combat uniform with a yellow insignia.\nProvides you with 10% bullet resistance.";
ITEM:Register();
