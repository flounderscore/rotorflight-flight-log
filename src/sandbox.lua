local models = require("models")
local flights = require("flights")

local fs = flights.Flights.new(
    os.tmpname() .. "_flights.csv",
    os.tmpname() .. "_aircraft.csv")

fs:appendFlight(
    models.Flight.new(
        nil, -- flightIndex
        0, -- modelId
        nil, -- batteryId (not used in this example)
        os.time(), -- flightStartTime
        os.time(), -- flightSegmentStartTime (same as flightStartTime for this example)
        3600, -- flightTimeSeconds
        1000, -- capacityUsedMah
        true -- isCompleted
    )
)

fs:appendFlight(
    models.Flight.new(
        nil, -- flightIndex
        0, -- modelId
        nil, -- batteryId (not used in this example)
        os.time(), -- flightStartTime
        os.time(), -- flightSegmentStartTime (same as flightStartTime for this example)
        7200, -- flightTimeSeconds
        2000, -- capacityUsedMah
        true -- isCompleted
    )
)

print(fs)