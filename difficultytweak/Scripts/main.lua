print("Loading Difficulty Tweak - By Creativious")

-- Credits For JSON https://github.com/rxi/json.lua/blob/master/json.lua

ChatHook = require "libs/chathook"

CommandManager = require "libs/commandmanager"

Config = require "libs/config"

TABLES = 17

CUSTOMERS_FULL = false

--- Calculates the base patience multiplier based on the maximum amount of customers that can be in the bakery at any given time
---@return number BasePatienceMultiplier base patience multiplier
function calcBasePatienceMultiplier()
    return (Config.get("BASE_PATIENCE_MULTIPLIER") + (Config.get("MAX_POSSIBLE_CUSTOMERS") / 50) / 10)
end

BASE_PATIENCE_MULTIPLIER = 1.0

PATIENCE_MULTIPLIER = BASE_PATIENCE_MULTIPLIER

HAS_GOTTEN_DEFAULT_PATIENCE = false

FIRST_CALC_DAY_LENGTH = false

CUSTOMERS_FOR_DAY = Config.get("MIN_POSSIBLE_CUSTOMERS")

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
    ---@type number
    local min_customers = Config.get("MIN_POSSIBLE_CUSTOMERS")
    ---@type number
    local max_customers = Config.get("MAX_POSSIBLE_CUSTOMERS")

    local customer_count = math.min(math.max(round(min_customers + max_customers * (0 + ((level - 1) / 600) + (total_days / 400))), min_customers), max_customers)
    return customer_count
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
                if Config.get("ENABLE_PATIENCE_TWEAKS") then
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
    PATIENCE_MULTIPLIER = BASE_PATIENCE_MULTIPLIER + (CUSTOMERS_WITH_ORDER_NUMBER / 300) + possible_patience_bonus + (WAITING_CUSTOMERS / 600)
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

--- Displays the startup message with information about the mod and available commands
function displayStartupMessage()
    ChatHook.send_info_to_chat("Difficulty Tweaks - By Creativious")
    ChatHook.send_info_to_chat("Commands (Listed on mod page):")
    ChatHook.send_info_to_chat("/help <command>")
    ChatHook.send_info_to_chat("^ Displays information about a command.")
end

function calc_spawn_delay()
    ---@type ABP_BakeryGameState_Ingame_C
    if (FIRST_CALC_DAY_LENGTH == false) then
        local gameState = FindFirstOf("BP_BakeryGameState_Ingame_C")
        local seconds = ((12 * 60) / gameState.GameTimeMultiplier) * 60
        DAY_LENGTH = seconds
        FIRST_CALC_DAY_LENGTH = true
        CALCULATED_DELAY_ON_CUSTOMER_SPAWN = DAY_LENGTH / getMaxCustomers()
    end
    return CALCULATED_DELAY_ON_CUSTOMER_SPAWN
    
end

local function StartMod()

    RegisterHook("/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GetMaxCustomerNumber", function(context)
        -- This function returns the amount of customers that a day will receive
        
        return getMaxCustomers()
    end)

    RegisterHook('/Game/Blueprints/Characters/Customer/Tasks/BTT_CustomerEating.BTT_CustomerEating_C:RandomEatingMode', function(context)
        if Config.get("ENABLE_EATING_DURATION_TWEAKS") == false then
            return
        end
        ---@type UBTT_CustomerEating_C
        local customerEating = context:get()
        ---@diagnostic disable-next-line
        local eating_duration = math.random(Config.get("MIN_POSSIBLE_EATING_TIME"), Config.get("MAX_POSSIBLE_EATING_TIME"))
        eating_duration = eating_duration * EATING_DURATION_MULTIPLIER
        if (eating_duration < 1.0) then
            eating_duration = 1.0
        end
        customerEating:SetPropertyValue('EatingDuration', eating_duration)
    end)

    -- @TODO: Make these scale with time
    RegisterHook('/Game/Blueprints/Gameplay/CustomerQueue/BP_CustomerManager.BP_CustomerManager_C:GenerateSpawnCooldown', function(context)
        local delay = calc_spawn_delay()
        return delay
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

--- /df_reset
---@param feedback CommandFeedback
function df_reset_command(feedback)
    Config.reset()
    ChatHook.send_info_to_chat("The config file has been reset to its default state.")
    ChatHook.send_info_to_chat("Reload save to apply changes.")
end

function on_startup()
    -- Config
    Config.set_location("Mods/difficultytweak/config.json") --- Change this if you use my code and have a different mod name

    Config.set_default("MIN_POSSIBLE_CUSTOMERS", 25)
    Config.set_default("MAX_POSSIBLE_CUSTOMERS", 500)
    Config.set_default("MIN_EATING_DURATION", 15.0)
    Config.set_default("BASE_PATIENCE_MULTIPLIER", 1.0)
    Config.set_default("MAX_EATING_DURATION", 30.0)
    Config.set_default("ENABLE_EATING_DURATION_TWEAKS", true)
    Config.set_default("ENABLE_PATIENCE_TWEAKS", true)

    Config.read()

    -- Commands
    CommandManager.register_command_for_config("max_customers", "MAX_POSSIBLE_CUSTOMERS", "Sets|Shows the maximum amount of customers that can be in the restaurant at any given time.")
    CommandManager.register_command_for_config("min_customers", "MIN_POSSIBLE_CUSTOMERS", "Sets|Shows the minimum amount of customers that can be in the restaurant at any given time.")
    CommandManager.register_command_for_config("base_patience_multiplier", "BASE_PATIENCE_MULTIPLIER", "Sets|Shows the base patience multiplier.")
    CommandManager.register_command_for_config("min_eating_duration", "MIN_EATING_DURATION", "Sets|Shows the minimum eating duration for customers.")
    CommandManager.register_command_for_config("max_eating_duration", "MAX_EATING_DURATION", "Sets|Shows the maximum eating duration for customers.")
    CommandManager.register_command_for_config("eating_duration_tweaks", "ENABLE_EATING_DURATION_TWEAKS", "Toggle|Display eating duration tweaks.")
    CommandManager.register_command_for_config("patience_tweaks", "ENABLE_PATIENCE_TWEAKS", "Toggle|Display whether or not the patience tweaks are enabled.")

    CommandManager.register_command("df_reset", "Reset the configuration to default settings.", {}, df_reset_command)

    BASE_PATIENCE_MULTIPLIER = calcBasePatienceMultiplier()

end

on_startup()