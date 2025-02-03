print("Loading Difficulty Tweak - By Creativious")

-- Credits For JSON https://github.com/rxi/json.lua/blob/master/json.lua

Json = require "libs/json"

ChatHook = require "libs/chathook"

TABLES = 17

CUSTOMERS_FULL = false

CONFIG = {
    MIN_POSSIBLE_CUSTOMERS = 25,
    MAX_POSSIBLE_CUSTOMERS=  500,
    MIN_EATING_DURATION = 15.0,
    BASE_PATIENCE_MULTIPLIER = 1.0,
    MAX_EATING_DURATION = 30.0,
    ENABLE_EATING_DURATION_TWEAKS = true,
    ENABLE_PATIENCE_TWEAKS = true
}

--- Calculates the base patience multiplier based on the maximum amount of customers that can be in the bakery at any given time
---@return number BasePatienceMultiplier base patience multiplier
function calcBasePatienceMultiplier()
    return (CONFIG.getBasePatienceMultiplier() + (CONFIG.getMaxCustomers() / 50) / 10)
end

BASE_PATIENCE_MULTIPLIER = 1.0


---#region Config Getters

--- Returns the maximum number of customers
---@return integer maxCustomers maximum number of customers
function CONFIG.getMaxCustomers()
    return CONFIG["MAX_POSSIBLE_CUSTOMERS"]
end

--- Returns the minimum number of customers
---@return integer minCustomers minimum number of customers
function CONFIG.getMinCustomers()
    return CONFIG["MIN_POSSIBLE_CUSTOMERS"]
end

--- Returns the maximum eating duration
---@return number maxEatingDuration maximum eating duration
function CONFIG.getMaxEatingDuration()
    return CONFIG["MAX_EATING_DURATION"]
end

--- Returns the minimum eating duration
---@return number minEatingDuration minimum eating duration
function CONFIG.getMinEatingDuration()
    return CONFIG["MIN_EATING_DURATION"]
end

--- Returns the base patience multiplier
---@return number basePatienceMultiplier base patience multiplier
function CONFIG.getBasePatienceMultiplier()
    return CONFIG["BASE_PATIENCE_MULTIPLIER"]
end

--- Returns whether eating duration tweaks are enabled
---@return boolean isEatingDurationTweaksEnabled whether eating duration tweaks are enabled
function CONFIG.getEnableEatingDurationTweaks()
    return CONFIG["ENABLE_EATING_DURATION_TWEAKS"]
end

--- Returns whether patience tweaks are enabled
---@return boolean isPatienceTweaksEnabled whether patience tweaks are enabled
function CONFIG.getEnablePatienceTweaks()
    return CONFIG["ENABLE_PATIENCE_TWEAKS"]
end

--- Returns a copy of the CONFIG table with functions filtered out
---@return table conf configuration table without functions
function CONFIG.getConfig()
    local conf = {}
    for key, value in pairs(CONFIG) do
        conf[key] = value
    end
    conf = filterFunctionsFromTable(conf)
    return conf
end

---#endregion

---#region Config Setters

--- Sets the minimum number of customers
---@param value integer minimum number of customers
function CONFIG.setMinCustomers(value)
    CONFIG["MIN_POSSIBLE_CUSTOMERS"] = value
    CONFIG.write()
end

--- Sets the maximum number of customers
---@param value integer maximum number of customers
function CONFIG.setMaxCustomers(value)
    CONFIG["MAX_POSSIBLE_CUSTOMERS"] = value
    BASE_PATIENCE_MULTIPLIER = CONFIG.getBasePatienceMultiplier() + ((value / 50) / 10)
    CONFIG.write()
end

--- Sets the base patience multiplier
---@param value number base patience multiplier
function CONFIG.setBasePatienceMultiplier(value)
    CONFIG["BASE_PATIENCE_MULTIPLIER"] = value
    BASE_PATIENCE_MULTIPLIER = calcBasePatienceMultiplier()
    CONFIG.write()
end

--- Sets the minimum eating duration
---@param value number minimum eating duration
function CONFIG.setMinEatingDuration(value)
    CONFIG["MIN_EATING_DURATION"] = value
    CONFIG.write()
end

