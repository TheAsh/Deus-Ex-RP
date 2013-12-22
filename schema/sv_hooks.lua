--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local JETPACK_SOUNDS = {};
local JETPACK_SOUND = Sound("PhysicsCannister.ThrusterLoop");

function PhaseFour:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary and (weapon.SilenceTime or weapon.PistolBurst)) then
		return true;
	end;
end;

function PhaseFour:PlayerSwitchFlashlight(player, on)
	return false;
end;

function PhaseFour:PlayerAdjustDeathInfo(player, info)
	if (PhaseFour.augments:Has(player, AUG_REINCARNATION)) then
		info.spawnTime = info.spawnTime * 0.25;
	end;
end;

function PhaseFour:PlayerCharacterUnloaded(player)
	local nextDisconnect = 0;
	local curTime = CurTime();
	
	if (player.nextDisconnect) then
		nextDisconnect = player.nextDisconnect;
	end;
	
	if (player:HasInitialized()) then
		if (player:GetSharedVar("tied") or curTime < nextDisconnect) then
			self:PlayerDropRandomItems(player, nil, true);
		end;
	end;
end;

function PhaseFour:PlayerCanOrderShipment(player, itemTable)
	if (itemTable("requiresExplosives") and !PhaseFour.augments:Has(player, AUG_EXPLOSIVES)) then
		Clockwork.player:Notify(player, "You need the Explosives augment to craft this!");
		
		return false;
	elseif (itemTable("requiresArmadillo") and !PhaseFour.augments:Has(player, AUG_ARMADILLO)) then
		Clockwork.player:Notify(player, "You need the Armadillo augment to craft this!");
		
		return false;
	elseif (itemTable("requiresGunsmith") and !PhaseFour.augments:Has(player, AUG_GUNSMITH)) then
		Clockwork.player:Notify(player, "You need the Gunsmith augment to craft this!");
		
		return false;
	elseif (itemTable("cost") > 120 and itemTable("batch") > 1) then
		local engRequired = math.floor(math.Clamp(itemTable("cost") / 150, 0, 50));
		local engineering = Clockwork.attributes:Fraction(player, ATB_ENGINEERING, 50, 50);
		
		if (engineering < engRequired) then
			Clockwork.player:Notify(player, "You need an engineering level of "..((100 / 50) * engRequired).."% to craft this!");
			
			return false;
		end;
	end;
end;

function PhaseFour:Tick()
	local curTime = CurTime();
	
	if (!self.nextCleanDecals or curTime >= self.nextCleanDecals) then
		self.nextCleanDecals = curTime + 60;
		
		for k, v in ipairs(_player.GetAll()) do
			v:RunCommand("r_cleardecals");
		end;
	end;
	
	if (!self.nextCleanSounds or curTime >= self.nextCleanSounds) then
		self.nextCleanSounds = curTime + 2;
		
		for k, v in pairs(JETPACK_SOUNDS) do
			if (!IsValid(k)) then
				JETPACK_SOUNDS[k] = nil;
				v:Stop();
			end;
		end;
	end;
end;

