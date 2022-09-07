local ui = {}
local imgui = require('imgui')

local theme = T{
    window_bg = { 0.101, 0.098, 0.098, 0.9 },
    child_bg = { 0.0, 0.0, 0.0, 0.50 },
    header_text_col = { 0.462, 0.647, 0.756, 1.0 },
    desc_text_col = { 0.450, 0.498, 0.529, 1.0 },
    button_create_filt = { 0.094, 0.447, 0.094, 0.9 },
    button_test_colors = { 0.894, 0.525, 0.525, 0.9 },
    button_tab_act_col = { 0.152, 0.298, 0.427, 0.9 },
    button_tab_dis_col = { 0.2, 0.2, 0.2, 0.9 },
    button_hov_col = { 0.2, 0.2, 0.3, 0.9 },
    button_act_col = { 0.3, 0.2, 0.3, 0.9 },
}

local filter_info = {
    filter_order = {
        'Melee',
        'Ranged',
        'Damage',
        'Healing',
        'Misses',
        'Items',
        'Uses',
        'Readies',
        'Casting',
    },

    filter_categories = {
        'Me',
        'Party',
        'Alliance',
        'Others',
        'My Pet',
        'My Fellow',
        'Other Pets',
        'Enemies',
        'Monsters',
    },

    filter_header = {
        enemies = {
            'Enemy \xef\x8c\x8b Player: All Messages',
            'Enemy \xef\x8c\x8b Party: All Messages',
            'Enemy \xef\x8c\x8b Alliance: All Messages',
            'Enemy \xef\x8c\x8b Others: All Messages',
            'Enemy \xef\x8c\x8b My Pet: All Messages',
            'Enemy \xef\x8c\x8b My Fellow: All Messages',
            'Enemy \xef\x8c\x8b Other Pets: All Messages',
            'Enemy \xef\x8c\x8b Enemy: All Messages',
            'Enemy \xef\x8c\x8b Monster: All Messages'
        },
        monsters = {
            'Monster \xef\x8c\x8b Player: All Messages',
            'Monster \xef\x8c\x8b Party: All Messages',
            'Monster \xef\x8c\x8b Alliance: All Messages',
            'Monster \xef\x8c\x8b Others: All Messages',
            'Monster \xef\x8c\x8b My Pet: All Messages',
            'Monster \xef\x8c\x8b My Fellow: All Messages',
            'Monster \xef\x8c\x8b Other Pets: All Messages',
            'Monster \xef\x8c\x8b Enemy: All Messages',
            'Monster \xef\x8c\x8b Monster: All Messages'
        }, 
    },

    filter_descriptions = {
        enemies = {
            'Filter all Enemy \xef\x8c\x8b Player messages',
            'Filter all Enemy \xef\x8c\x8b Party messages',
            'Filter all Enemy \xef\x8c\x8b Alliance messages',
            'Filter all messages from Enemy \xef\x8c\x8b others',
            'Filter all messages from Enemy \xef\x8c\x8b your Pet',
            'Filter all messages from Enemy \xef\x8c\x8b your Fellows',
            'Filter all messages from Enemy \xef\x8c\x8b other Pets',
            'Filter all messages from Enemy \xef\x8c\x8b other Enemies/Self',
            'Filter all messages from Enemy \xef\x8c\x8b other Monsters',
        },
        monsters = {
            'Filter all Monster \xef\x8c\x8b Player messages',
            'Filter all Monster \xef\x8c\x8b Party messages',
            'Filter all Monster \xef\x8c\x8b Alliance messages',
            'Filter all messages from Monster \xef\x8c\x8b others',
            'Filter all messages from Monster \xef\x8c\x8b your Pet',
            'Filter all messages from Monster \xef\x8c\x8b your Fellows',
            'Filter all messages from Monster \xef\x8c\x8b other Pets',
            'Filter all messages from Monster \xef\x8c\x8b other Enemies',
            'Filter all messages from Monster \xef\x8c\x8b other Monsters/Self',
        },
    }
};

