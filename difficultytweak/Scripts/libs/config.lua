TableUtils = require("libs/tableutils")
Json = require("libs/json")
FileUtils = require("libs/fileutils")

Config = {
    __CONFIG = {
    },
    __DEFAULTS = {

    },
    __LOCATION = nil
}

--- Sets a default value (This also will register the config entry)
---@param key string
---@param value string | boolean | number
function Config.set_default(key, value)
    Config.__CONFIG[key] = value
    Config.__DEFAULTS[key] = value
end

--- Gets a config value
---@param key string
---@return string | boolean | number | nil
function Config.get(key)
    if Config.__CONFIG[key] == nil then
        Config.__CONFIG[key] = Config.__DEFAULTS[key]
    end
    return Config.__CONFIG[key]
end

--- Gets a default value
---@param key string
---@return string | boolean | number | nil
function Config.get_default(key)
    if Config.__DEFAULTS[key] == nil then
        return nil
    end
    return Config.__DEFAULTS[key]
end

--- Sets the config location
--- @param location string
function Config.set_location(location)
    Config.__LOCATION = location
end

function Config.write()
    if (Config.__LOCATION == nil) then
        error("Config location has not been set, make sure to set the location using Config.set_location(location)")
        return
    end
    local filtered_config = TableUtils.copy_without_functions(Config.__CONFIG)
    FileUtils.write_file(Config.__LOCATION, Json.encode(filtered_config))
end

function Config.read()
    if (Config.__LOCATION == nil) then
        error("Config location has not been set, make sure to set the location using Config.set_location(location)")
        return
    end
    local content = FileUtils.read_file(Config.__LOCATION)
    if (content == nil) then
        Config.reset()
        return
    end
    local conf = Json.decode(content)
    local mismatched_keys = TableUtils.find_mismatched_keys(Config.__DEFAULTS, conf)
    Config.__CONFIG = conf
    if (#mismatched_keys > 0) then
        for _, key in pairs(mismatched_keys) do
            Config.__CONFIG[key] = Config.__DEFAULTS[key]
        end
        Config.write()
    end
end

--- Sets a config value
---@param key string
---@param value string | boolean | number
function Config.set(key, value)
    Config.__CONFIG[key] = value
    Config.write()
end

--- Resets a config value
---@param key string
function Config.reset_value(key)
    Config.__CONFIG[key] = Config.__DEFAULTS[key]
    Config.write()
end

--- Resets all config values
function Config.reset()
    Config.__CONFIG = TableUtils.copy_without_functions(Config.__DEFAULTS)
    Config.write()
end

return Config