function PhaseFour:PlayerUseUnknownItemFunction(player, itemTable, itemFunction)
	if (string.lower(itemFunction) == "cash" and itemTable("cost")) then
		local useSounds = {"buttons/button5.wav", "buttons/button4.wav"};
		local cashBack = itemTable("cost");
		
		if (PhaseFour.augments:Has(player, AUG_BLACKMARKET)) then
			cashBack = cashBack * 0.2;
		elseif (PhaseFour.augments:Has(player, AUG_CASHBACK)) then
			cashBack = cashBack * 0.25;
		else
			return;
		end;
		
		player:TakeItem(itemTable);
		player:EmitSound(useSounds[math.random(1, #useSounds)]);
		Clockwork.player:GiveCash(player, cashBack, "cashed an item");
	end;
end;

function PhaseFour:PlayerSpawnProp(player, model)
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	model = string.lower(model);
	
	if (string.find(model, "fence")) then
		Clockwork.player:Notify(player, "You cannot spawn fence props!");
		
		return false;
	end;
end;

function PhaseFour:PlayerAdjustDropWeaponInfo(player, info)
	if (Clockwork.player:GetWeaponClass(player) == info.itemTable("weaponClass")) then
		info.position = player:GetShootPos();
		info.angles = player:GetAimVector():Angle();
	else
		local gearTable = {
			Clockwork.player:GetGear(player, "Throwable"),
			Clockwork.player:GetGear(player, "Secondary"),
			Clockwork.player:GetGear(player, "Primary"),
			Clockwork.player:GetGear(player, "Melee")
		};
		
		for k, v in pairs(gearTable) do
			if (IsValid(v)) then
				local gearItemTable = v:GetItemTable();
				
				if (gearItemTable
				and gearItemTable.weaponClass == info.itemTable("weaponClass")) then
					local position, angles = v:GetRealPosition();
					
					if (position and angles) then
						info.position = position;
						info.angles = angles;
						break;
					end;
				end;
			end;
		end;
	end;
end;

function PhaseFour:EntityRemoved(entity)
	if (IsValid(entity) and entity:GetClass() == "prop_ragdoll") then
		if (entity.areBelongings) then
			if (table.Count(entity.inventory) > 0 or entity.cash > 0) then
				local belongings = ents.Create("cw_belongings");
				
				belongings:SetAngles(Angle(0, 0, -90));
				belongings:SetData(entity.inventory, entity.cash);
				belongings:SetPos(entity:GetPos() + Vector(0, 0, 32));
				belongings:Spawn();
				
				entity.inventory = nil;
				entity.cash = nil;
			end;
		end;
	end;
end;

function PhaseFour:PlayerAdjustEarnGeneratorInfo(player, info)
	if (info.entity:GetClass() == "cw_rationprinter") then
		if (PhaseFour.augments:Has(player, AUG_THIEVING)) then
			info.cash = info.cash + 30;
		end;
	elseif (info.entity:GetClass() == "cw_rationproducer") then
		if (PhaseFour.augments:Has(player, AUG_METALSHIP)) then
			info.cash = info.cash + 50;
		end;
	end;
end;

function PhaseFour:ClockworkInitPostEntity()
	self:LoadBelongings();
	self:LoadPersonalStorage();
end;

function PhaseFour:PostSaveData()
	self:SaveBelongings();
	self:SavePersonalStorage();
end;

function PhaseFour:PlayerSpray(player)
	if (!player:HasItemByID("spray_can") or player:GetSharedVar("tied")) then
		return true;
	end;
end;

function PhaseFour:ShowSpare1(player)
	local trace = player:GetEyeTraceNoCursor();
	local target = Clockwork.entity:GetPlayer(trace.Entity);

	if (target and target:Alive()) then
		if (!target:GetSharedVar("tied")) then
			Clockwork.player:RunClockworkCommand(player, "InvAction", "zip_tie", "use");
		else
			Clockwork.player:RunClockworkCommand(player, "CharSearch");
		end;
	end;
end;

function PhaseFour:ShowSpare2(player)
	Clockwork.datastream:Start(player, "HotkeyMenu", false);
end;

function PhaseFour:PlayerSpawnObject(player)
	if (player:GetSharedVar("tied")) then
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
		
		return false;
	end;
end;

function PhaseFour:PlayerCanBreachEntity(player, entity)
	if (Clockwork.entity:IsDoor(entity)) then
		if (!Clockwork.entity:IsDoorHidden(entity)) then
			return true;
		end;
	end;
end;

function PhaseFour:PlayerCanRadio(player, text, listeners, eavesdroppers)
	if (player:HasItemByID("handheld_radio")) then
		if (!player:GetCharacterData("frequency")) then
			Clockwork.player:Notify(player, "You need to set the radio frequency first!");
			
			return false;
		end;
	else
		Clockwork.player:Notify(player, "You do not own a radio!");
		
		return false;
	end;
end;

function PhaseFour:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity:IsPlayer() or Clockwork.entity:IsPlayerRagdoll(entity)) then
		return true;
	end;
end;

function PhaseFour:PlayerCanUseDoor(player, door)
	if (player:GetSharedVar("tied")) then
		return false;
	end;
end;

function PhaseFour:PlayerAdjustRadioInfo(player, info)
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and v:HasItemByID("handheld_radio")) then
			if (v:GetCharacterData("frequency") == player:GetCharacterData("frequency")) then
				if (!v:GetSharedVar("tied")) then
					info.listeners[v] = v;
				end;
			end;
		end;
	end;
end;

function PhaseFour:CanTool(player, trace, tool)
	if (!Clockwork.player:HasFlags(player, "w")) then
		if (string.sub(tool, 1, 5) == "wire_" or string.sub(tool, 1, 6) == "wire2_") then
			player:RunCommand("gmod_toolmode \"\"");
			return false;
		end;
	end;
end;

function PhaseFour:PlayerSaveCharacterData(player, data)
	if (data["safeboxitems"]) then
		local curSysTime = SysTime();
		data["safeboxitems"] = Clockwork.inventory:ToSaveable(data["safeboxitems"]);
		print("Took: "..(SysTime() - curSysTime));
	end;
end;

function PhaseFour:PlayerRestoreCharacterData(player, data)
	if (!data["victories"]) then data["victories"] = {}; end;
	if (!data["augments"]) then data["augments"] = {}; end;
	if (!data["notepad"]) then data["notepad"] = ""; end;
	if (!data["bounty"]) then data["bounty"] = 0; end;
	if (!data["honor"]) then data["honor"] = 50; end;
	if (!data["title"]) then data["title"] = ""; end;
	if (!data["fuel"]) then data["fuel"] = 100; end;
	
	data["safeboxitems"] = Clockwork.inventory:ToLoadable(data["safeboxitems"] or {});
	data["safeboxcash"] = data["safeboxcash"] or 0;
end;

function PhaseFour:PlayerDoesHaveItem(player, itemTable)
	local safebox = player:GetCharacterData("safeboxitems");
	
	if (safebox and safebox[itemTable("uniqueID")]) then
		return safebox[itemTable("uniqueID")];
	end;
end;

function PhaseFour:PlayerCanEarnGeneratorCash(player, info, cash)
	local positiveHintColor = "positive_hint";
	
	if (PhaseFour.augments:Has(player, AUG_RECKONER)) then
		Clockwork.player:GiveCash(player, info.cash, info.name);
		Clockwork.plugin:Call("PlayerEarnGeneratorCash", player, info, info.cash);
		
		return false;
	elseif (PhaseFour.augments:Has(player, AUG_ACCOUNTANT)) then
		Clockwork.hint:Send(player, "Your character's safebox gained "..Clockwork.kernel:FormatCash(info.cash)..".", 4, positiveHintColor);
		Clockwork.plugin:Call("PlayerEarnGeneratorCash", player, info, info.cash);
		
		player:SetCharacterData("safeboxcash", player:GetCharacterData("safeboxcash") + info.cash);
		
		return false;
	end;
end;

function PhaseFour:PlayerHealed(player, healer, itemTable)
	local action = Clockwork.player:GetAction(player);
	
	if (player:IsGood()) then
		healer:HandleHonor(5);
	else
		healer:HandleHonor(-5);
	end;
	
	if (itemTable("uniqueID") == "health_vial") then
		healer:ProgressAttribute(ATB_DEXTERITY, 15, true);
	elseif (itemTable("uniqueID") == "health_kit") then
		healer:ProgressAttribute(ATB_DEXTERITY, 25, true);
	elseif (itemTable("uniqueID") == "bandage") then
		healer:ProgressAttribute(ATB_DEXTERITY, 5, true);
	end;
end;

function PhaseFour:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("alliance", player:GetCharacterData("alliance", ""));
	player:SetSharedVar("nextDC", player.nextDisconnect or 0);
	player:SetSharedVar("bounty", player:GetCharacterData("bounty"));
	player:SetSharedVar("honor", player:GetCharacterData("honor"));
	player:SetSharedVar("title", player:GetCharacterData("title"));
	player:SetSharedVar("fuel", player:GetCharacterData("fuel"));
	player:SetSharedVar("rank", player:GetCharacterData("rank"));
	
	if (PhaseFour.augments:Has(player, AUG_GHOSTHEART)) then
		player:SetSharedVar("ghostheart", true);
	else
		player:SetSharedVar("ghostheart", false);
	end;
	
	if (player.cancelDisguise) then
		if (curTime >= player.cancelDisguise or !IsValid(player:GetSharedVar("disguise"))) then
			Clockwork.player:Notify(player, "Your disguise has begun to fade away, your true identity is revealed.");
			
			player.cancelDisguise = nil;
			player:SetSharedVar("disguise", NULL);
		end;
	end;
	
	if (player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0) then
		local inventoryWeight = Clockwork.inventory:CalculateWeight(player:GetInventory());

		if (inventoryWeight >= player:GetMaxWeight() / 4) then
			player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true);
		end;
	end;
	
	if (player:GetCash() > 200) then
		PhaseFour.victories:Progress(player, VIC_CODEKGUY);
	end;
