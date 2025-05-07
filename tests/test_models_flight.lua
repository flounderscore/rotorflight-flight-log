local models = assert(loadfile("../scripts/rfflightlog/lib/models.lua"))()
local asserts = assert(loadfile("asserts.lua"))()

print(asserts) -- Ensure asserts module is loaded correctly.

local now = os.time()
local segmentDuration = 20
local waitDuration = 5

-- Check initialization of `Flight` with default values.
local flight = models.Flight.new(42, 12, 2)
asserts.assertEq(flight.flightIndex, 42)
asserts.assertEq(flight.modelId, 12)
asserts.assertEq(flight.batteryId, 2)
asserts.assertEq(flight.flightStartTime, nil)
asserts.assertEq(flight.flightSegmentStartTime, nil)
asserts.assertEq(flight.flightDurationSeconds, 0)
asserts.assertEq(flight.capacityUsedMah, 0)
asserts.assertFalse(flight.isCompleted)

-- Start a flight (which would happen by arming, for example).
flight:startFlight(now)
asserts.assertEq(flight.flightStartTime, now)
asserts.assertNe(flight.flightSegmentStartTime, nil)
asserts.assertFalse(flight.isCompleted)

-- Start the first segment (which would happen when the throttle exceeds zero).
now = now + waitDuration
flight:startSegment(now)
asserts.assertEq(flight.flightSegmentStartTime, now)
asserts.assertLe(flight.flightStartTime, now)
asserts.assertEq(flight.flightDurationSeconds, 0) -- First segment, accumulated duration still zero.
asserts.assertFalse(flight.isCompleted)

asserts.assertError(function() flight:startSegment(now) end) -- Cannot start another segment before finishing.

-- Finish the first segment (which would happen on disarm, throttle, or governor state).
now = now + segmentDuration
flight:finishSegment(now)
asserts.assertEq(flight.flightDurationSeconds, segmentDuration)
asserts.assertLe(flight.flightSegmentStartTime, 0)
asserts.assertFalse(flight.isCompleted)

asserts.assertError(function() flight:finishSegment(now) end) -- Cannot finish another segment before starting.

-- Start the second segment.
now = now + waitDuration
flight:startSegment(now)
asserts.assertEq(flight.flightSegmentStartTime, now)
asserts.assertLe(flight.flightStartTime, now)
asserts.assertGe(flight.flightDurationSeconds, 0) -- Duration already contains the duration of the first segment.
asserts.assertFalse(flight.isCompleted)

-- Finish the second segment.
now = now + segmentDuration
flight:finishSegment(now)
asserts.assertEq(flight.flightDurationSeconds, segmentDuration * 2)
asserts.assertLe(flight.flightSegmentStartTime, 0)
asserts.assertFalse(flight.isCompleted)

asserts.assertError(function() flight:toTable() end) -- Cannot convert to table before finishing.

-- Finish the flight (which happens when telemetry is dropped for more than some amount of time or if re-arming is attempted and the used capacity reported by telemetry is decreased).
now = now + waitDuration
flight:finishFlight(1234, now)
asserts.assertEq(flight.flightDurationSeconds, segmentDuration * 2)
asserts.assertLe(flight.flightSegmentStartTime, 0)
asserts.assertLe(flight.flightStartTime, now)
asserts.assertEq(flight.capacityUsedMah, 1234)
asserts.assertTrue(flight.isCompleted)

asserts.assertError(function() flight:finishSegment(now) end) -- Cannot finish another segment after finishing.

asserts.assertNe(tostring(flight), "") -- Smoke test.
