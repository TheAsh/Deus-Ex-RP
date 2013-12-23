--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Civilian");
	CLASS.wages = 50;
	CLASS.color = Color(150, 125, 100, 255);
	CLASS.factions = {FACTION_CIVILIAN};
	CLASS.isDefault = true;
	CLASS.wagesName = "Supplies";
	CLASS.description = "The casual civilian within the city.";
	CLASS.defaultPhysDesc = "Wearing tattered clothing";
CLASS_CIVILIAN = CLASS:Register();