end;

function PhaseFour:PlayerUnragdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

function PhaseFour:PlayerRagdolled(player, state, ragdoll)
	Clockwork.player:SetAction(player, "die", false);
end;

function PhaseFour:PlayerThink(player, curTime, infoTable)
	if (player:Alive() and !player:IsRagdolled()) then
		if (!player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK) then
			if (player:IsInWorld()) then
				if (!player:IsOnGround() and player:GetGroundEntity() != game.GetWorld()) then
					player:ProgressAttribute(ATB_ACROBATICS, 0.25, true);
				elseif (infoTable.running) then
					player:ProgressAttribute(ATB_AGILITY, 0.125, true);
				elseif (infoTable.jogging) then
					player:ProgressAttribute(ATB_AGILITY, 0.0625, true);
				end;
			end;
		end;
	end;
	
	local acrobatics = Clockwork.attributes:Fraction(player, ATB_ACROBATICS, 175, 50);
	local aimVector = tostring(player:GetAimVector());
	local strength = Clockwork.attributes:Fraction(player, ATB_STRENGTH, 8, 4);
	local agility = Clockwork.attributes:Fraction(player, ATB_AGILITY, 50, 25);
	local velocity = player:GetVelocity():Length();
	local armor = player:Armor();
	
	if (!player.nextCheckAFK or (player.lastAimVector != aimVector and velocity < 1)) then
		player.nextCheckAFK = curTime + 1800;
		player.lastAimVector = aimVector;
	end;
	
	if (curTime >= player.nextCheckAFK) then
		player:Kick("Kicked for being AFK");
	end;
	
	if (clothes != "") then
		local itemTable = Clockwork.item:FindByID(clothes);
		
		if (itemTable and itemTable("pocketSpace")) then
			infoTable.inventoryWeight = infoTable.inventoryWeight + itemTable("pocketSpace");
		end;
	end;
	
	infoTable.inventoryWeight = infoTable.inventoryWeight + strength;
	infoTable.jumpPower = infoTable.jumpPower + acrobatics;
	infoTable.runSpeed = infoTable.runSpeed + agility;
	
	if (PhaseFour.augments:Has(player, AUG_GODSPEED)) then
		infoTable.runSpeed = infoTable.runSpeed * 1.1;
	end;
	
	if (player.isJetpacking) then
		PhaseFour.victories:Progress(player, VIC_TAKETOTHESKIES, 0.5);
		
		if (PhaseFour.augments:Has(player, AUG_HIGHPOWERED)) then
			player:SetCharacterData("fuel", math.max(player:GetCharacterData("fuel") - 0.138888889, 0));
		else
			player:SetCharacterData("fuel", math.max(player:GetCharacterData("fuel") - 0.277777778, 0));
		end;
		
		if (!JETPACK_SOUNDS[player]) then
			JETPACK_SOUNDS[player] = CreateSound(player, JETPACK_SOUND);
			JETPACK_SOUNDS[player]:PlayEx(0.5, 100 + Clockwork.attributes:Fraction(player, ATB_AERODYNAMICS, 50, 50));
		end;
	elseif (JETPACK_SOUNDS[player]) then
		JETPACK_SOUNDS[player]:Stop();
		JETPACK_SOUNDS[player] = nil;
	end;
	
	local mediumKevlar = Clockwork.item:FindByID("medium_kevlar");
	local heavyKevlar = Clockwork.item:FindByID("heavy_kevlar");
	local lightKevlar = Clockwork.item:FindByID("kevlar_vest");
	local playerGear = Clockwork.player:GetGear(player, "KevlarVest");
	
	if (armor > 100) then
		if (!playerGear or playerGear:GetItemTable() != heavyKevlar) then
			Clockwork.player:CreateGear(player, "KevlarVest", heavyKevlar);
		end;
	elseif (armor > 50) then
		if (!playerGear or playerGear:GetItemTable() != mediumKevlar) then
			Clockwork.player:CreateGear(player, "KevlarVest", mediumKevlar);
		end;
	elseif (armor > 0) then
		if (!playerGear or playerGear:GetItemTable() != lightKevlar) then
			Clockwork.player:CreateGear(player, "KevlarVest", lightKevlar);
		end;
	end;
