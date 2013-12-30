--[[
        © 2012 CloudSixteen.com do not share, re-distribute or modify
        without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("CharGiveAug");

COMMAND.tip = "Grant choosen character an augmentation.";
COMMAND.text = "<string Name> <string Augment>";
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER);
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.player:HasFlags(player, "G")) then
		local target = Clockwork.player:FindByID(arguments[1]);
		
		if (target) then
			local augmentTable = PhaseFour.augment:FindByID(arguments[2]);
			
			if (augmentTable and !augmentTable.PhaseFour.augment) then
				local augmentTable = PhaseFour.augment:Give(augmentTable(player, augment));
				local bSuccess, fault = target:GiveAugment(augmentTable, true);
				
				if (bSuccess) then
					if (string.sub(augmentTable("name"), -1) == "s") then
						Clockwork.player:Notify(player, "You have given "..target:Name().." some "..augmentTable("name")..".");
					else
						Clockwork.player:Notify(player, "You have given "..target:Name().." a "..augmentTable("name")..".");
					end;
					
					if (player != target) then
						if (string.sub(augmentTable("name"), -1) == "s") then
							Clockwork.player:Notify(target, player:Name().." has given you some "..augmentTable("name")..".");
						else
							Clockwork.player:Notify(target, player:Name().." has given you a "..augmentTable("name")..".");
						end;
					end;
			else
				Clockwork.player:Notify(player, "This is not a valid augment!");
			end;
		else
			Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		Clockwork.player:Notify(player, "I'm sorry, it seems like you cannot be trusted with this command!");
	end;
end;

COMMAND:Register();