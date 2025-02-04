StringUtils = {}

--- Replaces a character in a string
---@param str string
---@param old_char string
---@param new_char string
---@return string
function StringUtils.replace_char(str, old_char, new_char)
    return str:gsub(old_char, new_char)
end

--- Finds the first number in a string
---@param str string
---@return string
function StringUtils.find_first_number(str)
    return str:match("%d+")
end

--- Finds the first string before whitespace
---@param str string
---@return string
function StringUtils.find_first_word(str)
    return str:match("%S+")
end

--- Uppercases the first letter of each word in a string
--- @param str string
--- @return string
function StringUtils.capitalize(str)
    return str:gsub("^%l", string.upper)
end

return StringUtils