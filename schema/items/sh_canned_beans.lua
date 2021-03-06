--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Canned Beans";
ITEM.cost = 30;
ITEM.model = "models/props_lab/jar01b.mdl";
ITEM.weight = 0.6;
ITEM.access = "v";
ITEM.useText = "Eat";
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A tinned can, it slushes when you shake it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + 5, 0, player:GetMaxHealth()));
	player:BoostAttribute(self.name, ATB_ENDURANCE, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();
