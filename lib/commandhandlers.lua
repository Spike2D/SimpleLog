local commands = {}

commands.HandleCommand = function(e)
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/simplelog', '/slog')) then
        return;
    end

    e.blocked = true

    if (#args == 1 and args[1]:any('/simplelog', '/slog')) then
        print(chat.header('SimpleLog')..chat.message('Opening menu...'))
        gConfig.toggle_menu(1)
    end
    if (#args == 2 and args[2]:any('build_msg')) then
        if debug then
            local success_en, loadError_en = loadfile(('%saddons\\simplelog\\lib\\res\\action_messages_en.lua'):fmt(AshitaCore:GetInstallPath()));
            local success_jp, loadError_jp = loadfile(('%saddons\\simplelog\\lib\\res\\action_messages_jp.lua'):fmt(AshitaCore:GetInstallPath()));

            if not success_en then
                print(chat.header('SimpleLog') .. chat.error(loadError_en));
                return
            end
            local en_msg_file = success_en()

            if not success_jp then
                print(chat.header('SimpleLog') .. chat.error(loadError_jp));
                return
            end
            local jp_msg_file = success_jp()

            local file = io.open(('%saddons\\simplelog\\lib\\res\\action_messages.lua'):fmt(AshitaCore:GetInstallPath()), "w+")

            file:write('\n')
            file:write('\n')
            file:write('return {\n')
            for i, v in ipairs(en_msg_file) do
                if en_msg_file[i]['id'] ~= nil then
                    file:write('	['..tostring(i)..'] = {id='..tostring(i)..',jp="'..tostring(jp_msg_file[i])..'",en="'..tostring(en_msg_file[i]['en'])..'",')

                    if type(en_msg_file[i]['color']) == "string"then
                        file:write('color="'..tostring(en_msg_file[i]['color'])..'"')
                    elseif type(en_msg_file[i]['color']) == "number"then
                        file:write('color='..tostring(en_msg_file[i]['color']))
                    end

                    if en_msg_file[i]['suffix'] ~= nil then
                        file:write(',suffix="'..tostring(en_msg_file[i]['suffix'])..'"')
                    end
                    if en_msg_file[i]['prefix'] ~= nil then
                        file:write(',prefix="'..tostring(en_msg_file[i]['prefix'])..'"')
                    end
                    file:write('},\n')
                end
            end
            file:write('}, {"id", "jp", "en", "color", "suffix", "prefix"}\n')
            file:write('\n')
            file:write('')
            file:close()
        else
            print(chat.header('SimpleLog') .. chat.error('Disabled.'))
        end
    end
end

return commands;