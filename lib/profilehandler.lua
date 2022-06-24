local status = {
	PlayerId = 0,
	PlayerJob = 0,
	PlayerName = '',
	SettingsFolder = nil,
	CurrentFilters = nil;
};

Self = nil;
SelfPlayer = nil;

status.Init = function()
	if (AshitaCore:GetMemoryManager():GetParty():GetMemberIsActive(0) == 1) then
		Self = GetPlayerEntity()
		SelfPlayer = AshitaCore:GetMemoryManager():GetPlayer()
		gStatus.PlayerId = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0);
		gStatus.PlayerName = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0);
		gStatus.PlayerJob = AshitaCore:GetMemoryManager():GetPlayer():GetMainJob();
		gStatus.SettingsFolder = ('%sconfig\\addons\\simplelog\\%s_%u\\'):fmt(AshitaCore:GetInstallPath(), gStatus.PlayerName, gStatus.PlayerId);
		gStatus.AutoLoadProfile();

		if (get_weapon_skill == nil or get_spell == nil or get_item == nil) then
			gFuncs.PopulateSkills()
			gFuncs.PopulateSpells()
			gFuncs.PopulateItems()
		end
	end
end

status.AutoLoadProfile = function()
	local defaultSettingsFile = gStatus.SettingsFolder .. 'config.lua';
	local defaultFiltersFile = gStatus.SettingsFolder .. 'default_filters.lua';
	local defaultColorsFile = gStatus.SettingsFolder .. 'chat_colors.lua';
	local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));
	
	if (not ashita.fs.exists(defaultSettingsFile)) then
		gFileTools.CreateNewProfile(defaultSettingsFile, 'configuration');
		print(chat.header('SimpleLog') .. chat.message('Created config file: ') .. chat.color1(2, 'config.lua'));
		gStatus.LoadProfile(defaultSettingsFile, 'config');
	elseif (ashita.fs.exists(defaultSettingsFile)) then
		gStatus.LoadProfile(defaultSettingsFile, 'config');	
	end
	
	if (not ashita.fs.exists(jobFiltersFile)) then
		if (not ashita.fs.exists(defaultFiltersFile)) then
			gFileTools.CreateNewProfile(defaultFiltersFile, 'filters');
			print(chat.header('SimpleLog') .. chat.message('Created filters profile: ') .. chat.color1(2, 'default_filters.lua'));
			gStatus.LoadProfile(defaultFiltersFile, 'filters');
		elseif (ashita.fs.exists(defaultFiltersFile)) then
			gStatus.LoadProfile(defaultFiltersFile, 'filters');
		end
	elseif (ashita.fs.exists(jobFiltersFile)) then
		gStatus.LoadProfile(jobFiltersFile, 'filters');	
	end
	
	if (not ashita.fs.exists(defaultColorsFile)) then
		gFileTools.CreateNewProfile(defaultColorsFile, 'colors');
		print(chat.header('SimpleLog') .. chat.message('Created color profile: ') .. chat.color1(2, 'chat_colors.lua'));
		gStatus.LoadProfile(defaultColorsFile, 'colors');
	elseif (ashita.fs.exists(defaultColorsFile)) then
		gStatus.LoadProfile(defaultColorsFile, 'colors');	
	end
end

status.LoadProfile = function(profilePath, profileType)
    local shortFileName = profilePath:match("[^\\]*.$");
    local success, loadError = loadfile(profilePath);

	if (profileType == 'config') then
		if not success then
			gProfileSettings = static_settings;
			print(chat.header('SimpleLog') .. chat.error('Failed to load configuration file: ') .. chat.color1(2, shortFileName)..chat.error('\nSaving will be disabled.'));
			print(chat.header('SimpleLog') .. chat.error(loadError));
			static_config = true
			return;
		end
		gProfileSettings = success();
		if (gProfileSettings ~= nil) then
			print(chat.header('SimpleLog') .. chat.message('Loaded configuration file: ') .. chat.color1(2, shortFileName));
		end
	end
	
	if (profileType == 'filters') then
		if not success then
			local defaultFiltersFile = gStatus.SettingsFolder .. 'default_filters.lua';
			print(chat.header('SimpleLog') .. chat.error('Failed to load filters profile: ') .. chat.color1(2, shortFileName) .. chat.error(' loading defaults: ' .. chat.color1(2, 'default_filters.lua')));
			print(chat.header('SimpleLog') .. chat.error(loadError));
			local default_success, default_loadError = loadfile(defaultFiltersFile)
			if not default_success then
				gProfileFilter = static_filters;
				print(chat.header('SimpleLog') .. chat.error('Failed to load filters profile: ') .. chat.color1(2, 'default_filters.lua')..chat.error('\nSaving will be disabled.'));
				print(chat.header('SimpleLog') .. chat.error(default_loadError));
				static_config = true
				return
			end
			gProfileFilter = default_success();
			gStatus.CurrentFilters = 'default_filters.lua'
			return;
		else
			gProfileFilter = success();
		end
		if (gProfileFilter ~= nil) then
			print(chat.header('SimpleLog') .. chat.message('Loaded filters profile: ') .. chat.color1(2, shortFileName));
			gStatus.CurrentFilters = shortFileName
		end
	end
	
	if (profileType == 'colors') then
		if not success then
			gProfileColor = static_colors;
			print(chat.header('SimpleLog') .. chat.error('Failed to load colors profile: ') .. chat.color1(2, shortFileName)..chat.error('\nSaving will be disabled.'));
			print(chat.header('SimpleLog') .. chat.error(loadError));
			static_config = true
			return;
		end
		gProfileColor = success();
		if (gProfileColor ~= nil) then
			print(chat.header('SimpleLog') .. chat.message('Loaded colors profile: ') .. chat.color1(2, shortFileName));
		end
	end
end

return status;