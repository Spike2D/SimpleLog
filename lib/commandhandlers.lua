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
end

return commands;