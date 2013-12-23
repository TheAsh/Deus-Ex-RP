--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Los Angeles Police Department");
	CLASS.wages = 30;
	CLASS.color = Color(0, 65, 255, 255);
	CLASS.factions = {FACTION_LAPD};
	CLASS.isDefault = true;
	CLASS.wagesName = "Salary";
	CLASS.description = "A police officer for Los Angeles.";
	CLASS.defaultPhysDesc = "Wearing tidy police uniform.";
CLASS_LAPD = CLASS:Register();