end;

function PhaseFour:PlayerOrderShipment(player, itemTable, entity)
	if (itemTable("batch") == 5) then
		self.victories:Progress(player, VIC_BULKBUYER);
	end;
	
	if (itemTable("uniqueID") == "cw_metalcrowbar") then
		self.victories:Progress(player, AUG_FREEMAN);
	end;
	
	player:ProgressAttribute(ATB_ENGINEERING, itemTable("cost") / 3, true);	
end;

function PhaseFour:PlayerCanUseCommand(player, commandTable, arguments)
	if (player:GetSharedVar("tied")) then
		local blacklisted = {
			"OrderShipment",
			"Radio"
		};
		
		if (table.HasValue(blacklisted, commandTable.name)) then
			Clockwork.player:Notify(player, "You cannot use this command when you are tied!");
			
			return false;
		end;
	end;
end;

function PhaseFour:PlayerUse(player, entity)
	local curTime = CurTime();
	
	if (entity.bustedDown) then
		return false;
	end;
	
	if (player:GetSharedVar("tied")) then
		if (entity:IsVehicle()) then
			if (Clockwork.entity:IsChairEntity(entity) or Clockwork.entity:IsPodEntity(entity)) then
				return;
			end;
		end;
		
		if (!player.nextTieNotify or player.nextTieNotify < CurTime()) then
			Clockwork.player:Notify(player, "You cannot use that when you are tied!");
			
			player.nextTieNotify = CurTime() + 2;
		end;
		
		return false;
	end;
end;

function PhaseFour:PlayerCanDestroyItem(player, itemTable, bNoMessage)
	if (player:GetSharedVar("tied")) then
		if (!bNoMessage) then
			Clockwork.player:Notify(player, "You cannot destroy items when you are tied!");
		end;
		
		return false;
	end;
end;