--- Sets the maximum eating duration
---@param value number maximum eating duration
function CONFIG.setMaxEatingDuration(value)
    CONFIG["MAX_EATING_DURATION"] = value
    CONFIG.write()
end

--- Sets whether eating duration tweaks are enabled
---@param value boolean whether eating duration tweaks are enabled
function CONFIG.setEnableEatingDurationTweaks(value)
    CONFIG["ENABLE_EATING_DURATION_TWEAKS"] = value
    CONFIG.write()
end

--- Sets whether patience tweaks are enabled
---@param value boolean whether patience tweaks are enabled
function CONFIG.setEnablePatienceTweaks(value)
    CONFIG["ENABLE_PATIENCE_TWEAKS"] = value
    CONFIG.write()
end


--- Sets the entire config table
---@param value table the new config table
function CONFIG.setConfig(value)
    value = filterFunctionsFromTable(value)
    for key, value in pairs(value) do
        CONFIG[key] = value
    end
    CONFIG.write()
end

---#endregion


---#region Config Reset

--- Resets the maximum number of customers to its default value
function CONFIG.resetMaxCustomers()
    CONFIG["MAX_POSSIBLE_CUSTOMERS"] = 500
end

--- Resets the minimum number of customers to its default value
function CONFIG.resetMinCustomers()
    CONFIG["MIN_POSSIBLE_CUSTOMERS"] = 25
end

--- Resets the minimum eating duration to its default value
function CONFIG.resetMinEatingDuration()
    CONFIG["MIN_EATING_DURATION"] = 15.0
end

--- Resets the maximum eating duration to its default value
function CONFIG.resetMaxEatingDuration()
    CONFIG["MAX_EATING_DURATION"] = 30.0
end

--- Resets the base patience multiplier to its default value
function CONFIG.resetBasePatienceMultiplier()
    CONFIG["BASE_PATIENCE_MULTIPLIER"] = 1.0
end

--- Resets the enabling of eating duration tweaks to its default value
function CONFIG.resetEnableEatingDurationTweaks()
    CONFIG["ENABLE_EATING_DURATION_TWEAKS"] = true
end

--- Resets the enabling of patience tweaks to its default value
function CONFIG.resetEnablePatienceTweaks()
    CONFIG["ENABLE_PATIENCE_TWEAKS"] = true
end

--- Resets all configuration settings to their default values
function CONFIG.reset()
    CONFIG.resetMaxCustomers()
    CONFIG.resetMinCustomers()
    CONFIG.resetMinEatingDuration()
    CONFIG.resetMaxEatingDuration()
    CONFIG.resetBasePatienceMultiplier()
    CONFIG.resetEnableEatingDurationTweaks()
    CONFIG.resetEnablePatienceTweaks()
    CONFIG.write()
end

---#endregion

--- Writes the config to the config file
function CONFIG.write()
    write_to_config(CONFIG.getConfig())
end

--- Reads the config from the config file and sets it
function CONFIG.read()
    CONFIG.setConfig(read_config())
    CONFIG.write()
end

BASE_PATIENCE_MULTIPLIER = calcBasePatienceMultiplier()

PATIENCE_MULTIPLIER = BASE_PATIENCE_MULTIPLIER

HAS_GOTTEN_DEFAULT_PATIENCE = false

FIRST_CALC_DAY_LENGTH = false

CUSTOMERS_FOR_DAY = CONFIG.getMinCustomers()

DEFAULT_PATIENCE = 0

CALCULATED_DELAY_ON_CUSTOMER_SPAWN = 1

WAITING_CUSTOMERS = 0

DAY_LENGTH = 480

FIRST_TIME_GETTING_HELP_MESSSAGE = false

EATING_DURATION_BASE_MULTIPLIER = 1.0

EATING_DURATION_MULTIPLIER = EATING_DURATION_BASE_MULTIPLIER

CUSTOMERS_WITH_ORDER_NUMBER = 0

--- Returns the maximum number of customers
---@return integer
function getMaxCustomers()
    local bakery_ingame = FindFirstOf("BP_BakeryGameState_Ingame_C")
    local level = bakery_ingame:GetRestaurantLevel()
    local total_days = bakery_ingame:GetTotalDays()

    local customer_count = CONFIG.getMinCustomers() + CONFIG.getMaxCustomers() * (0 + ((level - 1) / 600) + (total_days / 400))
    customer_count = round(customer_count)
    if customer_count > CONFIG.getMaxCustomers() then
        customer_count = CONFIG.getMaxCustomers()
    end
    if customer_count < CONFIG.getMinCustomers() then
        customer_count = CONFIG.getMinCustomers()
    end
    return customer_count
