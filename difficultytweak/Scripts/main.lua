print("Loading Difficulty Tweak - By Creativious")

-- Credits For JSON https://github.com/rxi/json.lua/blob/master/json.lua

Json = require "libs/json"

TABLES = 17

CUSTOMERS_FULL = false

CONFIG = {
    MIN_POSSIBLE_CUSTOMERS = 25,
    MAX_POSSIBLE_CUSTOMERS=  500
}
BASE_PATIENCE_MULTIPLIER = 1.5 + ((CONFIG["MAX_POSSIBLE_CUSTOMERS"] / 50) / 10)

PATIENCE_MULTIPLIER = BASE_PATIENCE_MULTIPLIER

HAS_GOTTEN_DEFAULT_PATIENCE = false

DEFAULT_PATIENCE = 0

WAITING_CUSTOMERS = 0

FIRST_TIME_GETTING_HELP_MESSSAGE = false

DEFAULT_MIN_EATING_DURATION = 15.0
DEFAULT_MAX_EATING_DURATION = 30.0

EATING_DURATION_BASE_MULTIPLIER = 1.0

EATING_DURATION_MULTIPLIER = EATING_DURATION_BASE_MULTIPLIER

CUSTOMERS_WITH_ORDER_NUMBER = 0

--- Returns the maximum number of customers
---@return integer
function getMaxCustomers()
    local bakery_ingame = FindFirstOf("BP_BakeryGameState_Ingame_C")
    local level = bakery_ingame:GetRestaurantLevel()
    local total_days = bakery_ingame:GetTotalDays()

    print("Level: " .. tostring(level) .. "\n")
    print("Total Days: " .. tostring(total_days) .. "\n")

    local customer_count = CONFIG["MIN_POSSIBLE_CUSTOMERS"] + CONFIG["MAX_POSSIBLE_CUSTOMERS"] * (0 + ((level - 1) / 600) + (total_days / 400))
    customer_count = round(customer_count)
    if customer_count > CONFIG["MAX_POSSIBLE_CUSTOMERS"] then
        customer_count = CONFIG["MAX_POSSIBLE_CUSTOMERS"]
    end
    if customer_count < CONFIG["MIN_POSSIBLE_CUSTOMERS"] then
        customer_count = CONFIG["MIN_POSSIBLE_CUSTOMERS"]
    end
    print("Customer Count: " .. tostring(customer_count) .. "\n")
    sendInfoSystemMessage(tostring(customer_count) .. " Customers will come by today!")
    return customer_count
end

-- --- Sends a message to the chat
-- ---@param message string
-- function sendGlobalResponseMessage(message)
--     ---@type ABP_BakeryGameState_Ingame_C
--     local bakery_gamestate = FindFirstOf("BP_BakeryGameState_C")
--     ---@diagnostic disable-next-line
--     bakery_gamestate:PlayerChatMessage_OnMulticast("Difficulty Tweaks", message)
-- end

--- Sends a message to the chat with the info type
---@param message string
function sendInfoSystemMessage(message)
    sendSystemMessage(0, message)
end

--- Sends a message to the chat with the warning type
---@param message string
function sendWarningSystemMessage(message)
    sendSystemMessage(1, message)
end

--- Sends a message to the chat.
--- type = 0 for info, 1 for warning
--- @param type integer
--- @param message string
function sendSystemMessage(type, message)
    ---@type ABP_BakeryHUD_Ingame_C
    local bakery_hud = FindFirstOf("BP_BakeryHUD_Ingame_C")

    ---@class FFChatSystemMessage
    ---@field MessageType_3_8455A93744E1FFF8CD7CFF8FD10D675F EChatSystemMessageType::Type
    ---@field Message_6_1B82BC08456FC4C9E531BA890AE72DFF FText
    FFChatSystemMessage = {}
    FFChatSystemMessage.MessageType_3_8455A93744E1FFF8CD7CFF8FD10D675F = type
    FFChatSystemMessage.Message_6_1B82BC08456FC4C9E531BA890AE72DFF = FText(message)

    bakery_hud:AddSystemMessage(FFChatSystemMessage)
end

CONFIG_LOCATION = "Mods/difficultytweak/config.json"

--- Writes the config file
---@param table table
function write_to_config(table)
    local f = io.open(CONFIG_LOCATION, "w")
    f:write(Json.encode(table))
    f:close()
end

--- Reads the config file
---@return table
function read_config()
    local f = io.open(CONFIG_LOCATION, "r")
    local result = Json.decode(f:read())
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
    CONFIG = read_config()
else
    write_to_config(CONFIG)
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
                if patience_speed ~= round(DEFAULT_PATIENCE * PATIENCE_MULTIPLIER) then
                    customer:SetPatienceSpeed(round(DEFAULT_PATIENCE * PATIENCE_MULTIPLIER))
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