function PhaseFour:PlayerCanDropItem(player, itemTable, bNoMessage)
	if (player:GetSharedVar("tied")) then
		if (!bNoMessage) then
			Clockwork.player:Notify(player, "You cannot drop items when you are tied!");
		end;
		
		return false;
	end;
end;

function PhaseFour:PlayerCanUseItem(player, itemTable, bNoMessage)
	if (player:GetSharedVar("tied")) then
		if (!bNoMessage) then
			Clockwork.player:Notify(player, "You cannot use items when you are tied!");
		end;
		
		return false;
	end;
	
	if (Clockwork.item:IsWeapon(itemTable) and !itemTable("fakeWeapon")) then
		local throwableWeapon = nil;
		local secondaryWeapon = nil;
		local primaryWeapon = nil;
		local meleeWeapon = nil;
		local fault = nil;
		
		for k, v in ipairs(player:GetWeapons()) do
			local weaponTable = Clockwork.item:GetByWeapon(v);
			
			if (weaponTable and !weaponTable("fakeWeapon")) then
				if (!weaponTable:IsMeleeWeapon()
				and !weaponTable:IsThrowableWeapon()) then
					if (weaponTable.weight <= 2) then
						secondaryWeapon = true;
					else
						primaryWeapon = true;
					end;
				elseif (weaponTable:IsThrowableWeapon()) then
					throwableWeapon = true;
				else
					meleeWeapon = true;
				end;
			end;
		end;
		
		if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
			if (itemTable.weight <= 2) then
				if (secondaryWeapon) then
					fault = "You cannot use another secondary weapon!";
				end;
			elseif (primaryWeapon) then
				fault = "You cannot use another secondary weapon!";
			end;
		elseif (itemTable:IsThrowableWeapon()) then
			if (throwableWeapon) then
				fault = "You cannot use another throwable weapon!";
			end;
		elseif (meleeWeapon) then
			fault = "You cannot use another melee weapon!";
		end;
		
		if (fault) then
			if (!noMessage) then
				Clockwork.player:Notify(player, fault);
			end;
			
			return false;
		end;
	end;
end;

function PhaseFour:PlayerCanSayLOOC(player, text)
	if (!player:Alive()) then
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
end;

function PhaseFour:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
		if (info.class != "ooc" and info.class != "looc") then
			if (IsValid(info.speaker) and info.speaker:HasInitialized()) then
				if (string.sub(info.text, 1, 1) == "?") then
					info.text = string.sub(info.text, 2);
					info.data.anon = true;
				end;
			end;
		end;
	end;
end;

function PhaseFour:PlayerDestroyGenerator(player, entity, generator)
	local owner = entity:GetPlayer();
	
	if (IsValid(owner) and owner:IsGood()) then
		if (PhaseFour.augments:Has(player, AUG_PAYBACK)) then
			Clockwork.player:GiveCash(player, generator.cash, "destroying a "..string.lower(generator.name));
			
			return;
		end;
	end;
	
	Clockwork.player:GiveCash(player, generator.cash / 2, "destroying a "..string.lower(generator.name));
end;

