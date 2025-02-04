FileUtils = {}

--- Checks if a file exists
---@param path string The path to the file
---@return boolean Returns true if the file exists
function FileUtils.does_file_exist(path)
    local f = io.open(path, "r")
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

--- Reads a file
---@param path string The path to the file
---@return string | nil Returns nil if the file does not exist or if it is empty, otherwise returns the file content as a string
function FileUtils.read_file(path)
    if (FileUtils.does_file_exist(path) == false) then
        return nil
    end
    local f = io.open(path, "r")
    local result_t = f:read()
    f:close()
    if (result_t == "") then
        return nil
    end
    return result_t
end

--- Writes a file
---@param path string The path to the file
---@param content string The content of the file
function FileUtils.write_file(path, content)
    local f = io.open(path, "w")
    f:write(content)
    f:close()
end


return FileUtils