function setMinCustomersCommand(minCustomers)
    if minCustomers == nil then
        sendWarningSystemMessage("Incorrect usage of the command.")
        sendWarningSystemMessage("Usage: /set_min_customers <number>")
        return
    end
    sendInfoSystemMessage("Minimum Customers set to " .. minCustomers)
    CONFIG["MIN_POSSIBLE_CUSTOMERS"] = minCustomers
    write_to_config(CONFIG)
    sendInfoSystemMessage("Reload saves to apply changes.")
end

function setMaxCustomersCommand(maxCustomers)
    if maxCustomers == nil then
        sendWarningSystemMessage("Incorrect usage of the command.")
        sendWarningSystemMessage("Usage: /set_max_customers <number>")
        return
    end
    sendInfoSystemMessage("Maximum Customers set to " .. maxCustomers)
    CONFIG["MAX_POSSIBLE_CUSTOMERS"] = maxCustomers
    write_to_config(CONFIG)
    sendInfoSystemMessage("Reload saves to apply changes.")
end

function showMinCustomersCommand()
    sendInfoSystemMessage("Minimum Customers: " .. CONFIG["MIN_POSSIBLE_CUSTOMERS"])
end

function showMaxCustomersCommand()
    sendInfoSystemMessage("Maximum Customers: " .. CONFIG["MAX_POSSIBLE_CUSTOMERS"])
end

function resetConfigCommand()
    sendInfoSystemMessage("Resetting config file.")
    CONFIG["MIN_POSSIBLE_CUSTOMERS"] = 25
    CONFIG["MAX_POSSIBLE_CUSTOMERS"] = 500
    write_to_config(CONFIG)
    sendInfoSystemMessage("Reload saves to apply changes.")
end

function displayStartupMessage()
    sendInfoSystemMessage("Difficulty Tweaks - By Creativious")
    sendInfoSystemMessage("Commands:")
    sendInfoSystemMessage("/set_max_customers [default: 25] <number>")
    sendInfoSystemMessage("/set_min_customers [default: 500] <number>")
    sendInfoSystemMessage("/df_reset - Resets the config file")
    sendInfoSystemMessage("/show_min_customers")
    sendInfoSystemMessage("/show_max_customers")
end

function handleCommands(command)
    print("Handling command " .. command .. "\n")
    if string.sub(command, 1, 1) == "/" then
        min_customers_command_string = "/set_min_customers "
        max_customers_command_string = "/set_max_customers "
        reset_config_command_string = "/df_reset"
        show_min_customers_command_string = "/show_min_customers"
        show_max_customers_command_string = "/show_max_customers"

        if string.sub(command, 1, #show_min_customers_command_string) == show_min_customers_command_string then
            showMinCustomersCommand()
        end
        if string.sub(command, 1, #show_max_customers_command_string) == show_max_customers_command_string then
            showMaxCustomersCommand()
        end

        if string.sub(command, 1, #reset_config_command_string) == reset_config_command_string then
            resetConfigCommand()
        end
        if string.sub(command, 1, #max_customers_command_string) == max_customers_command_string then
            setMaxCustomersCommand(tonumber(string.sub(command, #max_customers_command_string + 1, #command)))
        end
        if string.sub(command, 1, #min_customers_command_string) == min_customers_command_string then
            setMinCustomersCommand(tonumber(string.sub(command, #min_customers_command_string + 1, #command)))
        end
    end
end


local function StartMod()

    RegisterHook("/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GetMaxCustomerNumber", function(context)
        -- This function returns the amount of customers that a day will receive
        if FIRST_TIME_GETTING_HELP_MESSSAGE == false then
            displayStartupMessage()
            FIRST_TIME_GETTING_HELP_MESSSAGE = true
        end
        return getMaxCustomers()
    end)

    RegisterHook("/Game/Blueprints/Characters/Player/BP_Player.BP_Player_C:PlayerChatMessage_OnServer", function(context, message)

        local msg = tostring(message:get().ToString(message:get()))
        if string.sub(msg, 1, 1) == "/" then
            handleCommands(msg)
        end
    end)

    RegisterHook('/Game/Blueprints/Characters/Customer/Tasks/BTT_CustomerEating.BTT_CustomerEating_C:RandomEatingMode', function(context)
        ---@type UBTT_CustomerEating_C
        local customerEating = context:get()
        local eating_duration = math.random(CONFIG["MIN_POSSIBLE_EATING_TIME"], CONFIG["MAX_POSSIBLE_EATING_TIME"])
        eating_duration = eating_duration * EATING_DURATION_MULTIPLIER
        if (eating_duration < 1.0) then
            eating_duration = 1.0
        end
        customerEating:SetPropertyValue('EatingDuration', eating_duration)
    end)
    
    

    -- sendInfoSystemMessage("Thank you for using Difficulty Tweaks!")
    -- TODO: Add info on commands (use a hook instead)
end


-- Flag to avoid loading the mod multiple times
local isLoaded = false

NotifyOnNewObject('/Game/Blueprints/GameMode/GameState/BP_BakeryGameState.BP_BakeryGameState_C', function()
    FIRST_TIME_GETTING_HELP_MESSSAGE = false
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