function PhaseFour:PlayerDeath(player, inflictor, attacker, damageInfo)
	self.victories:Progress(player, VIC_BULLYVICTIM);
	
	if (PhaseFour.augments:Has(player, AUG_FLASHMARTYR)) then
		self:SpawnFlash(player:GetPos());
	elseif (PhaseFour.augments:Has(player, AUG_TEARMARTYR)) then
		self:SpawnTearGas(player:GetPos());
	end;
	
	if (attacker:IsPlayer()) then
		local listeners = {};
		local weapon = attacker:GetActiveWeapon();
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized() and Clockwork.player:IsAdmin(v)) then
				listeners[#listeners + 1] = v;
			end;
		end;
		
		if (#listeners > 0) then
			Clockwork.chatBox:Add(listeners, attacker, "killed", "", {victim = player});
		end;
		
		if (IsValid(weapon)) then
			Clockwork.datastream:Start(player, "Death", weapon);
		else
			Clockwork.datastream:Start(player, "Death", true);
		end;
		
		if (player:IsBad()) then
			self.victories:Progress(attacker, VIC_DEVILHUNTER);
			attacker:HandleHonor(5);
		else
			self.victories:Progress(attacker, VIC_SAINTHUNTER);
			attacker:HandleHonor(-5);
		end;
		
		if (player:IsWanted() and player:GetAlliance() != attacker:GetAlliance()
		or (player:GetAlliance() == nil and attacker:GetAlliance() == nil)) then
			self.victories:Progress(attacker, VIC_BOUNTYHUNTER);
				Clockwork.player:GiveCash(attacker, player:GetBounty(), "bounty hunting");
			player:RemoveBounty();
		end;
	else
		Clockwork.datastream:Start(player, "Death", true);
	end;
	
	if (damageInfo) then
		local miscellaneousDamage = damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage();
		local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH);
		
		if (miscellaneousDamage or meleeDamage) then
			self:PlayerDropRandomItems(player, player:GetRagdollEntity());
		end;
	end;
end;

function PhaseFour:DoPlayerDeath(player, attacker, damageInfo)
	self:TiePlayer(player, false, true);
	
	player.beingSearched = nil;
	player.searching = nil;
end;

function PhaseFour:PlayerAdjustOrderItemTable(player, itemTable)
	if (PhaseFour.augments:Has(player, AUG_MERCANTILE)) then
		itemTable.cost = itemTable("cost") * 0.9;
	end;
end;

function PhaseFour:PlayerStorageShouldClose(player, storage)
	local entity = player:GetStorageEntity();
	
	if (player.searching and entity:IsPlayer() and !entity:GetSharedVar("tied")) then
		return true;
	end;
end;

function PhaseFour:PlayerAttributeUpdated(player, attributeTable, amount)
	local currentPoints = Clockwork.attributes:Get(player, attributeTable.uniqueID, true);
	
	if (!currentPoints) then
		return;
	end;
	
	if (currentPoints >= attributeTable.maximum) then
		if (attributeTable.uniqueID == ATB_ENDURANCE) then
			self.victories:Progress(player, VIC_SNAKESKIN);
		elseif (attributeTable.uniqueID == ATB_DEXTERITY) then
			self.victories:Progress(player, VIC_QUICKHANDS);
		elseif (attributeTable.uniqueID == ATB_AGILITY) then
			self.victories:Progress(player, VIC_GONZALES);
		elseif (attributeTable.uniqueID == ATB_STRENGTH) then
			self.victories:Progress(player, VIC_MIKETYSON);
		end;
	elseif (currentPoints >= 50) then
		if (attributeTable.uniqueID == ATB_ACROBATICS) then
			self.victories:Progress(player, VIC_FIDDYACRO);
		end;
	end;
end;

function PhaseFour:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local team = player:Team();
	
	if (!lightSpawn) then
		Clockwork.datastream:Start(player, "ClearEffects", false);
		
		player:SetSharedVar("disguise", NULL);
		player.cancelDisguise = nil;
		player.beingSearched = nil;
		player.searching = nil;
	end;
	
	if (player:GetSharedVar("tied")) then
		self:TiePlayer(player, true);
	end;
end;

function PhaseFour:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	local clothesItem = player:GetClothesItem();
	
	if (clothesItem) then
		if (player:IsRunning() or player:IsJogging()) then
			local runSound = clothesItem("runSound");
			
			if (runSound) then
				if (type(clothesItem.runSound) == "table") then
					sound = runSound[ math.random(1, #runSound) ];
				else
					sound = runSound;
				end;
			end;
		else
			local walkSound = clothesItem("walkSound");
			
			if (walkSound) then
				if (type(walkSound) == "table") then
					sound = walkSound[ math.random(1, #walkSound) ];
				else
					sound = walkSound;
				end;
			end;
		end;
	end;
	
	player:EmitSound(sound);
	return true;
end;

function PhaseFour:PlayerPunchThrown(player)
	player:ProgressAttribute(ATB_STRENGTH, 0.25, true);
end;

function PhaseFour:PlayerPunchEntity(player, entity)
	if (entity:IsPlayer() or entity:IsNPC()) then
		player:ProgressAttribute(ATB_STRENGTH, 1, true);
	else
		player:ProgressAttribute(ATB_STRENGTH, 0.5, true);
	end;
end;

function PhaseFour:EntityBreached(entity, activator)
	if (Clockwork.entity:IsDoor(entity)) then
		Clockwork.entity:OpenDoor(entity, 0, true, true);
		
		if (IsValid(activator)) then
			self.victories:Progress(activator, VIC_BLOCKBUSTER);
		end;
	end;
end;

function PhaseFour:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	local curTime = CurTime();
	local alliance = player:GetAlliance();
	
	if (damageInfo:IsBulletDamage()) then
		if (player:Armor() > 0) then
			Clockwork.datastream:Start(player, "ShotEffect", 0.25);
		else
			Clockwork.datastream:Start(player, "ShotEffect", 0.5);
		end;
	end;
	
	if (player:Health() <= 10 and math.random() <= 0.75) then
		if (Clockwork.player:GetAction(player) != "die") then
			Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil, nil, Clockwork.kernel:ConvertForce(damageInfo:GetDamageForce() * 32));
			
			if (PhaseFour.augments:Has(player, AUG_ADRENALINE)) then
				local duration = 60;
				
				if (PhaseFour.augments:Has(player, AUG_LONGLASTER)) then
					duration = duration / 2;
				end;
				
				Clockwork.player:SetAction(player, "die", duration, 1, function()
					if (IsValid(player) and player:Alive()) then
						Clockwork.player:SetRagdollState(player, RAGDOLL_NONE);
						player:SetHealth(10);
					end;
				end);
				
				player.nextDisconnect = curTime + duration + 30;
			else
				local duration = 60;
				
				if (PhaseFour.augments:Has(player, AUG_LONGLASTER)) then
					duration = duration * 2;
				end;
				
				Clockwork.player:SetAction(player, "die", duration, 1, function()
					if (IsValid(player) and player:Alive()) then
						player:TakeDamage(player:Health() * 2, attacker, inflictor);
					end;
				end);
				
				player.nextDisconnect = curTime + duration + 30;
			end;
		end;
	end;
	
	if (attacker:IsPlayer()) then
		Clockwork.datastream:Start(player, "TakeDmg", { attacker, damageInfo:GetDamage() });
		Clockwork.datastream:Start(attacker, "DealDmg", { player, damageInfo:GetDamage() });
		
		if (attacker:IsGood() and player:IsBad()) then
			if (PhaseFour.augments:Has(attacker, AUG_BLOODDONOR)) then
				local health = math.Round(damageInfo:GetDamage() * 0.1);
				
				if (health > 0) then
					attacker:SetHealth(math.Clamp(attacker:Health() + health, 0, attacker:GetMaxHealth()));
				end;
			end;
		end;
		
		if (alliance and attacker:GetAlliance() != alliance) then
			for k, v in ipairs(_player.GetAll()) do
				if (v:HasInitialized() and v:GetAlliance() == alliance) then
					Clockwork.datastream:Start(v, "TargetOutline", attacker);
				end;
			end;
		end;
		
		if (damageInfo:IsBulletDamage()) then
			if (PhaseFour.augments:Has(attacker, AUG_INCENDIARY)) then
				if (math.random() >= 0.9 and player:IsBad()) then
					if (!player:IsOnFire()) then
						player:Ignite(5, 0);
					end;
				end;
			elseif (PhaseFour.augments:Has(attacker, AUG_FROZENROUNDS)) then
				if (math.random() >= 0.9 and player:IsGood()) then
					if (!player:IsRagdolled()) then
						Clockwork.player:SetRagdollState(player, RAGDOLL_FALLENOVER, 5);
						
						local ragdollEntity = player:GetRagdollEntity();
						
						if (IsValid(ragdollEntity)) then
							Clockwork.entity:StatueRagdoll(ragdollEntity);
						end;
					end;
				end;
			end;
		end;
	end;
	
	if (!player.nextDisconnect or curTime > player.nextDisconnect + 60) then
		player.nextDisconnect = curTime + 60;
	end;
end;

function PhaseFour:PlayerLimbDamageHealed(player, hitGroup, amount)
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, false);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, false);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, false);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, false);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, false);
	end;