local color_info = {
    color_order = {
        'mob',
        'other',
        'p0',
        'p1',
        'p2',
        'p3',
        'p4',
        'p5',
        'al0',
        'al1',
        'al2',
        'al3',
        'al4',
        'al5',
        'a20',
        'a21',
        'a22',
        'a23',
        'a24',
        'a25',
        'mobdmg',
        'mydmg',
        'partydmg',
        'allydmg',
        'otherdmg',
        'spellcol',
        'mobspellcol',
        'abilcol',
        'wscol',
        'mobwscol',
        'statuscol',
        'enfeebcol',
        'itemcol',
    },
    color_name = {
        'Monster',
        'Other',
        'Party Member 1',
        'Party Member 2',
        'Party Member 3',
        'Party Member 4',
        'Party Member 5',
        'Party Member 6',
        'Alliance 1 Member 1',
        'Alliance 1 Member 2',
        'Alliance 1 Member 3',
        'Alliance 1 Member 4',
        'Alliance 1 Member 5',
        'Alliance 1 Member 6',
        'Alliance 2 Member 1',
        'Alliance 2 Member 2',
        'Alliance 2 Member 3',
        'Alliance 2 Member 4',
        'Alliance 2 Member 5',
        'Alliance 2 Member 6',
        'Monster Damage',
        'Player Damage',
        'Party Damage',
        'Ally Damage',
        'Other Damage',
        'Spell Color',
        'Monster Spell Color',
        'Ability Color',
        'Weapon Skill Color',
        'Monster Weapon Skill Color',
        'Status Color',
        'Enfeeblement Color',
        'Item Color',
    },
    color_inputs = {
    }
};

ui.state = T{
    button_pressed = false,
    toggle_menu = false,
    open = T{false},
    tab = 0,
};

--local module = {}

ui.toggle_menu = function (trig)
    if trig == 0 then
        ui.state.toggle_menu = false
    end
    if trig == 1 then
        ui.state.toggle_menu = true
    end
end