end

CONFIG_LOCATION = "Mods/difficultytweak/config.json"

--- Writes the config file
---@param table table
function write_to_config(table)
    table = filterFunctionsFromTable(table)
    if type(table) ~= "table" then
        error("Expected a table, got " .. type(table))
    end
    local f = io.open(CONFIG_LOCATION, "w")
    f:write(Json.encode(table))
    f:close()
end

--- Filters out functions from a table
---@param table table
---@return table
function filterFunctionsFromTable(table)
    local result = {}
    for key, value in pairs(table) do
        if type(value) ~= "function" then
            result[key] = value
        end
    end
    return result
end

--- Reads the config file
---@return table
function read_config()
    local f = io.open(CONFIG_LOCATION, "r")
    local result_t = f:read()
    f:close()
    if (result_t == nil) then
        CONFIG.write()
        return CONFIG.getConfig()
    end
    local result = Json.decode(result_t)
    return result
end

--- This file contains the main functionality of the Difficulty Tweaks mod.
--- It makes customers spawn based on level and total days played.
---@param name string
---@return boolean
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

if file_exists(CONFIG_LOCATION) then
    CONFIG.read()
else
    CONFIG.write()
end

--- Rounds a number
---@param x number
---@return integer
function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
  




local function processCustomers()
    local findAllCustomers = FindAllOf("BP_Customer_C")
    if findAllCustomers ~= nil then
        for _, customer in pairs(findAllCustomers) do
            if customer then
                if not HAS_GOTTEN_DEFAULT_PATIENCE then
                    DEFAULT_PATIENCE = customer:GetPropertyValue("PatienceSpeed")
                    HAS_GOTTEN_DEFAULT_PATIENCE = true
                end
                -- local order = customer:GetPropertyValue("Order")
                -- local customer_table = customer:GetPropertyValue("CustomerTable")
                -- local customer_state = customer:GetPropertyValue("CustomerState")
                local customer_queue_number = customer:GetPropertyValue("CustomerQueueNumber")
                local customer_order_number = customer:GetPropertyValue("OrderNumberOfPerson")
                local patience_speed = customer:GetPropertyValue("PatienceSpeed")
                if CONFIG.getEnablePatienceTweaks() then
                    if patience_speed ~= round(DEFAULT_PATIENCE * PATIENCE_MULTIPLIER) then
                        customer:SetPatienceSpeed(round(DEFAULT_PATIENCE * PATIENCE_MULTIPLIER))
                    end
                end
                if customer_queue_number ~= -1 then
                    WAITING_CUSTOMERS = WAITING_CUSTOMERS + 1
                end
                if customer_order_number ~= 0 then
                    CUSTOMERS_WITH_ORDER_NUMBER = CUSTOMERS_WITH_ORDER_NUMBER + 1
                end
            end
        end
    end
    if CUSTOMERS_WITH_ORDER_NUMBER == TABLES then
        CUSTOMERS_FULL = true
    else
        CUSTOMERS_FULL = false
    end
    possible_patience_bonus = 0
    possible_eating_duration_reduction = 0
    if CUSTOMERS_FULL then
        possible_patience_bonus = 0.25
        possible_eating_duration_reduction = 0.35
    end
    PATIENCE_MULTIPLIER = BASE_PATIENCE_MULTIPLIER + (CUSTOMERS_WITH_ORDER_NUMBER / 100) + possible_patience_bonus + (WAITING_CUSTOMERS / 200)
    EATING_DURATION_BASE_MULTIPLIER = EATING_DURATION_BASE_MULTIPLIER - possible_eating_duration_reduction - (WAITING_CUSTOMERS / 400) - (CUSTOMERS_WITH_ORDER_NUMBER / 100)
    
end

--- Returns the length of a table
---@param T table
---@return integer
function getLuaTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count +1 end
    return count
end