end;

function PhaseFour:PlayerLimbDamageReset(player)
	player:BoostAttribute("Limb Damage", nil, false);
end;

function PhaseFour:PlayerLimbTakeDamage(player, hitGroup, damage)
	local limbDamage = Clockwork.limb:GetDamage(player, hitGroup);
	
	if (hitGroup == HITGROUP_HEAD) then
		player:BoostAttribute("Limb Damage", ATB_DEXTERITY, -limbDamage);
	elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH) then
		player:BoostAttribute("Limb Damage", ATB_ENDURANCE, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
		player:BoostAttribute("Limb Damage", ATB_ACROBATICS, -limbDamage);
		player:BoostAttribute("Limb Damage", ATB_AGILITY, -limbDamage);
	elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
		player:BoostAttribute("Limb Damage", ATB_STRENGTH, -limbDamage);
	end;
end;

function PhaseFour:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	local endurance = Clockwork.attributes:Fraction(player, ATB_ENDURANCE, 0.4, 0.5);
	local clothesItem = player:GetClothesItem();
	local curTime = CurTime();
	
	if (hitGroup == HITGROUP_HEAD and PhaseFour.augments:Has(player, AUG_HEADPLATE)) then
		if (math.random() <= 0.5) then
			damageInfo:SetDamage(0);
		end;
	end;
	
	if (damageInfo:GetDamage() > 0 and hitGroup == HITGROUP_HEAD) then
		if (attacker:IsPlayer() and PhaseFour.augments:Has(attacker, AUG_RECYCLER)) then
			if (math.random() <= 0.5) then
				attacker:SetHealth(math.Clamp(attacker:Health() + (damageInfo:GetDamage() / 2), 0, attacker:GetMaxHealth()));
			end;
		end;
	end;
	
	if (damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)) then
		if (PhaseFour.augments:Has(player, AUG_BLUNTDEFENSE)) then
			damageInfo:ScaleDamage(0.75);
		end;
	end;
	
	if (attacker:GetClass() == "entityflame") then
		if (!player.nextTakeBurnDamage or curTime >= player.nextTakeBurnDamage) then
			player.nextTakeBurnDamage = curTime + 0.1;
			
			damageInfo:SetDamage(1);
		else
			damageInfo:SetDamage(0);
		end;
	end;
	
	if (damageInfo:IsFallDamage()) then
		if (PhaseFour.augments:Has(player, AUG_LEGBRACES)) then
			damageInfo:ScaleDamage(0.5);
		end;
	else
		damageInfo:ScaleDamage(1.25 - endurance);
	end;
	
	if (clothesItem) then
		if (clothesItem("armorScale")) then
			damageInfo:ScaleDamage(1 - (clothesItem("armorScale") * 0.6));
		end;
		
		local itemLevel = clothesItem:GetData("Level");
		
		if (itemLevel) then
			damageInfo:ScaleDamage(1.05 - (itemLevel * 0.05));
		end;
	end;
	
	if (attacker:IsPlayer() and attacker:IsBad() and player:IsGood()) then
		if (PhaseFour.augments:Has(attacker, AUG_HOLLOWPOINT)) then
			damageInfo:ScaleDamage(1.1);
		end;
	end;
	
	if (Clockwork.player:GetAction(player) == "die") then
		if (PhaseFour.augments:Has(player, AUG_BORNSURVIVOR)) then
			damageInfo:ScaleDamage(0);
		end;
	end;
	
	if (attacker:IsPlayer()) then
		local itemTable = Clockwork.item:GetByWeapon(attacker:GetActiveWeapon());
		
		if (itemTable) then
			local itemLevel = itemTable:GetData("Level");
			if (not itemLevel) then return; end;
			
			damageInfo:ScaleDamage(0.8 + (0.2 * itemLevel));
		end;
	end;
