--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("LIMB");
	CLASS.wages = 50;
	CLASS.color = Color(056, 082, 073, 255);
	CLASS.factions = {FACTION_CORP};
	CLASS.isDefault = true;
	CLASS.wagesName = "Salary";
	CLASS.description = "A worker at the LIMB clinic.";
	CLASS.defaultPhysDesc = "Wearing a clean LIMB uniform.";
CLASS_LIMB = CLASS:Register();
