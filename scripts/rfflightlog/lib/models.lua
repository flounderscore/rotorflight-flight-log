-- region Flight model

local Flight = {}
Flight.__index = Flight

--- Creates a new Flight instance.
-- @param flightIndex number: The index of the flight. If nil, it will be set to the next available index when added to a Flights instance.
-- @param modelId number: The ID of the model, -1 if not used.
-- @param batteryId number|nil: The ID of the battery used, nil if not used.
-- @param flightStartTime number|nil: The start time of the flight (UNIX timestamp), nil if not started.
-- @param flightSegmentStartTime number|nil: The start time of the current flight segment (UNIX timestamp), nil if no
--        segment is in progress.
-- @param flightDurationSeconds number: The total duration of the flight in seconds, 0 if not started.
-- @param capacityUsedMah number: The battery capacity used in mAh.
-- @param isCompleted boolean: Whether the flight is completed.
-- @return Flight: A new Flight instance.
function Flight.new(
    flightIndex,
    modelId,
    batteryId,
    flightStartTime,
    flightSegmentStartTime,
    flightDurationSeconds,
    capacityUsedMah,
    isCompleted
)
    local self = setmetatable({}, Flight)

    self.modelId = modelId or -1
    self.flightIndex = flightIndex
    self.flightStartTime = flightStartTime
    self.flightSegmentStartTime = flightSegmentStartTime or flightStartTime
    self.flightDurationSeconds = flightDurationSeconds or 0
    self.isCompleted = isCompleted or false
    self.batteryId = batteryId
    self.capacityUsedMah = capacityUsedMah or 0

    return self
end

--- Checks if the flight has started.
-- @return boolean: True if the flight has started, false otherwise.
function Flight:isStarted()
    return self.flightStartTime >= 0
end

--- Converts the Flight instance to a string representation.
-- @return string: A string representation of the Flight instance.
function Flight:__tostring()
    return string.format(
        "Flight(" ..
        "modelId=%d, " ..
        "flightIndex=%d, " ..
        "flightStartTime=%s, " ..
        "flightSegmentStartTime=%s, " ..
        "flightDuration=%d s, " ..
        "batteryId=%d, " ..
        "capacityUsedMah=%d mAh, " ..
        "isCompleted=%s)",
        self.modelId,
        self.flightIndex,
        os.date("\"%Y-%m-%d %H:%M:%S\"", self.flightStartTime),
        os.date("\"%Y-%m-%d %H:%M:%S\"", self.flightSegmentStartTime),
        self.flightDurationSeconds,
        self.batteryId or -1,
        self.capacityUsedMah,
        tostring(self.isCompleted)
    )
end

--- Converts the Flight instance to a table representation.
-- @return table: A table representation of the Flight instance.
-- @error string: An error message if the flight is not completed.
function Flight:toTable()
    return {
        modelId = self.modelId,
        flightIndex = self.flightIndex,
        flightStartTime = self.flightStartTime,
        flightDurationSeconds = self.flightDurationSeconds,
        batteryId = self.batteryId,
        capacityUsedMah = self.capacityUsedMah
    }
end

--- Starts a new flight segment.
-- @param now number: The current time (UNIX timestamp). Defaults to os.time().
-- @error string: An error message if the flight is already completed or if the flight segment has already been started.
function Flight:startSegment(now)
    if self.isCompleted then
        error("Cannot start segment. Flight is already completed.")
    end
    if self.flightSegmentStartTime ~= nil then
        error("Cannot start segment. Flight segment has already been started.")
    end

    now = now or os.time()

    -- Start overall flight time if not already started.
    if self.flightStartTime == nil then
        self.flightStartTime = now
    end

    self.flightSegmentStartTime = now
end

--- Finishes the current flight segment.
-- @param now number: The current time (UNIX timestamp). Defaults to os.time().
-- @error string: An error message if the flight is already completed or if the flight segment has not been started.
function Flight:finishSegment(now)
    if self.isCompleted then
        error("Cannot finish segment. Flight is already completed.")
    end

    if self.flightSegmentStartTime == nil then
        error("Cannot finish segment. Flight segment start time is not set.")
    end

    now = now or os.time()
    self.flightDurationSeconds = self.flightDurationSeconds + (now - self.flightSegmentStartTime)
    self.flightSegmentStartTime = nil
end

--- Starts the flight.
-- @param now number: The current time (UNIX timestamp). Defaults to os.time().
-- @error string: An error message if the flight is already completed or has already been started.
function Flight:startFlight(now)
    if self.isCompleted then
        error("Cannot start flight. Flight is already completed.")
    end

    if self.flightStartTime ~= nil then
        error("Cannot start flight. Flight has already been started.")
    end

    now = now or os.time()
    self.flightStartTime = now
end

--- Finishes the flight.
-- @param capacityUsedMah number: The battery capacity used in mAh.
-- @param now number: The current time (UNIX timestamp). Defaults to os.time().
-- @error string: An error message if the flight is already completed or if the flight segment has not been finished.
function Flight:finishFlight(capacityUsedMah, now)
    if self.isCompleted then
        error("Cannot finish flight. Flight is already completed.")
    end

    if self.flightSegmentStartTime ~= nil then
        self:finishSegment(now)
    end

    self.capacityUsedMah = capacityUsedMah or 0

    self.isCompleted = true
end
-- endregion

-- region Aircraft model

local Aircraft = {}
Aircraft.__index = Aircraft

--- Creates a new Aircraft instance.
-- @param modelId number: The ID of the model, -1 if not used.
-- @param numberOfFlights number: The total number of flights, defaults to 0.
-- @param totalFlightDurationSeconds number: The total flight duration in seconds.
-- @return Aircraft: A new Aircraft instance.
function Aircraft.new(modelId, numberOfFlights, totalFlightDurationSeconds)
    local self = setmetatable({}, Aircraft)

    self.modelId = modelId or -1
    self.numberOfFlights = numberOfFlights or 0
    self.totalFlightDurationSeconds = totalFlightDurationSeconds or 0

    return self
end

--- Converts the Aircraft instance to a string representation.
-- @return string: A string representation of the Aircraft instance.
function Aircraft:__tostring()
    return string.format(
        "Aircraft(" ..
        "modelId=%d, " ..
        "numberOfFlights=%d, " ..
        "totalFlightDurationSeconds=%d s)",
        self.modelId,
        self.numberOfFlights,
        self.totalFlightDurationSeconds
    )
end

--- Increments the flight count for the aircraft.
function Aircraft:incrementFlightCount()
    self.numberOfFlights = self.numberOfFlights + 1
end

--- Adds flight duration to the aircraft's total flight time.
-- @param duration number: The duration to add in seconds.
function Aircraft:addFlightDuration(duration)
    self.totalFlightDurationSeconds = self.totalFlightDurationSeconds + duration
end

-- endregion

return {
    Flight = Flight,
    Aircraft = Aircraft
}