ui.render_config = function(toggle)
    if toggle then
        ui.state.open[1] = not ui.state.open[1]
        --print('settings open: '..tostring(ui.state.open))
    end

    if not ui.state.open[1] then
        --print('settings close: '..tostring(ui.state.open))
        return
    end

    imgui.SetNextWindowContentSize({ 330, 430 })
    imgui.SetNextWindowSizeConstraints({ 330, 470 }, { 430, 650 })
    imgui.StyleColorsDark()

    imgui.PushStyleColor(ImGuiCol_WindowBg , theme.window_bg)
    imgui.PushStyleColor(ImGuiCol_TitleBg, theme.child_bg)
    if imgui.Begin(('SimpleLog - v%s'):fmt(addon.version), ui.state.open) then
        imgui.PopStyleColor(2)
        imgui.BeginGroup()
            if ui.state.tab == 0 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            if imgui.Button('\xEF\x82\xAD Settings') then
                ui.state.tab = 0
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('Configuration of addon behavior')
            end
            if ui.state.tab == 1 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            imgui.SameLine()
            if imgui.Button('\xef\x8a\x8d Filters') then
                ui.state.tab = 1
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('Chat log filter settings')
            end
            if ui.state.tab == 2 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            imgui.SameLine()
            if imgui.Button('\xef\x87\xbc Colors') then
                ui.state.tab = 2
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('Chat log color settings')
            end
            imgui.PushStyleColor(ImGuiCol_ChildBg, theme.child_bg)
            imgui.BeginChild('conf_box', { imgui.GetWindowWidth()-16, imgui.GetWindowHeight()-120 }, true)
                imgui.PopStyleColor()
                if ui.state.tab == 0 then
                    local lang_choices = {'English', 'Japanese'}

                    -- Language support yet not fully implemented
                    imgui.PushTextWrapPos(0)
                    imgui.TextColored(theme.desc_text_col, 'Language Option:\nSwitch between English or Japanese message outputs.')
                    -- Temp Warning
                    imgui.TextColored({1.0, 0.0, 0.0, 1.0}, 'EXPERIMENTAL')
                    if imgui.BeginCombo('', lang_choices[gProfileSettings.lang.object]) then
                        if imgui.Selectable('English', choice == 1) then
                            gProfileSettings.lang.object = 1
                            gProfileSettings.lang.internal = 2
                            gProfileSettings.lang.msg_text = 'en'
                        end
                        if imgui.Selectable('Japanese', choice == 2) then
                            gProfileSettings.lang.object = 2
                            gProfileSettings.lang.internal = 1
                            gProfileSettings.lang.msg_text = 'jp'
                        end
                        imgui.EndCombo()
                    end

                    imgui.PushTextWrapPos(0)
                    imgui.TextColored(theme.desc_text_col, 'General Options:\nChange different modes of how the addon output messages.')
                    if imgui.TreeNodeEx('Condese Options', ImGuiTreeNodeFlags_Framed and ImGuiTreeNodeFlags_DefaultOpen and ImGuiTreeNodeFlags_NoTreePushOnOpen ) then
                        local simplify_change = imgui.Checkbox('##simplify', {gProfileSettings.mode.simplify})
                        if simplify_change then
                            gProfileSettings.mode.simplify = not gProfileSettings.mode.simplify
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Simplify')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Condense battle text into shorter custom messages.')

                        imgui.NewLine()
                        local condensetargets_change = imgui.Checkbox('##condensetargets', {gProfileSettings.mode.condensetargets})
                        if condensetargets_change then
                            gProfileSettings.mode.condensetargets = not gProfileSettings.mode.condensetargets
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Condense Targets')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Condense the damage into a single digit.')

                        if gProfileSettings.mode.condensetargets then
                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local targetnumber_change = imgui.Checkbox('##targetnumber', {gProfileSettings.mode.targetnumber})
                            if targetnumber_change then
                                gProfileSettings.mode.targetnumber = not gProfileSettings.mode.targetnumber
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Target Number')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Shows the number of condensed targets.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local condensetargetname_change = imgui.Checkbox('##condensetargetname', {gProfileSettings.mode.condensetargetname})
                            if condensetargetname_change then
                                gProfileSettings.mode.condensetargetname = not gProfileSettings.mode.condensetargetname
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Condense Target Name')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Condenses the the different target names into one.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local oxford_change = imgui.Checkbox('##oxford', {gProfileSettings.mode.oxford})
                            if oxford_change then
                                gProfileSettings.mode.oxford = not gProfileSettings.mode.oxford
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Oxford Comma')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Allows oxford comma.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local commamode_change = imgui.Checkbox('##commamode', {gProfileSettings.mode.commamode})
                            if commamode_change then
                                gProfileSettings.mode.commamode = not gProfileSettings.mode.commamode
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Comma Mode')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Comma-only mode.')
                        end

                        imgui.NewLine()
                        local condensedamage_change = imgui.Checkbox('##condesedamage', {gProfileSettings.mode.condensedamage})
                        if condensedamage_change then
                            gProfileSettings.mode.condensedamage = not gProfileSettings.mode.condensedamage
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Condense Damage')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Condense the damage into a single digit.')

                        if gProfileSettings.mode.condensedamage then
                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local swingnumber_change = imgui.Checkbox('##swingnumber', {gProfileSettings.mode.swingnumber})
                            if swingnumber_change then
                                gProfileSettings.mode.swingnumber = not gProfileSettings.mode.swingnumber
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Swing Number')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Display the number of hits.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local sumdamage_change = imgui.Checkbox('##sumdamage', {gProfileSettings.mode.sumdamage})
                            if sumdamage_change then
                                gProfileSettings.mode.sumdamage = not gProfileSettings.mode.sumdamage
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Sum Damage')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Condese the number of damage, otherwise separed by comma.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local condensecrits_change = imgui.Checkbox('##condensecrits', {gProfileSettings.mode.condensecrits})
                            if condensecrits_change then
                                gProfileSettings.mode.condensecrits = not gProfileSettings.mode.condensecrits
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Condense Crits')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Condese the number of critical damage, otherwise separed by comma.')
                        end
                    end

                    if imgui.TreeNodeEx('Visbility Options', ImGuiTreeNodeFlags_Framed and ImGuiTreeNodeFlags_NoTreePushOnOpen ) then
                        local cancelmultimsg_change = imgui.Checkbox('##cancelmultimsg', {gProfileSettings.mode.cancelmultimsg})
                        if cancelmultimsg_change then
                            gProfileSettings.mode.cancelmultimsg = not gProfileSettings.mode.cancelmultimsg
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Cancel Multiple Messages')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Blocks the spam of identical messages.')

                        imgui.NewLine()
                        local showpetownernames_change = imgui.Checkbox('##showpetownernames', {gProfileSettings.mode.showpetownernames})
                        if showpetownernames_change then
                            gProfileSettings.mode.showpetownernames = not gProfileSettings.mode.showpetownernames
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Pet Owner Names')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Shows the name of pet Owners in messages.')

                        imgui.NewLine()
                        local crafting_change = imgui.Checkbox('##crafting', {gProfileSettings.mode.crafting})
                        if crafting_change then
                            gProfileSettings.mode.crafting = not gProfileSettings.mode.crafting
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Crafting')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Displays early message of Crafting results.')

                        imgui.NewLine()
                        local showblocks_change = imgui.Checkbox('##showblocks', {gProfileSettings.mode.showblocks})
                        if showblocks_change then
                            gProfileSettings.mode.showblocks = not gProfileSettings.mode.showblocks
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Blocks')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Displays block messages.')

                        imgui.NewLine()
                        local showguards_change = imgui.Checkbox('##showguards', {gProfileSettings.mode.showguards})
                        if showguards_change then
                            gProfileSettings.mode.showguards = not gProfileSettings.mode.showguards
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Guards')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Displays guard messages.')

                        imgui.NewLine()
                        local showcritws_change = imgui.Checkbox('##showcritws', {gProfileSettings.mode.showcritws})
                        if showcritws_change then
                            gProfileSettings.mode.showcritws = not gProfileSettings.mode.showcritws
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Critical Weapon Skill')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Displays critical Weapon Skill messages.')

                        imgui.NewLine()
                        local showrollinfo_change = imgui.Checkbox('##showrollinfo', {gProfileSettings.mode.showrollinfo})
                        if showrollinfo_change then
                            gProfileSettings.mode.showrollinfo = not gProfileSettings.mode.showrollinfo
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Roll Info')
                        imgui.PushTextWrapPos(0)
                        imgui.TextColored(theme.desc_text_col, 'Displays Corsair Roll info messages.')
                    end
                    imgui.TreePop(2)
                elseif ui.state.tab == 1 then
                    imgui.PushTextWrapPos(0)
                    imgui.TextColored(theme.desc_text_col, 'Profile: ')
                    imgui.SameLine()
                    imgui.TextColored(theme.button_create_filt, gStatus.CurrentFilters)
                    imgui.PushStyleColor(ImGuiCol_Button, theme.button_create_filt)
                    imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
                    imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
                    if imgui.Button('\xef\x85\x9b Create Job Profile') then
                        local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));
                        local shortFileName = jobFiltersFile:match("[^\\]*.$");

                        if (not ashita.fs.exists(jobFiltersFile)) then
                            gFileTools.CreateNewProfile(jobFiltersFile, 'filters');
                            print(chat.header('SimpleLog') .. chat.message('Created filters profile: ') .. chat.color1(2, shortFileName));
                            gStatus.LoadProfile(jobFiltersFile, 'filters');
                        elseif (ashita.fs.exists(jobFiltersFile)) then
                            imgui.OpenPopup('###file_man')
                        end
                    end
                    
                    imgui.PopStyleColor(3)
                    if imgui.IsItemHovered() then
                        imgui.SetTooltip('Configuration of addon behavior')
                    end

                    local size = imgui.GetIO().DisplaySize
                    local center = { size.x * 0.5, size.y * 0.5 }

                    imgui.SetNextWindowPos(center, ImGuiCond_Appearing, {0.5, 0.5})
                    imgui.SetNextWindowSize({ -1, -1 },  ImGuiCond_Always)

                    if imgui.BeginPopupModal('Overwrite?###file_man', nil, ImGuiWindowFlags_AlwaysAutoResize) then
                        imgui.NewLine()
                        imgui.Text('Profile filter already exists.\nDo you want to replace it?\nFilter Settings will be reset.')
                        imgui.NewLine()
                        imgui.Separator()

                        imgui.SetCursorPosX(imgui.GetCursorPosX() + 45)
                        if imgui.Button('Confirm') then
                            local defaultFiltersFile = ('%saddons\\simplelog\\filters.lua'):fmt(AshitaCore:GetInstallPath());

                            local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));
                            local shortFileName = jobFiltersFile:match("[^\\]*.$");

                            gFileTools.OverwriteProfile(jobFiltersFile, defaultFiltersFile)
                            print(chat.header('SimpleLog') .. chat.message('Recreated filters profile: ') .. chat.color1(2, shortFileName));
                            gStatus.LoadProfile(jobFiltersFile, 'filters');
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button('Cancel') then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end

                    if imgui.BeginTabBar('#filters_bar') then
                        if imgui.BeginTabItem('Player') then
                            local player_me = imgui.Checkbox('##player_me', {gProfileFilter.me.all})
                            if player_me then
                                gProfileFilter.me.all = not gProfileFilter.me.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Player: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all Player messages')

                            local player_checkboxes = {}
                            if not gProfileFilter.me.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    player_checkboxes[i] = imgui.Checkbox(('##player_%s'):fmt(v), {gProfileFilter.me[v:lower()]})
                                    if player_checkboxes[i] then
                                        gProfileFilter.me[v:lower()] = not gProfileFilter.me[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            player_checkboxes[10] = imgui.Checkbox('##player_target', {gProfileFilter.me.target})
                            if player_checkboxes[10] then
                                gProfileFilter.me.target = not gProfileFilter.me.target
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Target')
                            imgui.NewLine()

                            local player_party = imgui.Checkbox('##player_party', {gProfileFilter.party.all})
                            if player_party then
                                gProfileFilter.party.all = not gProfileFilter.party.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Party: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all Party messages')

                            local party_checkboxes = {}
                            if not gProfileFilter.party.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    party_checkboxes[i] = imgui.Checkbox(('##party_%s'):fmt(v), {gProfileFilter.party[v:lower()]})
                                    if party_checkboxes[i] then
                                        gProfileFilter.party[v:lower()] = not gProfileFilter.party[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.NewLine()

                            local player_alliance = imgui.Checkbox('##player_alliance', {gProfileFilter.alliance.all})
                            if player_alliance then
                                gProfileFilter.alliance.all = not gProfileFilter.alliance.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Alliance: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all Alliance messages')

                            local alliance_checkboxes = {}
                            if not gProfileFilter.alliance.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    alliance_checkboxes[i] = imgui.Checkbox(('##alliance_%s'):fmt(v), {gProfileFilter.alliance[v:lower()]})
                                    if alliance_checkboxes[i] then
                                        gProfileFilter.alliance[v:lower()] = not gProfileFilter.alliance[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.NewLine()

                            local player_my_pet = imgui.Checkbox('##player_my_pet', {gProfileFilter.my_pet.all})
                            if player_my_pet then
                                gProfileFilter.my_pet.all = not gProfileFilter.my_pet.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'My Pet: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all messages from your Pet')

                            local my_pet_checkboxes = {}
                            if not gProfileFilter.my_pet.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    my_pet_checkboxes[i] = imgui.Checkbox(('##my_pet_%s'):fmt(v), {gProfileFilter.my_pet[v:lower()]})
                                    if my_pet_checkboxes[i] then
                                        gProfileFilter.my_pet[v:lower()] = not gProfileFilter.my_pet[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Others') then
                            local others_others = imgui.Checkbox('##others_others', {gProfileFilter.others.all})
                            if others_others then
                                gProfileFilter.others.all = not gProfileFilter.others.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Others: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all messages from others')

                            local others_checkboxes = {}
                            if not gProfileFilter.others.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    others_checkboxes[i] = imgui.Checkbox(('##others_%s'):fmt(v), {gProfileFilter.others[v:lower()]})
                                    if others_checkboxes[i] then
                                        gProfileFilter.others[v:lower()] = not gProfileFilter.others[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.NewLine()

                            local others_my_fellow = imgui.Checkbox('##others_my_fellow', {gProfileFilter.my_fellow.all})
                            if others_my_fellow then
                                gProfileFilter.my_fellow.all = not gProfileFilter.my_fellow.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'My Fellow: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all messages from your Fellows')

                            local my_fellow_checkboxes = {}
                            if not gProfileFilter.my_fellow.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    my_fellow_checkboxes[i] = imgui.Checkbox(('##my_fellow_%s'):fmt(v), {gProfileFilter.my_fellow[v:lower()]})
                                    if my_fellow_checkboxes[i] then
                                        gProfileFilter.my_fellow[v:lower()] = not gProfileFilter.my_fellow[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.NewLine()

                            local others_other_pets = imgui.Checkbox('##others_other_pets', {gProfileFilter.other_pets.all})
                            if others_other_pets then
                                gProfileFilter.other_pets.all = not gProfileFilter.other_pets.all
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Other Pets: All Messages')
                            imgui.PushTextWrapPos(0)
                            imgui.TextColored(theme.desc_text_col, 'Filter all messages from other Pets')

                            local other_pets_checkboxes = {}
                            if not gProfileFilter.other_pets.all then
                                for i, v in ipairs(filter_info.filter_order) do
                                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                    imgui.SameLine()
                                    other_pets_checkboxes[i] = imgui.Checkbox(('##other_pets_%s'):fmt(v), {gProfileFilter.other_pets[v:lower()]})
                                    if other_pets_checkboxes[i] then
                                        gProfileFilter.other_pets[v:lower()] = not gProfileFilter.other_pets[v:lower()]
                                    end
                                    imgui.SameLine()
                                    imgui.TextColored(theme.header_text_col, tostring(v))
                                end
                            end
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Enemies') then
                            imgui.TextColored(theme.header_text_col, 'Enemies:')
                            imgui.TextColored(theme.desc_text_col, 'Monster that your party has claimed doing something with one of the below targets:')

                            local enemies_checkboxes = T{all = {}, internal = {}}
                            local enemies_index = 1
                            for i, v in ipairs(filter_info.filter_categories) do
                                local v_int = v:lower():gsub(' ', '_')
                                enemies_checkboxes['all'][i] = imgui.Checkbox(('##enemies_%s'):fmt(v_int), { gProfileFilter.enemies[v_int].all })

                                if enemies_checkboxes['all'][i] then
                                    gProfileFilter.enemies[v_int].all = not gProfileFilter.enemies[v_int].all
                                end
                                imgui.SameLine()
                                imgui.PushTextWrapPos(0)
                                imgui.TextColored(theme.header_text_col, filter_info.filter_header.enemies[i])
                                imgui.PushTextWrapPos(0)
                                imgui.TextColored(theme.desc_text_col, filter_info.filter_descriptions.enemies[i])
                                if not gProfileFilter.enemies[v_int].all then
                                    for n, m in ipairs(filter_info.filter_order) do
                                        local m_int = m:lower()
                                        imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                        imgui.SameLine()
                                        enemies_checkboxes['internal'][enemies_index] = imgui.Checkbox(('##enemies_%s_%s'):fmt(v_int, m_int), {gProfileFilter.enemies[v_int][m_int]})
                                        if enemies_checkboxes['internal'][enemies_index] then
                                            gProfileFilter.enemies[v_int][m_int] = not gProfileFilter.enemies[v_int][m_int]
                                        end
                                        imgui.SameLine()
                                        imgui.TextColored(theme.header_text_col, tostring(m))
                                        enemies_index = n + 6
                                    end
                                end
                            end
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Monsters') then
                            imgui.TextColored(theme.header_text_col, 'Monsters:')
                            imgui.TextColored(theme.desc_text_col, ' NPC not claimed to your party is doing something with one of the below targets:')

                            local monsters_checkboxes = T{all = {}, internal = {}}
                            local monsters_index = 1
                            for i, v in ipairs(filter_info.filter_categories) do
                                local v_int = v:lower():gsub(' ', '_')
                                monsters_checkboxes['all'][i] = imgui.Checkbox(('##monsters_%s'):fmt(v_int), { gProfileFilter.monsters[v_int].all })

                                if monsters_checkboxes['all'][i] then
                                    gProfileFilter.monsters[v_int].all = not gProfileFilter.monsters[v_int].all
                                end
                                imgui.SameLine()
                                imgui.PushTextWrapPos(0)
                                imgui.TextColored(theme.header_text_col, filter_info.filter_header.monsters[i])
                                imgui.PushTextWrapPos(0)
                                imgui.TextColored(theme.desc_text_col, filter_info.filter_descriptions.monsters[i])
                                if not gProfileFilter.monsters[v_int].all then
                                    for n, m in ipairs(filter_info.filter_order) do
                                        local m_int = m:lower()
                                        imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                                        imgui.SameLine()
                                        monsters_checkboxes['internal'][monsters_index] = imgui.Checkbox(('##monsters_%s_%s'):fmt(v_int, m_int), {gProfileFilter.monsters[v_int][m_int]})
                                        if monsters_checkboxes['internal'][monsters_index] then
                                            gProfileFilter.monsters[v_int][m_int] = not gProfileFilter.monsters[v_int][m_int]
                                        end
                                        imgui.SameLine()
                                        imgui.TextColored(theme.header_text_col, tostring(m))
                                        monsters_index = n + 6
                                    end
                                end
                            end
                            imgui.EndTabItem()
                        end
                        imgui.EndTabBar()
                    end
                elseif ui.state.tab == 2 then
                    imgui.TextColored(theme.desc_text_col, 'Colors:')
                    imgui.PushTextWrapPos(0)
                    imgui.TextColored(theme.desc_text_col, 'Colors are customizable based on party / alliance position. Use the colortest button to view the available colors.')
                    imgui.PushTextWrapPos(0)
                    imgui.TextColored(theme.desc_text_col, 'If you wish for a color to be unchanged from its normal color, set it to 0.')
                    imgui.PushStyleColor(ImGuiCol_Button, theme.button_test_colors)
                    imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
                    imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
                    if imgui.Button('\xef\x94\xbf Color Test') then
                        local counter = 0
                        local line = ''
                        for n = 1, 262 do
                            if not color_redundant:contains(n) and not black_colors:contains(n) then
                                if n <= 255 then
                                    loc_col = string.char(0x1F, n)
                                else
                                    loc_col = string.char(0x1E, n - 254)
                                end
                                line = line..loc_col..string.format('%03d ', n)
                                counter = counter + 1
                            end
                            if counter == 16 or n == 262 then
                                AshitaCore:GetChatManager():AddChatMessage(6, false, line)
                                counter = 0
                                line = ''
                            end

                        end
                        AshitaCore:GetChatManager():AddChatMessage(122, false, 'Colors Tested!')
                    end
                    imgui.PopStyleColor(3)
                    if imgui.IsItemHovered() then
                        imgui.SetTooltip('Show available colors on chat')
                    end

                    ui.updatecolors()
                    local colors_inputbox = {}
                    for i, v in ipairs(color_info.color_order) do
                        imgui.PushItemWidth(30)
                        colors_inputbox[i] = imgui.InputInt(('##%s'):fmt(v), color_info.color_inputs[v], 0)
                        if colors_inputbox[i] then
                            gProfileColor[v] = tonumber(color_info.color_inputs[v][1])
                        end
                        imgui.PopItemWidth()
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, color_info.color_name[i])
                    end
                end
            imgui.EndChild()
            if imgui.Button('\xef\x95\xaf Save Changes', {imgui.GetWindowWidth()-16, 20}) then
                if not static_config then
                    ui.save_changes()
                else
                    gFuncs.Error('Saving is Disabled.')
                end
            end
            imgui.TextDisabled(('\xef\x83\x81 %s'):fmt(addon.link))
            imgui.TextDisabled(('\xef\x87\xb9 2022 by %s'):fmt(addon.author))
        imgui.EndGroup()
    end
    imgui.End()
end

ui.updatecolors = function ()
    for i, v in pairs(gProfileColor) do
        if type(v) == 'table' then
            color_info.color_inputs[i] = v
        else
            color_info.color_inputs[i] = T{ v }
        end
    end
end

ui.save_changes = function ()
    local defaultSettingsFile = gStatus.SettingsFolder .. 'config.lua';
	local defaultFiltersFile = gStatus.SettingsFolder .. 'default_filters.lua';
	local defaultColorsFile = gStatus.SettingsFolder .. 'chat_colors.lua';
	local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));

    gFileTools.SaveChanges(defaultSettingsFile, gProfileSettings, 'settings')
    if gStatus.CurrentFilters == ('%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob)) then
        gFileTools.SaveChanges(jobFiltersFile, gProfileFilter, 'filters')
    else
        gFileTools.SaveChanges(defaultFiltersFile, gProfileFilter, 'filters')
    end
    
    gFileTools.SaveChanges(defaultColorsFile, gProfileColor, 'colors')
    print(chat.header('SimpleLog')..chat.success('All changes Saved'))
end

return ui