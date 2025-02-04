local chathook = {_version = "0.1.0"}

chathook.chat_callbacks = {}

chathook.__has_hooks_been_registered = false

NotifyOnNewObject('/Game/Blueprints/GameMode/GameState/BP_BakeryGameState.BP_BakeryGameState_C', function()
    if chathook.__has_hooks_been_registered == false then
        chathook.__register_hooks()
        chathook.__has_hooks_been_registered = true
    end
end)

--- Registers a hook for the chat message events (register_callback_on_chat_message doesn't work without this being used first)
function chathook.__register_hooks()

    --- when a chat message is received
    RegisterHook("/Game/Blueprints/Characters/Player/BP_Player.BP_Player_C:PlayerChatMessage_OnServer", function(context, message)
        local msg = tostring(message:get().ToString(message:get()))
        for _, callback in ipairs(chathook.chat_callbacks) do
            callback(msg)
        end
    end)
end

--- Registers a callback to be called when a chat message is received, requires to take in a string
---@param callback function
function chathook.register_callback_on_chat_message(callback)
    table.insert(chathook.chat_callbacks, callback)
end

--- Creates a system message, and returns it
---@param message_type integer
---@param message string
---@return FFChatSystemMessage
function chathook.__create_system_message(message_type, message)
    ---@class FFChatSystemMessage
    ---@field MessageType_3_8455A93744E1FFF8CD7CFF8FD10D675F EChatSystemMessageType::Type
    ---@field Message_6_1B82BC08456FC4C9E531BA890AE72DFF FText
    FFChatSystemMessage = {}
    FFChatSystemMessage.MessageType_3_8455A93744E1FFF8CD7CFF8FD10D675F = message_type
    FFChatSystemMessage.Message_6_1B82BC08456FC4C9E531BA890AE72DFF = FText(message)
    return FFChatSystemMessage
end

--- Sends a message to the chat with the specified type and message
---@param message_type integer The type of the system message
---@param message string The message to be sent
function chathook.__send_message_to_chat(message_type, message)
    ---@type ABP_BakeryHUD_Ingame_C
    local bakery_hud = FindFirstOf("BP_BakeryHUD_Ingame_C")
    bakery_hud:AddSystemMessage(chathook.__create_system_message(message_type, message))
end

--- Splits a string into multiple messages to be sent to the chat, with the specified type and callback
---@param message_type integer | string The type of the system message, can also be a string, if it's a string it is better use for the fake player message
---@param message string The message to be sent
---@param callback function The callback to be called for each split message
function chathook.__auto_split_string_with_callback(message_type, message, callback)
    local max_length = 48
    local new_message = ""
    for word in string.gmatch(message, "[^%s]+") do
        local word_length = string.len(word)
        if string.len(new_message) + word_length > max_length then
            if type(message_type) == "string" then
                callback(message_type,new_message)
            else
                callback(message_type, new_message)
            end
            new_message = ""
        end
        new_message = new_message .. word .. " "
    end
    if string.len(new_message) > 0 then
        if type(message_type) == "string" then
            callback(message_type, new_message)
        else
            callback(message_type, new_message)
        end
    end
end

--- Sends a message to the chat with the specified type and message
---@param message string The message to be sent
function chathook.send_info_to_chat(message)
    chathook.__auto_split_string_with_callback(0, message, chathook.__send_message_to_chat)
end

--- Sends a message to the chat with the specified type and message
---@param message string The message to be sent
function chathook.send_warning_to_chat(message)
    chathook.__auto_split_string_with_callback(1, message, chathook.__send_message_to_chat)
end

--- Sends a message to the chat with the specified player name and message
---@param player_name string The name of the player that sent the message
---@param message string The message to be sent
function chathook.send_fake_player_message_to_chat(player_name, message)
    chathook.__auto_split_string_with_callback(player_name, message, chathook.__send_fake_player_message_to_chat_callback)
end

--- Sends a fake player message to the chat with the specified player name and message (intended to be used as a callback)
---@param player_name string The name of the player that sent the message
---@param message string The message to be sent
function chathook.__send_fake_player_message_to_chat_callback(player_name, message)
    ---@type ABP_BakeryGameState_Ingame_C
    local gamestate = FindFirstOf("BP_BakeryGameState_Ingame_C")
    ---@diagnostic disable-next-line
    gamestate:PlayerChatMessage_OnMulticast(player_name, message)
end

return chathook