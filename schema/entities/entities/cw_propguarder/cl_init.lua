--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local guarding = 0;
	local position = self:GetPos();
	
	y = Clockwork.kernel:DrawInfo("Prop Guarder", x, y, colorTargetID, alpha);
	
	for k, v in ipairs(ents.FindByClass("prop_physics")) do
		if (v:GetPos():Distance(position) <= 512) then
			guarding = guarding + 1;
		end;
	end;
	
	y = Clockwork.kernel:DrawInfo("This is guarding "..guarding.." prop(s).", x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	local entIndex = self:EntIndex();
		GENERATOR_OUTLINE_LIST[entIndex] = self;
	self:DrawModel();
end;