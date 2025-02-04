ChatHook = require("libs/chathook")
TableUtils = require("libs/tableutils")
Config = require("libs/config")
StringUtils = require("libs/stringutils")

CommandManager = {
    ---@type Command[]
    commands = {},
    __HAS_REGISTERED_HOOK = false
}

---@class CommandArg
---@field name string
---@field arg_type string
---@field default any
CommandArgPreset = {
    name = "",
    arg_type = "string",
    default = nil
}

---@class Command
---@field name string
---@field desciption string
---@field args CommandArg[]
---@field optional_config_entry string
---@field callback function
CommandPreset = {
    name = "",
    desciption = "",
    args = {},
    optional_config_entry = "",
    callback = nil
}

---@class CommandArgFeedback
---@field name string
---@field arg_type string
---@field value any
CommandArgFeedbackPreset = {
    name = "",
    arg_type = "string",
    value = nil
}

---@class CommandFeedback
---@field command_name string
---@field optional_config_entry string
---@field args CommandArgFeedback[]
CommandFeedbackPreset = {
    command_name = "",
    optional_config_entry = "",
    args = {},
}

--- Create a new command arg object
---@param name string
---@param arg_type string
---@param default any
---@return CommandArg
function CommandManager.__create_command_arg_obj(name, arg_type, default)
    local obj = TableUtils.copy(CommandArgPreset)
    obj.name = name
    obj.arg_type = arg_type
    obj.default = default
    return obj
end

--- Add an argument to a table, while specifying the type
---@param tbl table
---@param name string
---@param arg_type string
---@param default any
function CommandManager.add_arg_to_table_with_defined_type(tbl, name, arg_type, default)
    local obj = CommandManager.__create_command_arg_obj(name, arg_type, default)
    table.insert(tbl, obj)
end

--- Add an argument to a table
---@param tbl table
---@param name string
---@param default any
function CommandManager.add_arg_to_table(tbl, name, default)
    local arg_type = type(default)
    CommandManager.add_arg_to_table_with_defined_type(tbl, name, arg_type, default)
end

--- Create a new command object
---@param name string
---@param desciption string
---@param args CommandArg[]
---@param optional_config_entry string
---@param callback function
---@return Command
function CommandManager.__create_command_obj(name, desciption, args, optional_config_entry, callback)
    local obj = TableUtils.copy(CommandPreset)
    obj.name = name
    obj.desciption = desciption
    obj.args = args
    obj.optional_config_entry = optional_config_entry
    obj.callback = callback
    return obj
end

function CommandManager.__get_command_string_from_larger_string(larger_string)
    return string.match(larger_string, "^[^%s]+")
end

--- Register a command (Internally)
---@param command string
---@param desciption string
---@param args CommandArg[]
---@param optional_config_entry string
---@param callback function
---@return string | nil val the return value, if it is a nil that means it already exists
function CommandManager.__internal_register_command(command, desciption, args, optional_config_entry, callback)
    if CommandManager.__HAS_REGISTERED_HOOK == false then
        CommandManager.__HAS_REGISTERED_HOOK = true
        ChatHook.register_callback_on_chat_message(CommandManager.__command_callback)
        local bargs = {}
        CommandManager.add_arg_to_table(bargs, "command", "help")
        CommandManager.register_command("help", "Displays information about a command.", bargs, CommandManager.help_command_callback)
    end
    if TableUtils.does_table_contain_key(CommandManager.commands, command) then
        error("The command " .. tostring(command) .. " has already been registered")
        return nil
    end
    local obj = CommandManager.__create_command_obj(command, desciption, args, optional_config_entry, callback)
    CommandManager.commands[command] = obj
    return command
end

--- Register a command
--- @param command string
--- @param desciption string
--- @param args CommandArg[]
--- @param callback function
function CommandManager.register_command(command, desciption, args, callback)
    return CommandManager.__internal_register_command(command, desciption, args, "", callback)
end

--- Gets the number of arguments for a command
---@param command_obj Command
---@return integer arg_count
function CommandManager.__get_arg_count(command_obj)
    return TableUtils.count_keys(command_obj.args)
end

--- Gets the usage string for the argument, such as <true|false> or <number> or <string>
---@param command_arg CommandArg
---@return string return_val
function CommandManager.get_usage_text_for_argument(command_arg)
    if command_arg.arg_type == "string" then
        return "<string>"
    elseif command_arg.arg_type == "boolean" then
        return "<true|false>"
    elseif command_arg.arg_type == "number" then
        return "<number>"
    end

    return "<unknown|any>"

end

--- Get's the string the tells the end user how to use the command
---@param command_obj Command
function CommandManager.get_usage_string_from_command(command_obj)
    local usage_string = "Usage: /" .. command_obj.name
    local arg_count = CommandManager.__get_arg_count(command_obj)
    if (arg_count == 0) then
        return usage_string
    end
    local i = 0
    while i < arg_count do
        usage_string = usage_string .. " "
        local arg = command_obj.args[i+1]
        local arg_string = CommandManager.get_usage_text_for_argument(arg)
        usage_string = usage_string .. arg_string
        i = (i or 0) + 1
    end

    return usage_string


end

