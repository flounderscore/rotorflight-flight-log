local csv = require("csv")

local models = require("models")

local defaultFilenameFlights = "flights.csv"

local defaultFilenameAircraft = "aircraft.csv"

local headersFlights = {"modelId", "flightIndex", "flightStartTime", "flightDurationSeconds", "capacityUsedMah"}

local headersAircraft = {"modelId", "numberOfFlights", "flightDurationSeconds", "capacityUsedMah"}

--- Compare the top-level content of two tables for equality.
-- @param t1 table: The first table.
-- @param t2 table: The second table.
-- @return boolean: True if the tables have the same top-level keys and values, false otherwise.
local function tableEquals(t1, t2)
    if t1 == t2 then
        return true -- Same reference
    end

    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false -- One or both are not tables
    end

    -- Compare keys and values in t1
    for key, value in pairs(t1) do
        if t2[key] ~= value then
            return false
        end
    end

    -- Check if t2 has keys not in t1
    for key in pairs(t2) do
        if t1[key] == nil then
            return false
        end
    end

    return true
end

--- Check the headers of a file or initialize file with the expected headers.
-- @param filename string: The name of the file to check or initialize.
-- @param expectedHeaders table: The expected headers of the file.
-- @return boolean: True if the headers match the expected headers or were initialized, false otherwise.
local function checkHeadersOrInitialize(filename, expectedHeaders)
    local file = io.open(filename, "r")
    if not file then
        file = io.open(filename, "w")
        if not file then
            error("Could not open file for writing: " .. filename)
        end
        csv.writeCsvHeadersToFile(file, expectedHeaders)
        file:close()
        return true
    end

    local headers = csv.readCsvHeadersFromFile(file)
    file:close()

    return tableEquals(headers, expectedHeaders)
end

local Flights = {}
Flights.__index = Flights

function Flights.new(filenameFlights, filenameAircraft)
    local self = setmetatable({}, Flights)

    self.filenameFlights = filenameFlights or defaultFilenameFlights
    self.filenameAircraft = filenameAircraft or defaultFilenameAircraft

    -- This will hold the flights in memory. We don't load flights into memory by default; this willbe done on demand 
    -- with `loadFlights`.
    self.flights = {}

    -- We only read the aircraft data once at the beginning and keep it in memory.
    checkHeadersOrInitialize(self.filenameAircraft, headersAircraft)
    local _, aircraft = csv.readCsv(self.filenameAircraft) -- Load existing aircraft data from the CSV file.
    self.aircraft = aircraft

    return self
end

--- Load flights from the CSV file into memory.
-- @param modelId number|nil: If provided, only flights with this modelId will be loaded.
-- @param append boolean: If true, will append to the existing flights in memory. If false, will clear the existing flights.
function Flights:loadFlights(modelId, append)
    append = append or false

    local file = io.open(self.filenameFlights, "r")
    if not file then
        error("Could not open file: " .. self.filenameFlights)
    end

    local headers = csv.readCsvHeadersFromFile(file)
    if headers ~= headersFlights then
        error("Headers in file do not match expected headers for flights.")
    end

    if not append then
        self.flights = {}  -- Clear the existing flights if not appending.
    end

    for row in csv.readCsvRowsFromFile(file) do
        local flight = models.Flight.new()
        if modelId and row["modelId"] ~= modelId then
            goto continue
        end
        for _, columnName in ipairs(headers) do
            flight[columnName] = row[columnName]
        end
        table.insert(self.flights, flight)

        ::continue:: -- Continue to the next row if the modelId does not match.
    end

    file:close()
end

function Flights:getNumberOfFlights(modeId)
    if not self.flights then
        return 0
    end

    if modeId then
        local count = 0
        for _, flight in ipairs(self.flights) do
            if tonumber(flight.modelId) == modeId then
                count = count + 1
            end
        end
        return count
    end

    return 0
end

function Flights:appendFlight(flight)
    if not checkHeadersOrInitialize(self.filenameFlights, headersFlights) then
        error("Headers of file do not match expected headers: " .. self.filenameFlights)
    end

    if not flight.isCompleted then
        flight:finishFlight()
    end

    if not flight.flightIndex then
        flight.flightIndex = self:getNumberOfFlights(flight.modelId)
        print(flight.flightIndex)
    end

    table.insert(self.flights, flight) -- Store the flight in memory for further processing if needed.

    local file = io.open(self.filenameFlights, "a")
    if not file then
        error("Could not open file: " .. self.filenameFlights)
    end
    csv.writeCsvRowToFile(file, headersFlights, flight:toTable())
    file:close()

    self:updateAircraft(flight) -- Update the aircraft data based on this flight.
end

function Flights:updateAircraft(flight)
    -- Find the existing record for the modelId or create a new one if it doesn't exist.
    local modelId = flight.modelId
    local aircraftRecord = nil
    for _, record in ipairs(self.aircraft) do
        if tonumber(record.modelId) == modelId then
            aircraftRecord = record
            break
        end
    end
    if not aircraftRecord then
        -- Create a new record if it doesn't exist.
        aircraftRecord = {
            modelId = modelId
        }
        table.insert(self.aircraft, aircraftRecord) -- Add the new record to the list.
    end

    -- Update the aircraft record with the flight data.
    aircraftRecord.numberOfFlights = (aircraftRecord.numberOfFlights or flight.flightIndex or 0) + 1
    aircraftRecord.flightDurationSeconds = (aircraftRecord.flightDurationSeconds or 0) + (flight.flightDurationSeconds or 0)
        -- Add the flight duration to the existing total. If nil, default to 0.
        -- This ensures that if flightDurationSeconds is nil, it defaults to 0.
    aircraftRecord.capacityUsedMah = (aircraftRecord.capacityUsedMah or 0) + (flight.capacityUsedMah or 0)

    -- Write the updated record back to the CSV file.
    csv.writeCsv(self.filenameAircraft, headersAircraft, self.aircraft)
end

function Flights:__tostring()
    local s = string.format(
        "Flights(filenameFlights=%s, filenameAircraft=%s):",
        self.filenameFlights,
        self.filenameAircraft
    )
    for _, flight in ipairs(self.flights) do
        -- Append each flight's string representation to the output.
        s = s .. "\n    " .. tostring(flight)
    end
    return s
end

return {
    Flights = Flights
}

