--- Asserts that a condition is true.
-- @param condition boolean: The condition to check.
-- @param message string|nil: Optional message to display if the assertion fails.
-- @param caller_depth number: The depth of the caller in the stack (default is 0).
local function assert_true(condition, message, caller_depth)
    local info = debug.getinfo(2 + (caller_depth or 0), "Sl")  -- Get the caller's info
    local filename = info.short_src
    local line = info.currentline

    if not condition then
        assertion_error = string.format("❌ Assertion failed at %s:%d. ", filename, line) .. 
            (message or "Expected true, but got false.")
        print(assertion_error)
        error(assertion_error, 2)
    end
    print(string.format("✅ Assertion succeeded at %s:%d.", filename, line))
end

--- Asserts that a condition is false.
-- @param condition boolean: The condition to check.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_false(condition, message)
    return assert_true(not condition, message or "Expected false, but got true.")
end

--- Asserts that two values are equal.
-- @param lhs any: The left-hand side value.
-- @param rhs any: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_eq(lhs, rhs, message)
    return assert_true(lhs == rhs, string.format("Expected %s, but got %s.", tostring(rhs), tostring(lhs)))
end

--- Asserts that two values are not equal.
-- @param lhs any: The left-hand side value.
-- @param rhs any: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_ne(lhs, rhs, message)
    return assert_true(lhs ~= rhs, string.format("Expected anything other than %s.", tostring(lhs)))
end

--- Asserts that the left-hand side value is less than or equal to the right-hand side value.
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_le(lhs, rhs, message)
    return assert_true(lhs <= rhs, string.format("Expected %s to be less than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is greater than or equal to the right-hand side value.
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_ge(lhs, rhs, message)
    return assert_true(lhs >= rhs, string.format("Expected %s to be greater than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is less than or equal to the right-hand side value (alias for assert_le).
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_leq(lhs, rhs, message)
    return assert_true(lhs <= rhs, string.format("Expected %s to be less than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that the left-hand side value is greater than or equal to the right-hand side value (alias for assert_ge).
-- @param lhs number: The left-hand side value.
-- @param rhs number: The right-hand side value.
-- @param message string|nil: Optional message to display if the assertion fails.
local function assert_geq(lhs, rhs, message)
    return assert_true(lhs >= rhs, string.format("Expected %s to be greater than or equal to %s.", tostring(lhs), tostring(rhs)))
end

--- Asserts that a function raises an error when called.
-- @param func function: The function to call.
-- @param ... any: Arguments to pass to the function.
local function assert_error(func, ...)
    local status, err = pcall(func, ...)
    assert_true(not status, "Expected an error, but got none.", 1)
end

return {
    assert_true = assert_true,
    assert_false = assert_false,
    assert_eq = assert_eq,
    assert_ne = assert_ne,
    assert_le = assert_le,
    assert_ge = assert_ge,
    assert_leq = assert_leq,
    assert_geq = assert_geq,
    assert_error = assert_error,
}
