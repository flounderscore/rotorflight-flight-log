local models = require("models")
local asserts = require("tests.asserts")

local now = os.time()
local segmentDuration = 20
local waitDuration = 5

-- Check initialization of `Flight` with default values.
local flight = models.Flight.new(42, 12, 2)
asserts.assert_eq(flight.flightIndex, 42)
asserts.assert_eq(flight.modelId, 12)
asserts.assert_eq(flight.batteryId, 2)
asserts.assert_le(flight.flightStartTime, 0)
asserts.assert_le(flight.flightSegmentStartTime, 0)
asserts.assert_eq(flight.flightDurationSeconds, 0)
asserts.assert_eq(flight.capacityUsedMah, 0)
asserts.assert_false(flight.isCompleted)

-- Start a flight (which would happen by arming, for example).
flight:startFlight(now)
asserts.assert_eq(flight.flightStartTime, now)
asserts.assert_le(flight.flightSegmentStartTime, 0)
asserts.assert_false(flight.isCompleted)

-- Start the first segment (which would happen when the throttle exceeds zero).
now = now + waitDuration
flight:startSegment(now)
asserts.assert_eq(flight.flightSegmentStartTime, now)
asserts.assert_le(flight.flightStartTime, now)
asserts.assert_eq(flight.flightDurationSeconds, 0) -- First segment, accumulated duration still zero.
asserts.assert_false(flight.isCompleted)

asserts.assert_error(function() flight:startSegment(now) end) -- Cannot start another segment before finishing.

-- Finish the first segment (which would happen on disarm, throttle, or governor state).
now = now + segmentDuration
flight:finishSegment(now)
asserts.assert_eq(flight.flightDurationSeconds, segmentDuration)
asserts.assert_le(flight.flightSegmentStartTime, 0)
asserts.assert_false(flight.isCompleted)

asserts.assert_error(function() flight:finishSegment(now) end) -- Cannot finish another segment before starting.

-- Start the second segment.
now = now + waitDuration
flight:startSegment(now)
asserts.assert_eq(flight.flightSegmentStartTime, now)
asserts.assert_le(flight.flightStartTime, now)
asserts.assert_ge(flight.flightDurationSeconds, 0) -- Duration already contains the duration of the first segment.
asserts.assert_false(flight.isCompleted)

-- Finish the second segment.
now = now + segmentDuration
flight:finishSegment(now)
asserts.assert_eq(flight.flightDurationSeconds, segmentDuration * 2)
asserts.assert_le(flight.flightSegmentStartTime, 0)
asserts.assert_false(flight.isCompleted)

asserts.assert_error(function() flight:toTable() end) -- Cannot convert to table before finishing.

-- Finish the flight (which happens when telemetry is dropped for more than some amount of time or if re-arming is attempted and the used capacity reported by telemetry is decreased).
now = now + waitDuration
flight:finishFlight(1234, now)
asserts.assert_eq(flight.flightDurationSeconds, segmentDuration * 2)
asserts.assert_le(flight.flightSegmentStartTime, 0)
asserts.assert_le(flight.flightStartTime, now)
asserts.assert_eq(flight.capacityUsedMah, 1234)
asserts.assert_true(flight.isCompleted)

asserts.assert_error(function() flight:finishSegment(now) end) -- Cannot finish another segment after finishing.

asserts.assert_ne(tostring(flight), "") -- Smoke test.
