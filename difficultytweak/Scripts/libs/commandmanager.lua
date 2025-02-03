ChatHook = require("libs/chathook")
TableUtils = require("libs/tableutils")

CommandManager = {
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
function CommandManager.__internal_register_command(command, desciption, args, callback)
    local obj = CommandManager.__create_command_obj(command, desciption, args, callback)
    table.insert(CommandManager.commands, obj)
end


return CommandManager