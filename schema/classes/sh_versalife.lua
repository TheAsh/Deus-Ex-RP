--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Versalife");
	CLASS.wages = 50;
	CLASS.color = Color(159, 091, 017, 255);
	CLASS.factions = {FACTION_CIVILIAN};
	CLASS.isDefault = true;
	CLASS.wagesName = "Salary";
	CLASS.description = "Staff at versalife laboratories.";
	CLASS.defaultPhysDesc = "Wearing standard versalife clothing";
CLASS_VERSALIFE = CLASS:Register();
