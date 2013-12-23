--[[
        � 2013 CloudSixteen.com do not share, re-distribute or modify
        without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("LAPD | Special Weapons and Tactics");
        CLASS.wages = 30;
        CLASS.color = Color(0, 0, 255, 240);
        CLASS.factions = {FACTION_SWAT};
        CLASS.isDefault = true;
        CLASS.wagesName = "Salary";
        CLASS.description = "An elite police officer working for the Los Angeles Police Department.";
        CLASS.defaultPhysDesc = "Wearing heavily geared uniform and a big SWAT symbol on the back of his shirt.";
CLASS_SWAT = CLASS:Register();
