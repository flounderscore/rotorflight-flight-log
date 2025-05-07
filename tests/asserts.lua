--- Asserts that a condition is true.
-- @param condition boolean: The condition to check.
-- @param message string|nil: Optional message to display if the assertion fails.
-- @param callerDepth number: The depth of the caller in the stack (default is 0).
local function assertTrue(condition, message, callerDepth)
    local info = debug.getinfo(2 + (callerDepth or 0), "Sl")  -- Get the caller's info
    local filename = info.short_src
    local line = info.currentline

    if not condition then
        local assertionError = string.format("❌ Assertion failed at %s:%d. ", filename, line) .. 
            (message or "Expected true, but got false.")
        print(assertionError)
        error(assertionError, 2)
    end
    print(string.format("✅ Assertion succeeded at %s:%d.", filename, line))
end

--- Asserts that a condition is false.
-- @param condition boolean: The condition to check.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertFalse(condition, message)
    return assertTrue(not condition, message or "Expected false, but got true.")
end

--- Asserts that two values are equal.
-- @param lhs any: The left-hand side value.
-- @param rhs any: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertEq(lhs, rhs, message)
    return assertTrue(lhs == rhs, string.format("Expected %s, but got %s.", tostring(rhs), tostring(lhs)))
end

--- Asserts that two values are not equal.
-- @param lhs any: The left-hand side value.
-- @param rhs any: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertNe(lhs, rhs, message)
    return assertTrue(lhs ~= rhs, string.format("Expected anything other than %s.", tostring(lhs)))
end

--- Asserts that the left-hand side value is less than or equal to the right-hand side value.
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertLe(lhs, rhs, message)
    return assertTrue(lhs <= rhs, string.format("Expected %s to be less than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is greater than or equal to the right-hand side value.
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertGe(lhs, rhs, message)
    return assertTrue(lhs >= rhs, string.format("Expected %s to be greater than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is less than or equal to the right-hand side value (alias for assertLe).
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertLeq(lhs, rhs, message)
    return assertTrue(lhs <= rhs, string.format("Expected %s to be less than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is greater than or equal to the right-hand side value (alias for assertGe).
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assertGeq(lhs, rhs, message)
    return assertTrue(lhs >= rhs, string.format("Expected %s to be greater than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that a function raises an error when called.
-- @param func function: The function to call.
-- @param ... any: Arguments to pass to the function.
local function assertError(func, ...)
    local status, err = pcall(func, ...)
    assertTrue(not status, "Expected an error, but got none.", 1)
end

return {
    assertTrue = assertTrue,
    assertFalse = assertFalse,
    assertEq = assertEq,
    assertNe = assertNe,
    assertLe = assertLe,
    assertGe = assertGe,
    assertLeq = assertLeq,
    assertGeq = assertGeq,
    assertError = assertError,
}
