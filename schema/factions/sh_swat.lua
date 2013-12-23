--[[
        © 2013 CloudSixteen.com do not share, re-distribute or modify
        without permission of its author (kurozael@gmail.com).
--]]

local FACTION = Clockwork.faction:New("Special Weapons and Tactics");

FACTION.useFullName = true;
FACTION.whitelist = true;
FACTION.material = "wip";
FACTION.models = {
        female = {
                        "mmodels/europee_orange1.mdl",

        },
        male = {
                        "models/europee_orange1.mdl",

        };
};

-- Called when a player is transferred to the faction.
function FACTION:OnTransferred(player, faction, name)
        if (faction.name != FACTION_CIVILLIAN) then
                return false;
        end;
end;

FACTION_SWAT = FACTION:Register();
