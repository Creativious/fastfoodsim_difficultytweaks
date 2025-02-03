ChatHook = require("libs/chathook")
TableUtils = require("libs/tableutils")

CommandManager = {
    ---@type Command[]
    commands = {}
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
---@field callback function
CommandPreset = {
    name = "",
    desciption = "",
    args = {},
    callback = nil
}

--- Create a new command arg object
---@param name string
---@param arg_type string
---@param default any
---@return CommandArg
function CommandManager.__create_command_arg_obj(name, arg_type, default)
    local obj = TableUtils.copy(CommandArgPreset)
    obj.name = name
    obj.type = arg_type
    obj.default = default
    return obj
end

--- Add an argument to a table, while specifying the type
---@param table table
---@param name string
---@param arg_type string
---@param default any
function CommandManager.add_arg_to_table_with_defined_type(table, name, arg_type, default)
    local obj = CommandManager.__create_command_arg_obj(name, arg_type, default)
    table.insert(table, obj)
end

--- Add an argument to a table
---@param table table
---@param name string
---@param default any
function CommandManager.add_arg_to_table(table, name, default)
    local arg_type = type(default)
    CommandManager.add_arg_to_table_with_defined_type(table, name, arg_type, default)
end

--- Create a new command object
---@param name string
---@param desciption string
---@param args CommandArg[]
---@param callback function
---@return Command
function CommandManager.__create_command_obj(name, desciption, args, callback)
    local obj = TableUtils.copy(CommandPreset)
    obj.name = name
    obj.desciption = desciption
    obj.args = args
    obj.callback = callback
    return obj
end

--- Register a command (Internally)
---@param command string
---@param args CommandArg[]
---@param callback function
---@return string | nil val the return value, if it is a nil that means it already exists
function CommandManager.__internal_register_command(command, desciption, args, callback)
    if TableUtils.does_table_contain_key(CommandManager.commands, command) then
        error("The command " .. tostring(command) .. " has already been registered")
        return nil
    end
    local obj = CommandManager.__create_command_obj(command, desciption, args, callback)
    table.insert(CommandManager.commands, obj)
    return command
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

---comment
---@param command string
---@return Command val
function CommandManager.get_command(command)
    local val = CommandManager.commands[command]
    return val
end

return CommandManager