--- Sets the minimum customers that can be in the bakery at any given time
---@param minCustomers number Minimum customers that can be in the bakery at any given time
function setMinCustomersCommand(minCustomers)
    if minCustomers == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_min_customers <number>")
        return
    end
    if type(minCustomers) ~= "number" then
        ChatHook.send_warning_to_chat("Minimum customers must be a number.")
        ChatHook.send_warning_to_chat("Usage: /set_min_customers <number>")
        return
    end
    if minCustomers < 1 then
        ChatHook.send_warning_to_chat("Minimum customers must be above 0.")
        ChatHook.send_warning_to_chat("Usage: /set_min_customers <number>")
        return
    end
    ChatHook.send_info_to_chat("Minimum Customers set to " .. tostring(minCustomers))
    CONFIG.setMinCustomers(minCustomers)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Sets the maximum customers that can be in the bakery at any given time
---@param maxCustomers number Maximum customers that can be in the bakery at any given time
function setMaxCustomersCommand(maxCustomers)
    if maxCustomers == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_max_customers <number>")
        return
    end
    if type(maxCustomers) ~= "number" then
        ChatHook.send_warning_to_chat("Maximum customers must be a number.")
        ChatHook.send_warning_to_chat("Usage: /set_max_customers <number>")
        return
    end
    if maxCustomers < 1 then
        ChatHook.send_warning_to_chat("Maximum customers must be above 0.")
        ChatHook.send_warning_to_chat("Usage: /set_max_customers <number>")
        return
    end
    ChatHook.send_info_to_chat("Maximum Customers set to " .. tostring(maxCustomers))
    CONFIG.setMaxCustomers(maxCustomers)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Shows the current minimum customers that can be in the bakery at any given time
function showMinCustomersCommand()
    ChatHook.send_info_to_chat("Minimum Customers: " .. tostring(CONFIG.getMinCustomers()))
end

--- Shows the current maximum customers that can be in the bakery at any given time
function showMaxCustomersCommand()
    ChatHook.send_info_to_chat("Maximum Customers: " .. tostring(CONFIG.getMaxCustomers()))
end

--- Resets the config file to its default values
function resetConfigCommand()
    ChatHook.send_info_to_chat("Resetting config file.")
    CONFIG.reset()
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Sets the base patience multiplier for when there are no customers in the bakery
---@param basePatienceMultiplier number Base patience multiplier for when there are no customers in the bakery
function setBasePatienceMultiplierCommand(basePatienceMultiplier)
    if basePatienceMultiplier == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_base_patience_multiplier <number>")
        return
    end
    if type(basePatienceMultiplier) ~= "number" then
        ChatHook.send_warning_to_chat("Base patience multiplier must be a number.")
        ChatHook.send_warning_to_chat("Usage: /set_base_patience_multiplier <number>")
        return
    end
    ChatHook.send_info_to_chat("Base Patience Multiplier set to " .. tostring(basePatienceMultiplier))
    CONFIG.setBasePatienceMultiplier(basePatienceMultiplier)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Shows the current base patience multiplier for when there are no customers in the bakery
function showBasePatienceMultiplierCommand()
    ChatHook.send_info_to_chat("Base Patience Multiplier: " .. tostring(CONFIG.getBasePatienceMultiplier()))
end

--- Sets the minimum eating duration for customers
---@param minEatingDuration number Minimum eating duration for customers
function setMinEatingDurationCommand(minEatingDuration)
    if minEatingDuration == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_min_eating_duration <number>")
        return
    end
    if type(minEatingDuration) ~= "number" then
        ChatHook.send_warning_to_chat("Minimum eating duration must be a number.")
        ChatHook.send_warning_to_chat("Usage: /set_min_eating_duration <number>")
        return
    end
    ChatHook.send_info_to_chat("Minimum Eating Duration set to " .. tostring(minEatingDuration))
    CONFIG.setMinEatingDuration(minEatingDuration)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Shows the current minimum eating duration for customers
function showMinEatingDurationCommand()
    ChatHook.send_info_to_chat("Minimum Eating Duration: " .. CONFIG.getMinEatingDuration())
end

