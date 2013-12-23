--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Iluminati");
	CLASS.wages = 50;
	CLASS.color = Color(150, 125, 100, 255);
	CLASS.factions = {FACTION_CIVILIAN};
	CLASS.isDefault = true;
	CLASS.wagesName = "Salary";
	CLASS.description = "The not so casual civilian within the city.";
	CLASS.defaultPhysDesc = "Wearing new clothing";
CLASS_CIVILIAN = CLASS:Register();