--- Gets a command from the command string
---@param command string
---@return Command val
function CommandManager.get_command(command)
    local val = CommandManager.commands[command]
    return val
end

--- The command feedback for commands
---@param command_feedback CommandFeedback
function CommandManager.__config_command_callback(command_feedback)
    local config_entry = command_feedback.optional_config_entry
    local command_human_name = StringUtils.replace_char(command_feedback.command_name, "_", " ")
    if (config_entry == "") then
        error("No config entry for command " .. command_feedback.command_name)
        return
    end
    -- Since it's a config entry, there is only one argument
    local arg = command_feedback.args[1]
    if (arg.value == nil) then
        -- Then this is the show part of the command
        command_human_name = StringUtils.capitalize(command_human_name)
        ChatHook.send_info_to_chat(command_human_name .. " is currently set to " .. tostring(Config.get(config_entry)))
        return
    end
    Config.set(config_entry, arg.value)
    ChatHook.send_info_to_chat("Set " .. command_human_name .. " to " .. tostring(arg.value))
    ChatHook.send_info_to_chat("Reload save to apply changes.")
end

--- Register a command that automatically 
---@param command string The command name, such as "max_customers", the usage for commands like this will be /max_customers <number> and if you do /max_customers you'll get the result from it
---@param config_entry string The config entry to get the value from
function CommandManager.register_command_for_config(command, config_entry, description)
    local val = Config.get_default(config_entry)
    local args = {}
    CommandManager.add_arg_to_table(args, "value", val)
    CommandManager.__internal_register_command(command, description, args, config_entry, CommandManager.__config_command_callback)
end

--- Checks if a command exists
---@param command string
---@return boolean
function CommandManager.does_command_exist(command)
    return TableUtils.does_table_contain_key(CommandManager.commands, command)
end

function CommandManager.print_command_info_to_chat(command)
    local command_obj = CommandManager.get_command(command)
    local usage_string = CommandManager.get_usage_string_from_command(command_obj)
    ChatHook.send_info_to_chat(usage_string)
    ChatHook.send_info_to_chat(command_obj.desciption)
end

--- The callback for the help command
---@param command_feedback CommandFeedback
function CommandManager.help_command_callback(command_feedback)
    ---@type string
    local command_name = nil
    if (TableUtils.count_keys(command_feedback.args) >= 1) then
        command_name = command_feedback.args[1].value
    end
    if (command_name == nil) then
        CommandManager.print_command_info_to_chat("help")
    elseif command_name == "" then
        CommandManager.print_command_info_to_chat(command_name)
    else
        local does_exist = CommandManager.does_command_exist(command_name)
        if does_exist then
            CommandManager.print_command_info_to_chat(command_name)
        else
            ChatHook.send_warning_to_chat("Unknown command: " .. command_name)
        end
    end
end

--- The command feedback for commands
---@param msg string
function CommandManager.__command_callback(msg)
    if (msg:sub(1, 1) == "/") then
        local command_string = CommandManager.__get_command_string_from_larger_string(msg:sub(2))
        if CommandManager.does_command_exist(command_string) == false then
            ChatHook.send_warning_to_chat("Unknown command: " .. command_string)
            return
        end
        local command_obj = CommandManager.get_command(command_string)
        local callback = command_obj.callback
        ---@type CommandFeedback
        local command_feedback = TableUtils.copy(CommandFeedbackPreset)
        command_feedback.command_name = command_string
        command_feedback.optional_config_entry = command_obj.optional_config_entry
        local readable_command = string.sub(msg, #command_string + 2)
        for _, arg in pairs(command_obj.args) do
            ---@type CommandArgFeedback
            local arg_feedback = TableUtils.copy(CommandArgFeedbackPreset)
            arg_feedback.name = arg.name
            arg_feedback.arg_type = arg.arg_type
            if (readable_command == "") then
                arg_feedback.value = nil
                goto continue
            end
            if (StringUtils.replace_char(readable_command, " ", "") == "") then
                arg_feedback.value = nil
            elseif (arg.arg_type == "number") then
                local val = StringUtils.find_first_number(readable_command)
                readable_command = string.sub(readable_command, #val + 2)
                local other_val = tonumber(val)
                if (other_val == nil) then
                    ChatHook.send_warning_to_chat("Invalid number: " .. tostring(val) .. " for command ".. command_string)
                    ChatHook.send_warning_to_chat(CommandManager.get_usage_text_for_command(command_obj))
                    return
                end
                arg_feedback.value = other_val
            else
                -- Everything else starts as a string
                local first_word = StringUtils.find_first_word(readable_command)
                readable_command = string.sub(readable_command, #first_word + 2)
                if (arg.arg_type == "boolean") then
                    if (first_word == "true") then
                        arg_feedback.value = true
                    elseif (first_word == "false") then
                        arg_feedback.value = false
                    else
                        ChatHook.send_warning_to_chat("Invalid boolean: " .. first_word .. " for command ".. command_string)
                        ChatHook.send_warning_to_chat(CommandManager.get_usage_text_for_command(command_obj))
                        return
                    end
                else
                    arg_feedback.value = first_word
                end
            end
            ::continue::
            table.insert(command_feedback.args, arg_feedback)
            
        end
        callback(command_feedback)
    end
end



return CommandManager