--- Sets the maximum eating duration for customers
---@param maxEatingDuration number Maximum eating duration for customers
function setMaxEatingDurationCommand(maxEatingDuration)
    if maxEatingDuration == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_max_eating_duration <number>")
        return
    end
    if type(maxEatingDuration) ~= "number" then
        ChatHook.send_warning_to_chat("Maximum eating duration must be a number.")
        ChatHook.send_warning_to_chat("Usage: /set_max_eating_duration <number>")
        return
    end
    ChatHook.send_info_to_chat("Maximum Eating Duration set to " .. tostring(maxEatingDuration))
    CONFIG.setMaxEatingDuration(maxEatingDuration)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Converts a string to a boolean value
--- @param value string The string to convert ("true" or "false")
--- @return boolean|nil value The boolean value if conversion is successful, otherwise nil
function parseToBoolean(value)
    value = string.lower(value)
    
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    end
    return nil
end

--- Sets whether patience tweaks are enabled
---@param patienceTweaks string Whether patience tweaks are enabled
function setPatienceTweaksCommand(patienceTweaks)
    ---@diagnostic disable-next-line
    patienceTweaks = parseToBoolean(patienceTweaks)
    if patienceTweaks == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_patience_tweaks <true/false>")
        return
    end
    if type(patienceTweaks) ~= "boolean" then
        ChatHook.send_warning_to_chat("Patience tweaks must be a boolean.")
        ChatHook.send_warning_to_chat("Usage: /set_patience_tweaks <true/false>")
        return
    end
    ChatHook.send_info_to_chat("Patience Tweaks set to " .. tostring(patienceTweaks))
    CONFIG.setEnablePatienceTweaks(patienceTweaks)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Shows the current state of the patience tweaks
function showPatienceTweaksCommand()
    ChatHook.send_info_to_chat("Patience Tweaks: " .. tostring(CONFIG.getEnablePatienceTweaks()))
end

--- Sets whether eating duration tweaks are enabled
---@param eatingDurationTweaks string Whether eating duration tweaks are enabled
function setEatingDurationTweaksCommand(eatingDurationTweaks)
    ---@diagnostic disable-next-line
    eatingDurationTweaks = parseToBoolean(eatingDurationTweaks)
    if eatingDurationTweaks == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /set_eating_duration_tweaks <true/false>")
        return
    end
    if type(eatingDurationTweaks) ~= "boolean" then
        ChatHook.send_warning_to_chat("Eating duration tweaks must be a boolean.")
        ChatHook.send_warning_to_chat("Usage: /set_eating_duration_tweaks <true/false>")
        return
    end
    ChatHook.send_info_to_chat("Eating Duration Tweaks set to " .. tostring(eatingDurationTweaks))
    CONFIG.setEnableEatingDurationTweaks(eatingDurationTweaks)
    ChatHook.send_info_to_chat("Reload saves to apply changes.")
end

--- Shows the current state of the eating duration tweaks
function showEatingDurationTweaksCommand()
    ChatHook.send_info_to_chat("Eating Duration Tweaks: " .. tostring(CONFIG.getEnableEatingDurationTweaks()))
end

--- Shows the current maximum eating duration for customers
function showMaxEatingDurationCommand()
    ChatHook.send_info_to_chat("Maximum Eating Duration: " .. tostring(CONFIG.getMaxEatingDuration()))
end

--- Displays the startup message with information about the mod and available commands
function displayStartupMessage()
    ChatHook.send_info_to_chat("Difficulty Tweaks - By Creativious")
    ChatHook.send_info_to_chat("Commands (Listed on mod page):")
    ChatHook.send_info_to_chat("/help <command>")
    ChatHook.send_info_to_chat("^ Displays information about a command.")
end

