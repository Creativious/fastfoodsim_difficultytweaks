TableUtils = {

}

--- Copies all key-value pairs from one table to another
---@param from table The source table to copy from
---@return table result New copied table
function TableUtils.copy(from)
    local to = {}
    for key, value in pairs(from) do
        to[key] = value
    end
    return to
end

--- Filters out function entries from a table
---@param tbl table The table to filter
---@return table result New table with function entries removed
function TableUtils.__filter_functions_from_table(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        if type(value) ~= "function" then
            result[key] = value
        end
    end
    return result
end


--- Copies all key-value pairs from one table to another, excluding functions
---@param from table The source table to copy from
---@return table result New table with function entries removed
function TableUtils.copy_without_functions(from)
    local filtered_from = TableUtils.__filter_functions_from_table(from)
    return TableUtils.copy(filtered_from)
end

--- Returns the number of keys in a table
---@param tbl table The table to count keys from
---@return integer count The number of keys in the table
function TableUtils.count_keys(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Checks if the table contains a copy of this key, returns true if it does, false if it doesn't
---@param tbl table the table to check
---@param key string the key to check the table with
---@return boolean bool The return boolean
function TableUtils.does_table_contain_key(tbl, key)
    for tbl_key, _ in pairs(tbl) do
        if key == tbl_key then
            return true
        end
    end
    return false
end

--- Prints out a table
---@param tbl table
function TableUtils.print_out_table(tbl)
    for key, value in pairs(tbl) do
        if (type(value) == "table") then
            print(tostring(key) .. ":\n")
            TableUtils.print_out_table(value)
        end
        print(tostring(key) .. ": " .. tostring(value) .. "\n")
    end
end

--- Returns the keys in table 1 that are not in table 2
--- @param tbl1 table
--- @param tbl2 table
--- @return table
function TableUtils.find_mismatched_keys(tbl1, tbl2)
    local mismatched_keys = {}
    for key, _ in pairs(tbl1) do
        if tbl2[key] == nil then
            table.insert(mismatched_keys, key)
        end
    end
    return mismatched_keys
end

return TableUtils