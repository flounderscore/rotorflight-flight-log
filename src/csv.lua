--- Escapes a value for safe inclusion in a CSV file.
-- If the value is a string, double quotes are escaped, and the value is wrapped in quotes.
-- If the value is nil, an empty string is returned.
-- Otherwise, the value is converted to a string.
-- @param value any The value to escape. (string|nil|number)
-- @return string The escaped value as a string.
local function escape_csv(value)
    if type(value) == "string" then
        -- Escape double quotes by doubling them and wrap the value in quotes
        value = value:gsub('"', '""')
        return '"' .. value .. '"'
    elseif value == nil then
        return ""
    else
        return tostring(value)
    end
end

--- Writes the header row to a CSV file.
-- @param file file* The file object to write to.
-- @param headers table A table containing the header names.
local function write_csv_headers_to_file(file, headers)
    -- Write the header row to the file object
    file:write(table.concat(headers, ",") .. "\n")
end

--- Writes the data rows to a CSV file.
-- @param file file* The file object to write to.
-- @param headers table A table containing the header names.
-- @param data table A table containing the data rows, where each row is a table with keys matching the headers.
local function write_csv_data_to_file(file, headers, data)
    -- Write the data rows to the file object
    for _, row in ipairs(data) do
        local values = {}
        for _, header in ipairs(headers) do
            table.insert(values, escape_csv(row[header]))
        end
        file:write(table.concat(values, ",") .. "\n")
    end
end

--- Writes a complete CSV file, including headers and data.
-- @param filename string The name of the file to write to.
-- @param headers table A table containing the header names.
-- @param data table A table containing the data rows, where each row is a table with keys matching the headers.
local function write_csv(filename, headers, data)
    local file, err = io.open(filename, "w")
    if not file then
        error("Could not open file for writing: " .. err)
    end

    write_csv_headers_to_file(file, headers)
    write_csv_data_to_file(file, headers, data)

    file:close()
end

--- Reads the header row from a CSV file object.
-- @param file file* The file object to read from.
-- @return table A table containing the header names.
local function read_csv_headers_from_file(file)
    -- Read the header row from the file object
    local headers = {}
    local header_line = file:read("*l")
    for header in header_line:gmatch("[^,]+") do
        table.insert(headers, header)
    end
    return headers
end

--- Reads the data rows from a CSV file object.
-- @param file file* The file object to read from.
-- @param headers table A table containing the header names.
-- @return table A table containing the data rows, where each row is a table with keys matching the headers.
local function read_csv_data_from_file(file, headers)
    -- Read the data rows from the file object
    local data = {}
    for line in file:lines() do
        local row = {}
        for i, value in ipairs(line:split(",")) do
            row[headers[i]] = value
        end
        table.insert(data, row)
    end
    return data
end

--- Reads the header row from a CSV file.
-- @param filename string The name of the file to read from.
-- @return table A table containing the header names.
local function read_csv_headers(filename)
    local file, err = io.open(filename, "r")
    if not file then
        error("Could not open file for reading: " .. err)
    end

    local headers = read_csv_headers_from_file(file)
    file:close()
    return headers
end

--- Reads a complete CSV file, including headers and data.
-- @param filename string The name of the file to read from.
-- @return table, table A table containing the header names and a table containing the data rows.
local function read_csv(filename)
    local file, err = io.open(filename, "r")
    if not file then
        error("Could not open file for reading: " .. err)
    end

    local headers = read_csv_headers_from_file(file)
    local data = read_csv_data_from_file(file, headers)

    file:close()
    return headers, data
end

--- Reads the last row from a CSV file object.
-- @param file file* The file object to read from.
-- @param headers table A table containing the header names.
-- @return table A table representing the last row, where keys match the headers.
local function read_last_csv_row_from_file(file, headers)
    -- Seek to the end of the file
    file:seek("end", -1)

    -- Move backward until we find the start of the last line
    local pos = file:seek()
    while pos > 0 do
        file:seek("set", pos - 1)
        local char = file:read(1)
        if char == "\n" then
            break
        end
        pos = pos - 1
    end

    -- Read the last line
    local last_line = file:read("*l")

    -- Parse the last line into a table
    local row = {}
    local values = {}
    for value in last_line:gmatch("[^,]+") do
        table.insert(values, value)
    end

    for i, header in ipairs(headers) do
        row[header] = values[i]
    end

    return row
end

--- Reads the last row from a CSV file.
-- @param filename string The name of the file to read from.
-- @param headers table A table containing the header names.
-- @return table A table representing the last row, where keys match the headers.
local function read_last_csv_row(filename, headers)
    local file, err = io.open(filename, "r")
    if not file then
        error("Could not open file for reading: " .. err)
    end

    local last_row = read_last_csv_row_from_file(file, headers)
    file:close()
    return last_row
end

--- Writes a single row to a CSV file object.
-- @param file file* The file object to write to. Assumes the file is already seeked to the end.
-- @param headers table A table containing the header names.
-- @param row table A table representing the row to write, where keys match the headers.
local function write_csv_row_to_file(file, headers, row)
    local values = {}
    for _, header in ipairs(headers) do
        table.insert(values, escape_csv(row[header]))
    end
    file:write(table.concat(values, ",") .. "\n")
end

--- Writes a single row to a CSV file.
-- @param filename string The name of the file to write to.
-- @param headers table A table containing the header names.
-- @param row table A table representing the row to write, where keys match the headers.
local function write_csv_row(filename, headers, row)
    local file, err = io.open(filename, "a") -- Open in append mode
    if not file then
        error("Could not open file for writing: " .. err)
    end

    write_csv_row_to_file(file, headers, row)
    file:close()
end

return {
    write_csv = write_csv,
    read_csv = read_csv,
    read_csv_headers = read_csv_headers,
    read_last_csv_row = read_last_csv_row,
    write_csv_row = write_csv_row,
    write_csv_row_to_file = write_csv_row_to_file,
    write_csv_data_to_file = write_csv_data_to_file,
    write_csv_headers_to_file = write_csv_headers_to_file
}