--- Displays information about a command
---@param command string The command to get information about
function helpCommand(command)
    if command == nil then
        ChatHook.send_warning_to_chat("Incorrect usage of the command.")
        ChatHook.send_warning_to_chat("Usage: /help <command>")
        return
    end
    command = command:gsub("[/\\]", "")
    if command == "set_min_customers" then
        ChatHook.send_info_to_chat("Usage: /set_min_customers <number>")
        ChatHook.send_info_to_chat("Default: 25")
        ChatHook.send_info_to_chat("Sets the minimum amount of customers that can be in the bakery at any given time.")
    elseif command == "set_max_customers" then
        ChatHook.send_info_to_chat("Usage: /set_max_customers <number>")
        ChatHook.send_info_to_chat("Default: 500")
        ChatHook.send_info_to_chat("Sets the maximum amount of customers that can be in the bakery at any given time.")
    elseif command == "set_base_patience_multiplier" then
        ChatHook.send_info_to_chat("Usage: /set_base_patience_multiplier <number>")
        ChatHook.send_info_to_chat("Default: 1.0")
        ChatHook.send_info_to_chat("Sets the base patience multiplier for when there are no customers in the bakery.")
    elseif command == "set_min_eating_duration" then
        ChatHook.send_info_to_chat("Usage: /set_min_eating_duration <number>")
        ChatHook.send_info_to_chat("Default: 15.0")
        ChatHook.send_info_to_chat("Sets the minimum eating duration for customers.")
    elseif command == "set_max_eating_duration" then
        ChatHook.send_info_to_chat("Usage: /set_max_eating_duration <number>")
        ChatHook.send_info_to_chat("Default: 30.0")
        ChatHook.send_info_to_chat("Sets the maximum eating duration for customers.")
    elseif command == "set_patience_tweaks" then
        ChatHook.send_info_to_chat("Usage: /set_patience_tweaks <true/false>")
        ChatHook.send_info_to_chat("Default: true")
        ChatHook.send_info_to_chat("Sets the patience tweaks on or off.")
    elseif command == "set_eating_duration_tweaks" then
        ChatHook.send_info_to_chat("Usage: /set_eating_duration_tweaks <true/false>")
        ChatHook.send_info_to_chat("Default: true")
        ChatHook.send_info_to_chat("Sets the eating duration tweaks on or off.")
    elseif command == "show_patience_tweaks" then
        ChatHook.send_info_to_chat("Usage: /show_patience_tweaks")
        ChatHook.send_info_to_chat("Shows the current state of the patience tweaks.")
    elseif command == "show_eating_duration_tweaks" then
        ChatHook.send_info_to_chat("Usage: /show_eating_duration_tweaks")
        ChatHook.send_info_to_chat("Shows the current state of the eating duration tweaks.")
    elseif command == "show_min_customers" then
        ChatHook.send_info_to_chat("Usage: /show_min_customers")
        ChatHook.send_info_to_chat("Shows the current minimum amount of customers that can be in the bakery at any given time.")
    elseif command == "show_max_customers" then
        ChatHook.send_info_to_chat("Usage: /show_max_customers")
        ChatHook.send_info_to_chat("Shows the current maximum amount of customers that can be in the bakery at any given time.")
    elseif command == "show_base_patience_multiplier" then
        ChatHook.send_info_to_chat("Usage: /show_base_patience_multiplier")
        ChatHook.send_info_to_chat("Shows the current base patience multiplier for when there are no customers in the bakery.")
    elseif command == "show_min_eating_duration" then
        ChatHook.send_info_to_chat("Usage: /show_min_eating_duration")
        ChatHook.send_info_to_chat("Shows the current minimum eating duration for customers.")
    elseif command == "show_max_eating_duration" then
        ChatHook.send_info_to_chat("Usage: /show_max_eating_duration")
        ChatHook.send_info_to_chat("Shows the current maximum eating duration for customers.")
    elseif command == "df_reset" then
        ChatHook.send_info_to_chat("Usage: /df_reset")
        ChatHook.send_info_to_chat("Resets the config file to its default state.")
    elseif command == "help" then
        ChatHook.send_info_to_chat("Usage: /help <command>")
        ChatHook.send_info_to_chat("Displays information about a command.")
    else
        ChatHook.send_warning_to_chat("Unknown command. Refer to the mod page for a list of commands.")
    end
end