end;

function PhaseFour:EntityTakeDamage(entity, damageInfo)
	local inflictor, attacker, amount = damageInfo:GetInflictor(), damageInfo:GetAttacker(), damageInfo:GetDamage();
	local curTime = CurTime();
	local player = Clockwork.entity:GetPlayer(entity);
	
	if (player) then
		if (!player.nextEnduranceTime or CurTime() > player.nextEnduranceTime) then
			player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true);
			player.nextEnduranceTime = CurTime() + 2;
		end;
	end;
	
	if (attacker:IsPlayer()) then
		local weapon = Clockwork.player:GetWeaponClass(attacker);
		
		if (weapon == "weapon_crowbar") then
			if (entity:IsPlayer()) then
				damageInfo:ScaleDamage(0.1);
			else
				damageInfo:ScaleDamage(0.8);
			end;
		end;
		
		if (entity:GetClass() == "prop_physics") then
			for k, v in ipairs(ents.FindByClass("cw_propguarder")) do
				if (entity:GetPos():Distance(v:GetPos()) < 512) then
					damageInfo:ScaleDamage(0.5);
					
					return;
				end;
			end;
			
			if (damageInfo:IsBulletDamage()) then
				damageInfo:ScaleDamage(0.5);
			end;
			
			local boundingRadius = entity:BoundingRadius() * 12;
			entity.health = entity.health or boundingRadius;
			entity.health = math.max(entity.health - damageInfo:GetDamage(), 0);
			
			local blackness = (255 / boundingRadius) * entity.health;
			entity:SetColor(blackness, blackness, blackness, 255);
			
			if (entity.health == 0 and !entity.isDead) then
				if (entity:GetOwnerKey() != attacker:QueryCharacter("key")) then
					self.victories:Progress(attacker, AUG_HOOLIGAN);
				end;
				
				Clockwork.entity:Decay(entity, 5);
				
				entity:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				entity:Ignite(5, 0);
				entity.isDead = true;
			end;
		end;
		
		for k, v in ipairs(ents.FindByClass("cw_doorguarder")) do
			if (entity:GetPos():Distance(v:GetPos()) < 256) then
				local owner = v:GetPlayer();
				
				if (IsValid(owner) and PhaseFour.augments:Has(owner, AUG_REVERSEMAN)) then
					attacker:TakeDamageInfo(damageInfo);
				end;
				
				return;
			end;
		end;
		
		if (damageInfo:IsBulletDamage() and !IsValid(entity.breach)) then
			if (string.lower(entity:GetClass()) == "prop_door_rotating") then
				if (!Clockwork.entity:IsDoorFalse(entity)) then
					local damagePosition = damageInfo:GetDamagePosition();
					
					if (entity:WorldToLocal(damagePosition):Distance(Vector(-1.0313, 41.8047, -8.1611)) <= 8) then
						local effectData = EffectData();
						
						effectData:SetStart(damagePosition);
						effectData:SetOrigin(damagePosition);
						effectData:SetScale(8);
						
						util.Effect("GlassImpact", effectData, true, true);
						
						Clockwork.entity:OpenDoor(entity, 0, true, true, attacker:GetPos());
					end;
				end;
			end;
		end;
	end;
end;

CloudAuthX.External("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");