--- Handles commands issued to the mod, parsing and executing the appropriate command functions.
--- Commands should be prefixed with a slash ("/").
---@param command string The command string issued by the user, including parameters.
function handleCommands(command)
    print("Handling command " .. command .. "\n")
    if string.sub(command, 1, 1) == "/" then
        min_customers_command_string = "/set_min_customers "
        max_customers_command_string = "/set_max_customers "
        reset_config_command_string = "/df_reset"
        show_min_customers_command_string = "/show_min_customers"
        show_max_customers_command_string = "/show_max_customers"
        help_command_string = "/help "
        set_base_patience_multiplier_command_string = "/set_base_patience_multiplier "
        show_base_patience_multiplier_command_string = "/show_base_patience_multiplier"
        set_min_eating_duration_command_string = "/set_min_eating_duration "
        show_min_eating_duration_command_string = "/show_min_eating_duration"
        set_max_eating_duration_command_string = "/set_max_eating_duration "
        show_max_eating_duration_command_string = "/show_max_eating_duration"
        set_patience_tweaks_command_string = "/set_patience_tweaks "
        show_patience_tweaks_command_string = "/show_patience_tweaks"
        set_eating_duration_tweaks_command_string = "/set_eating_duration_tweaks "
        show_eating_duration_tweaks_command_string = "/show_eating_duration_tweaks"

        if string.sub(command, 1, #show_min_customers_command_string) == show_min_customers_command_string then
            showMinCustomersCommand()
        elseif string.sub(command, 1, #show_max_customers_command_string) == show_max_customers_command_string then
            showMaxCustomersCommand()
        elseif string.sub(command, 1, #reset_config_command_string) == reset_config_command_string then
            resetConfigCommand()
        elseif string.sub(command, 1, #max_customers_command_string) == max_customers_command_string then
            setMaxCustomersCommand(tonumber(string.sub(command, #max_customers_command_string + 1, #command)))
        elseif string.sub(command, 1, #min_customers_command_string) == min_customers_command_string then
            setMinCustomersCommand(tonumber(string.sub(command, #min_customers_command_string + 1, #command)))
        elseif string.sub(command, 1, #help_command_string) == help_command_string then
            helpCommand(string.sub(command, #help_command_string + 1, #command))
        elseif string.sub(command, 1, #set_base_patience_multiplier_command_string) == set_base_patience_multiplier_command_string then
            setBasePatienceMultiplierCommand(tonumber(string.sub(command, #set_base_patience_multiplier_command_string + 1, #command)))
        elseif string.sub(command, 1, #show_base_patience_multiplier_command_string) == show_base_patience_multiplier_command_string then
            showBasePatienceMultiplierCommand()
        elseif string.sub(command, 1, #set_min_eating_duration_command_string) == set_min_eating_duration_command_string then
            setMinEatingDurationCommand(tonumber(string.sub(command, #set_min_eating_duration_command_string + 1, #command)))
        elseif string.sub(command, 1, #show_min_eating_duration_command_string) == show_min_eating_duration_command_string then
            showMinEatingDurationCommand()
        elseif string.sub(command, 1, #set_max_eating_duration_command_string) == set_max_eating_duration_command_string then
            setMaxEatingDurationCommand(tonumber(string.sub(command, #set_max_eating_duration_command_string + 1, #command)))
        elseif string.sub(command, 1, #show_max_eating_duration_command_string) == show_max_eating_duration_command_string then
            showMaxEatingDurationCommand()
        elseif string.sub(command, 1, #set_patience_tweaks_command_string) == set_patience_tweaks_command_string then
            setPatienceTweaksCommand(tostring(string.sub(command, #set_patience_tweaks_command_string + 1, #command)))
        elseif string.sub(command, 1, #show_patience_tweaks_command_string) == show_patience_tweaks_command_string then
            showPatienceTweaksCommand()
        elseif string.sub(command, 1, #set_eating_duration_tweaks_command_string) == set_eating_duration_tweaks_command_string then
            setEatingDurationTweaksCommand(tostring(string.sub(command, #set_eating_duration_tweaks_command_string + 1, #command)))
        elseif string.sub(command, 1, #show_eating_duration_tweaks_command_string) == show_eating_duration_tweaks_command_string then
            showEatingDurationTweaksCommand()
        else 
            ChatHook.send_warning_to_chat("Unknown command. Refer to the mod page for a list of commands.")
        end
    end
end

function calc_spawn_delay()
    ---@type ABP_BakeryGameState_Ingame_C
    if (FIRST_CALC_DAY_LENGTH) then
        local gameState = FindFirstOf("BP_BakeryGameState_Ingame_C")
        local seconds = ((12 * 60) / gameState.GameTimeMultiplier) * 60
        DAY_LENGTH = seconds
        FIRST_CALC_DAY_LENGTH = true
        CALCULATED_DELAY_ON_CUSTOMER_SPAWN = DAY_LENGTH / CUSTOMERS_FOR_DAY
        return
    end
    return CALCULATED_DELAY_ON_CUSTOMER_SPAWN
    
end

local function StartMod()

    RegisterHook("/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GetMaxCustomerNumber", function(context)
        -- This function returns the amount of customers that a day will receive
        
        return getMaxCustomers()
    end)

    --- to be deleted as it's in chathook
    RegisterHook("/Game/Blueprints/Characters/Player/BP_Player.BP_Player_C:PlayerChatMessage_OnServer", function(context, message)

        local msg = tostring(message:get().ToString(message:get()))
        if string.sub(msg, 1, 1) == "/" then
            handleCommands(msg)
        end
    end)

    RegisterHook('/Game/Blueprints/Characters/Customer/Tasks/BTT_CustomerEating.BTT_CustomerEating_C:RandomEatingMode', function(context)
        if CONFIG.getEnableEatingDurationTweaks() == false then
            return
        end
        ---@type UBTT_CustomerEating_C
        local customerEating = context:get()
        local eating_duration = math.random(CONFIG["MIN_POSSIBLE_EATING_TIME"], CONFIG["MAX_POSSIBLE_EATING_TIME"])
        eating_duration = eating_duration * EATING_DURATION_MULTIPLIER
        if (eating_duration < 1.0) then
            eating_duration = 1.0
        end
        customerEating:SetPropertyValue('EatingDuration', eating_duration)
    end)

    -- @TODO: Make these scale with time
    RegisterHook('/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GenerateSpawnCooldown', function(context)
        return calc_spawn_delay()
    end)

    RegisterHook('/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GenerateDriveThruSpawnCooldown', function(context)
        return calc_spawn_delay()
    end)

    RegisterHook('/Game/Blueprints/Gameplay/Door/BP_EntranceDoor.BP_EntranceDoor_C:SetEntranceDoorOpen', function(context)
        FIRST_CALC_DAY_LENGTH = false
        CUSTOMERS_FOR_DAY = getMaxCustomers()
        if FIRST_TIME_GETTING_HELP_MESSSAGE == false then
            displayStartupMessage()
            FIRST_TIME_GETTING_HELP_MESSSAGE = true
            ChatHook.send_info_to_chat(tostring(getMaxCustomers()) .. " Customers will come by today!")
        end
    end)

    RegisterHook('/Game/Blueprints/GameMode/GameState/BP_BakeryGameState_Ingame.BP_BakeryGameState_Ingame_C:NewDayStarted_OnMulticast', function(context)
        FIRST_CALC_DAY_LENGTH = false
        if FIRST_TIME_GETTING_HELP_MESSSAGE == false then
            displayStartupMessage()
            FIRST_TIME_GETTING_HELP_MESSSAGE = true
        end
        CUSTOMERS_FOR_DAY = getMaxCustomers()
        ChatHook.send_info_to_chat(tostring(getMaxCustomers()) .. " Customers will come by today!")
    end)

    
    
    

    -- ChatHook.send_info_to_chat("Thank you for using Difficulty Tweaks!")
    -- TODO: Add info on commands (use a hook instead)
end


-- Flag to avoid loading the mod multiple times
local isLoaded = false

NotifyOnNewObject('/Game/Blueprints/GameMode/GameState/BP_BakeryGameState.BP_BakeryGameState_C', function()
    FIRST_TIME_GETTING_HELP_MESSSAGE = false
    FIRST_CALC_DAY_LENGTH = false
    -- Check if the mod is already loaded
    if isLoaded == true then
        return
    end

    -- Find the game state object
    local BakeryGameStateIngame = FindFirstOf('BP_BakeryGameState_Ingame_C')
    if BakeryGameStateIngame == nil then
        return
    end

    -- Check if the game is running (check value of bIsRestaurantRunning)
    local bIsRestaurantRunning = BakeryGameStateIngame:GetPropertyValue('bIsRestaurantRunning')
    if bIsRestaurantRunning ~= false then
        return
    end

    -- Load the mod
    StartMod()

    -- Update the flag
    isLoaded = true

end)

-- Run the getCustomers function every 2 seconds
LoopAsync(2000, function()
    processCustomers()
end)